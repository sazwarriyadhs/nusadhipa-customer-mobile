import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import 'auth_service.dart';
import '../models/product.dart';
import '../models/business.dart';
import '../models/order.dart';

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

  Future<Map<String, String>> _getHeaders({bool isJson = true}) async {
    final token = await AuthService().getToken();
    final headers = <String, String>{'Accept': 'application/json'};
    if (isJson) headers['Content-Type'] = 'application/json';
    if (token != null && token.isNotEmpty) {
      headers['Authorization'] = 'Bearer $token';
    }
    return headers;
  }

  Future<Map<String, dynamic>> _get(String path, {Map<String, String>? query}) async {
    final uri = Uri.parse('${ApiConfig.kApiBaseUrl}$path').replace(queryParameters: query);
    try {
      final headers = await _getHeaders(isJson: false);
      final response = await http.get(uri, headers: headers).timeout(const Duration(milliseconds: ApiConfig.kTimeoutMs));

      if (response.statusCode < 200 || response.statusCode >= 300) {
        String errorMsg = 'API mengembalikan HTTP ${response.statusCode}';
        try {
          final errJson = jsonDecode(response.body);
          if (errJson is Map && errJson['error'] != null) {
            errorMsg = errJson['error'].toString();
          } else if (errJson is Map && errJson['message'] != null) {
            errorMsg = errJson['message'].toString();
          }
        } catch (_) {}
        throw ApiException(errorMsg, statusCode: response.statusCode);
      }

      try {
        final decoded = jsonDecode(response.body);
        if (decoded is! Map<String, dynamic>) {
          throw ApiException('Format response tidak valid');
        }
        return decoded;
      } catch (e) {
        throw ApiException('Gagal parsing response: ${e.toString()}');
      }
    } on TimeoutException {
      throw ApiException('Permintaan timeout. Periksa koneksi.');
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('Tidak dapat terhubung ke server: ${e.toString()}');
    }
  }

  Future<Map<String, dynamic>> _post(String path, {Map<String, dynamic>? body}) async {
    final uri = Uri.parse('${ApiConfig.kApiBaseUrl}$path');
    try {
      final response = await http.post(
        uri,
        headers: {...await _getHeaders(), 'Content-Type': 'application/json'},
        body: body != null ? jsonEncode(body) : null,
      ).timeout(Duration(milliseconds: ApiConfig.kTimeoutMs));
      
      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw ApiException('HTTP ${response.statusCode}', statusCode: response.statusCode);
      }
      return jsonDecode(response.body) as Map<String, dynamic>;
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('Gagal mengirim data: ${e.toString()}');
    }
  }

  Future<Map<String, dynamic>> _delete(String path) async {
    final uri = Uri.parse('${ApiConfig.kApiBaseUrl}$path');
    try {
      final response = await http.delete(uri, headers: await _getHeaders()).timeout(Duration(milliseconds: ApiConfig.kTimeoutMs));
      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw ApiException('HTTP ${response.statusCode}', statusCode: response.statusCode);
      }
      return jsonDecode(response.body) as Map<String, dynamic>;
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('Gagal menghapus data: ${e.toString()}');
    }
  }

  Future<Map<String, dynamic>> _patch(String path, {Map<String, dynamic>? body}) async {
    final uri = Uri.parse('${ApiConfig.kApiBaseUrl}$path');
    try {
      final response = await http.patch(
        uri,
        headers: {...await _getHeaders(), 'Content-Type': 'application/json'},
        body: body != null ? jsonEncode(body) : null,
      ).timeout(Duration(milliseconds: ApiConfig.kTimeoutMs));

      if (response.statusCode < 200 || response.statusCode >= 300) {
        String message = 'HTTP ${response.statusCode}';
        try {
          final decoded = jsonDecode(response.body);
          if (decoded is Map && decoded['message'] != null) {
            message = decoded['message'].toString();
          }
        } catch (_) {}
        throw ApiException(message, statusCode: response.statusCode);
      }
      return jsonDecode(response.body) as Map<String, dynamic>;
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('Gagal mengupdate data: ${e.toString()}');
    }
  }

  // TAMBAHAN: Fungsi Update Profil untuk EditProfileScreen
  Future<Map<String, dynamic>> updateProfile({required String name}) async {
    return await _patch('/customer/profile', body: {'name': name});
  }

  // ============================================================
  // PRODUCTS
  // ============================================================
  Future<List<Product>> getProducts({
    String? query,
    String? category,
    String? business,
    String? status,
    int page = 1,
    int limit = 100,
  }) async {
    final params = <String, String>{'page': page.toString(), 'limit': limit.toString()};
    if (query != null && query.trim().isNotEmpty) params['q'] = query.trim();
    if (category != null && category.trim().isNotEmpty) params['category'] = category.trim();
    if (business != null && business.trim().isNotEmpty) params['business'] = business.trim();
    if (status != null && status.trim().isNotEmpty) params['status'] = status.trim();

    final json = await _get('/products', query: params);
    final data = json['data'];
    if (data is! List) return [];
    return data.whereType<Map<String, dynamic>>().map(Product.fromJson).toList();
  }

  Future<dynamic> getProduct(String slug) async {
    final json = await _get('/products/$slug');
    return json['data'];
  }

  // ============================================================
  // CATEGORIES
  // ============================================================
  Future<List<Category>> getCategories() async {
    final json = await _get('/categories');
    final data = json['data'];
    if (data is! List) return [];
    return data.whereType<Map<String, dynamic>>().map(Category.fromJson).toList();
  }

  // ============================================================
  // BUSINESS
  // ============================================================
  Future<Business> getMyBusiness() async {
    final json = await _get('/businesses/me');
    final data = json['data'];
    if (data is! Map<String, dynamic>) {
      throw ApiException(json['error']?.toString() ?? 'Format data business tidak valid');
    }
    return Business.fromJson(data);
  }

  // ============================================================
  // ORDERS
  // ============================================================
  Future<List<Order>> getOrders({String? status}) async {
    final params = <String, String>{};
    if (status != null && status.isNotEmpty && status != 'all') {
      params['status'] = status;
    }
    final json = await _get('/orders', query: params);
    final data = json['data'];
    if (data is! List) return [];
    return data.whereType<Map<String, dynamic>>().map(Order.fromJson).toList();
  }

  // ============================================================
  // CART
  // ============================================================
  Future<List<dynamic>> getCart() async {
    final json = await _get('/cart');
    final data = json['data'];
    if (data is List) return data;
    if (data is Map) {
      final items = data['items'];
      if (items is List) return items;
    }
    return <dynamic>[];
  }

  Future<void> addToCart(dynamic variantId, int quantity, {String sellingMode = 'package'}) async {
    await _post('/cart/items', body: {
      'variant_id': variantId,
      'quantity': quantity,
      'selling_mode': sellingMode,
    });
  }

  Future<void> updateCartItem(dynamic cartItemId, int quantity) async {
    await _patch('/cart/items/$cartItemId', body: {'quantity': quantity});
  }

  Future<void> removeFromCart(dynamic cartItemId) async {
    await _delete('/cart/items/$cartItemId');
  }

  Future<Map<String, dynamic>> getWallet() async {
    try {
      final json = await _get('/customer/wallet');
      final data = json['data'];
      if (data is Map<String, dynamic>) return data;
      return {'balance': 0, 'points': 0};
    } catch (e) {
      return {'balance': 0, 'points': 0};
    }
  }

  // ============================================================
  // CHECKOUT
  // ============================================================
  Future<Map<String, dynamic>> createOrder(Map<String, dynamic> body) async {
    return await _post('/orders', body: body);
  }
}
