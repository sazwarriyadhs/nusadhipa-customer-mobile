import 'dart:async';
import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import '../config/api_config.dart';
import 'auth_service.dart';
import '../models/product.dart';
import '../models/business.dart';
import '../models/order.dart';
import '../models/order_detail.dart';
import '../models/financial_report.dart';

class ApiException implements Exception {
  final String message;
  final int? statusCode;
  ApiException(this.message, {this.statusCode});
  @override
  String toString() => message;
}

class ApiService {
  static final ApiService _instance = ApiService._();
  factory ApiService() => _instance;
  ApiService._();

  Future<Map<String, dynamic>> _get(String path,
      {Map<String, String>? query}) async {
    final uri = Uri.parse('${ApiConfig.kApiBaseUrl}$path')
        .replace(queryParameters: query);

    try {
      final token = await AuthService().getToken();
      final headers = <String, String>{'Accept': 'application/json'};
      if (token != null && token.isNotEmpty) {
        headers['Authorization'] = 'Bearer $token';
      }

      final response = await http
          .get(uri, headers: headers)
          .timeout(const Duration(milliseconds: ApiConfig.kTimeoutMs));

      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw ApiException(
          'API mengembalikan HTTP ${response.statusCode}',
          statusCode: response.statusCode,
        );
      }

      return jsonDecode(response.body) as Map<String, dynamic>;
    } on TimeoutException {
      throw ApiException('Permintaan timeout. Periksa koneksi.');
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('Tidak dapat terhubung ke server.');
    }
  }

  Future<List<Product>> getProducts({
    String? query,
    String? category,
    String? businessSlug,
    int page = 1,
    int limit = 20,
  }) async {
    final params = <String, String>{
      'page': page.toString(),
      'limit': limit.toString(),
    };
    if (query != null && query.trim().isNotEmpty) {
      params['q'] = query.trim();
    }
    if (category != null && category.trim().isNotEmpty) {
      params['category'] = category.trim();
    }
    if (businessSlug != null && businessSlug.trim().isNotEmpty) {
      params['business'] = businessSlug.trim();
    }

    final json = await _get(ApiConfig.kProducts, query: params);
    final data = json['data'];
    if (data is! List) return [];

    return data
        .whereType<Map<String, dynamic>>()
        .map(Product.fromJson)
        .toList();
  }

  Future<List<Category>> getCategories() async {
    final json = await _get(ApiConfig.kCategories);
    final data = json['data'];
    if (data is! List) return [];

    return data
        .whereType<Map<String, dynamic>>()
        .map(Category.fromJson)
        .toList();
  }

  // ==================== BUSINESS ====================
  Future<Business> getMyBusiness() async {
    final json = await _get(ApiConfig.kBusinessMe);
    final data = json['data'];
    if (data is! Map<String, dynamic>) {
      throw ApiException('Format data business tidak valid');
    }
    return Business.fromJson(data);
  }

  // ==================== ORDERS ====================
  Future<List<Order>> getOrders({String? status}) async {
    final params = <String, String>{};
    if (status != null && status.isNotEmpty && status != 'all') {
      params['status'] = status;
    }

    final json = await _get(ApiConfig.kOrders, query: params);
    final data = json['data'];
    if (data is! List) return [];

    return data
        .whereType<Map<String, dynamic>>()
        .map(Order.fromJson)
        .toList();
  }

  // ==================== SHIPMENTS ====================
  Future<List<Shipment>> getShipments() async {
    final json = await _get(ApiConfig.kShipments);
    final data = json['data'];
    if (data is! List) return [];

    return data
        .whereType<Map<String, dynamic>>()
        .map(Shipment.fromJson)
        .toList();
  }

  // ==================== ORDER DETAIL ====================
  Future<OrderDetail> getOrderDetail(String publicId) async {
    final json = await _get('${ApiConfig.kOrders}/$publicId');
    final data = json['data'];
    if (data is! Map<String, dynamic>) {
      throw ApiException('Format detail order tidak valid');
    }
    return OrderDetail.fromJson(data);
  }

  // ==================== FINANCIAL REPORT ====================
  Future<FinancialReport> getFinancialReport({
    String? from,
    String? to,
  }) async {
    final params = <String, String>{};
    if (from != null) params['from'] = from;
    if (to != null) params['to'] = to;

    final json = await _get(ApiConfig.kReportFinancial, query: params);
    final data = json['data'];
    if (data is! Map<String, dynamic>) {
      throw ApiException('Format laporan tidak valid');
    }
    return FinancialReport.fromJson(data);
  }

  // ==================== CREATE PRODUCT ====================
  Future<Map<String, dynamic>> createProduct({
    required String name,
    required double price,
    required int stock,
    String? description,
    String? categorySlug,
    String? sku,
  }) async {
    final uri = Uri.parse('${ApiConfig.kApiBaseUrl}${ApiConfig.kProducts}');

    try {
      final response = await http
          .post(
            uri,
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
            },
            body: jsonEncode({
              'name': name.trim(),
              'price': price,
              'stock': stock,
              'description': description?.trim(),
              'category_slug': categorySlug,
              'sku': sku,
            }),
          )
          .timeout(const Duration(milliseconds: ApiConfig.kTimeoutMs));

      final json = jsonDecode(response.body) as Map<String, dynamic>;

      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw ApiException(
          json['message']?.toString() ?? 'Gagal membuat produk',
          statusCode: response.statusCode,
        );
      }

      if (json['success'] != true) {
        throw ApiException(
          json['message']?.toString() ?? 'Gagal membuat produk',
        );
      }

      final data = json['data'];
      if (data is Map<String, dynamic>) return data;
      return <String, dynamic>{};
    } on TimeoutException {
      throw ApiException('Permintaan timeout. Periksa koneksi.');
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('Tidak dapat terhubung ke server.');
    }
  }

  // ==================== UPDATE PRODUCT ====================
  Future<Map<String, dynamic>> updateProduct({
    required String publicId,
    String? name,
    double? price,
    int? stock,
    String? description,
    String? categorySlug,
  }) async {
    final uri = Uri.parse(
      '${ApiConfig.kApiBaseUrl}${ApiConfig.kProducts}/$publicId',
    );

    final body = <String, dynamic>{};
    if (name != null) body['name'] = name.trim();
    if (price != null) body['price'] = price;
    if (stock != null) body['stock'] = stock;
    if (description != null) body['description'] = description.trim();
    if (categorySlug != null) body['category_slug'] = categorySlug;

    try {
      final response = await http
          .put(
            uri,
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
            },
            body: jsonEncode(body),
          )
          .timeout(const Duration(milliseconds: ApiConfig.kTimeoutMs));

      final json = jsonDecode(response.body) as Map<String, dynamic>;

      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw ApiException(
          json['message']?.toString() ?? 'Gagal update produk',
          statusCode: response.statusCode,
        );
      }

      if (json['success'] != true) {
        throw ApiException(
          json['message']?.toString() ?? 'Gagal update produk',
        );
      }

      final data = json['data'];
      if (data is Map<String, dynamic>) return data;
      return <String, dynamic>{};
    } on TimeoutException {
      throw ApiException('Permintaan timeout. Periksa koneksi.');
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('Tidak dapat terhubung ke server.');
    }
  }

  // ==================== DELETE PRODUCT ====================
  Future<void> deleteProduct(String publicId) async {
    final uri = Uri.parse(
      '${ApiConfig.kApiBaseUrl}${ApiConfig.kProducts}/$publicId',
    );

    try {
      final response = await http
          .delete(
            uri,
            headers: {'Accept': 'application/json'},
          )
          .timeout(const Duration(milliseconds: ApiConfig.kTimeoutMs));

      final json = jsonDecode(response.body) as Map<String, dynamic>;

      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw ApiException(
          json['message']?.toString() ?? 'Gagal hapus produk',
          statusCode: response.statusCode,
        );
      }

      if (json['success'] != true) {
        throw ApiException(
          json['message']?.toString() ?? 'Gagal hapus produk',
        );
      }
    } on TimeoutException {
      throw ApiException('Permintaan timeout. Periksa koneksi.');
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('Tidak dapat terhubung ke server.');
    }
  }

  // ==================== GET PRODUCT DETAIL ====================
  Future<Product> getProduct(String slug) async {
    final json = await _get(
      '${ApiConfig.kProducts}/${Uri.encodeComponent(slug)}',
    );
    final data = json['data'];
    if (data is! Map<String, dynamic>) {
      throw ApiException('Format detail produk tidak valid');
    }
    return Product.fromJson(data);
  }

  // ==================== UPLOAD PRODUCT IMAGE ====================
  Future<Map<String, dynamic>> uploadProductImage({
    required String productPublicId,
    required File imageFile,
    bool isPrimary = true,
  }) async {
    final uri = Uri.parse(
      '${ApiConfig.kApiBaseUrl}/products/$productPublicId/images',
    );

    try {
      final request = http.MultipartRequest('POST', uri);

      final ext = imageFile.path.split('.').last.toLowerCase();
      final mimeType = ext == 'png'
          ? 'image/png'
          : ext == 'webp'
              ? 'image/webp'
              : 'image/jpeg';

      request.files.add(
        await http.MultipartFile.fromPath(
          'image',
          imageFile.path,
          contentType: MediaType.parse(mimeType),
        ),
      );
      request.fields['is_primary'] = isPrimary ? '1' : '0';

      final streamed = await request
          .send()
          .timeout(const Duration(milliseconds: 30000));
      final response = await http.Response.fromStream(streamed);
      final json = jsonDecode(response.body) as Map<String, dynamic>;

      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw ApiException(
          json['message']?.toString() ?? 'Gagal upload gambar',
          statusCode: response.statusCode,
        );
      }

      if (json['success'] != true) {
        throw ApiException(
          json['message']?.toString() ?? 'Gagal upload gambar',
        );
      }

      final data = json['data'];
      if (data is Map<String, dynamic>) return data;
      return <String, dynamic>{};
    } on TimeoutException {
      throw ApiException('Upload timeout. Coba lagi.');
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('Gagal upload: ${e.toString()}');
    }
  }
}