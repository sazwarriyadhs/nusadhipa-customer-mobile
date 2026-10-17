import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/business_model.dart';

class ApiService {
  // Ubah dari static const ke final (karena dipanggil via instance)
  final String baseUrl = 'http://localhost:4000/api/v1';

  // Hapus 'static' di semua fungsi agar bisa dipanggil pakai ApiService()
  
  Future<void> cekHealth() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/health'));
      if (response.statusCode == 200) {
        print('✅ API Terhubung: ${response.body}');
      }
    } catch (e) {
      print('❌ Gagal konek API: $e');
    }
  }

  Future<List<BusinessModel>> getBusinesses() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/businesses'));
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true) {
          List<dynamic> listData = data['data'];
          return listData.map((e) => BusinessModel.fromJson(e)).toList();
        }
      }
      throw Exception('Gagal load businesses: ${response.statusCode}');
    } catch (e) {
      print('Error API Businesses: $e');
      return [];
    }
  }

  // Fungsi ini yang dicari sama home_screen.dart
  Future<dynamic> getProducts({int limit = 100}) async {
    try {
      // Sesuaikan '/products' kalau route di backend kamu beda
      final response = await http.get(Uri.parse('$baseUrl/products?limit=$limit'));
      
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
      return null;
    } catch (e) {
      print('Error API Products: $e');
      return null;
    }
  }
}
