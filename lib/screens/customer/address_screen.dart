import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:http/http.dart' as http;
import '../../config/theme.dart';
import '../../services/api_service.dart';

class AddressScreen extends StatefulWidget {
  const AddressScreen({super.key});

  @override
  State<AddressScreen> createState() => _AddressScreenState();
}

class _AddressScreenState extends State<AddressScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _addressCtrl = TextEditingController();
  final _cityCtrl = TextEditingController();
  final _provinceCtrl = TextEditingController();
  
  LatLng? _selectedLatLng;
  final MapController _mapController = MapController();
  bool _loading = false;
  bool _searchingLocation = false;

  // FUNGSI BARU: Panggil OpenStreetMap Nominatim API langsung
  Future<void> _searchCoordinates() async {
    final fullAddress = "${_addressCtrl.text.trim()}, ${_cityCtrl.text.trim()}, ${_provinceCtrl.text.trim()}";
    
    if (fullAddress.trim() == ', ,' || fullAddress.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Isi alamat/kota dulu untuk mencari titik'), backgroundColor: Colors.orange),
      );
      return;
    }

    setState(() => _searchingLocation = true);

    try {
      // Nominatim API (OpenStreetMap)
      final url = Uri.parse('https://nominatim.openstreetmap.org/search?q=$fullAddress&format=json&limit=1');
      final response = await http.get(url, headers: {
        'User-Agent': 'NusadhipaCustomerApp/1.0', // Wajib buat Nominatim
      });

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data is List && data.isNotEmpty) {
          final lat = double.parse(data[0]['lat']);
          final lon = double.parse(data[0]['lon']);
          final newLatLng = LatLng(lat, lon);
          
          setState(() {
            _selectedLatLng = newLatLng;
          });
          
          _mapController.move(newLatLng, 16);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Titik lokasi ditemukan!'), backgroundColor: Colors.green),
          );
        } else {
          throw Exception('Alamat tidak ditemukan');
        }
      } else {
        throw Exception('Gagal koneksi ke OSM');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal mencari lokasi: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _searchingLocation = false);
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedLatLng == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Klik "Cari Koordinat" atau ketuk peta manual'), backgroundColor: Colors.orange),
      );
      return;
    }

    setState(() => _loading = true);
    
    try {
      await ApiService().saveAddress({
        'name': _nameCtrl.text.trim(),
        'phone': _phoneCtrl.text.trim(),
        'address': _addressCtrl.text.trim(),
        'city': _cityCtrl.text.trim(),
        'province': _provinceCtrl.text.trim(),
        'latitude': _selectedLatLng!.latitude,
        'longitude': _selectedLatLng!.longitude,
      });
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Alamat & Koordinat berhasil disimpan!'), backgroundColor: Colors.green),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal menyimpan alamat: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0F172A),
        title: const Text('Tambah Alamat', style: TextStyle(color: Colors.white)),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            _buildField(_nameCtrl, 'Nama Penerima', Icons.person),
            _buildField(_phoneCtrl, 'No. Telepon', Icons.phone),
            _buildField(_addressCtrl, 'Alamat Lengkap', Icons.location_on, maxLines: 2),
            _buildField(_cityCtrl, 'Kota', Icons.location_city),
            _buildField(_provinceCtrl, 'Provinsi', Icons.map),

            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Titik Koordinat (Wajib)', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                TextButton.icon(
                  onPressed: _searchingLocation ? null : _searchCoordinates,
                  icon: _searchingLocation 
                      ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: brandRed))
                      : const Icon(Icons.search, color: brandRed, size: 18),
                  label: Text(
                    _searchingLocation ? 'Mencari...' : 'Cari dari Alamat',
                    style: const TextStyle(color: brandRed, fontSize: 12, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            SizedBox(
              height: 200,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: FlutterMap(
                  mapController: _mapController,
                  options: MapOptions(
                    initialCenter: _selectedLatLng ?? const LatLng(-2.5489, 118.0149), 
                    initialZoom: 4,
                    onTap: (tapPosition, point) {
                      setState(() => _selectedLatLng = point);
                    },
                  ),
                  children: [
                    TileLayer(
                      urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                      userAgentPackageName: 'com.nusadhipa.customer',
                    ),
                    if (_selectedLatLng != null)
                      MarkerLayer(
                        markers: [
                          Marker(
                            point: _selectedLatLng!,
                            width: 40,
                            height: 40,
                            child: const Icon(Icons.location_pin, color: brandRed, size: 40),
                          ),
                        ],
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              _selectedLatLng == null
                  ? 'Ketik alamat lalu klik "Cari dari Alamat", atau ketuk peta manual'
                  : 'Lat: ${_selectedLatLng!.latitude.toStringAsFixed(5)}, Lng: ${_selectedLatLng!.longitude.toStringAsFixed(5)}',
              style: const TextStyle(fontSize: 11, color: Colors.white54),
            ),
            const SizedBox(height: 24),
            
            SizedBox(
              height: 50,
              child: ElevatedButton(
                onPressed: _loading ? null : _save,
                style: ElevatedButton.styleFrom(
                  backgroundColor: brandRed,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: _loading 
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text('Simpan Alamat', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildField(TextEditingController ctrl, String label, IconData icon, {int maxLines = 1}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: ctrl,
        maxLines: maxLines,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: Colors.white70),
          prefixIcon: Icon(icon, color: brandRed),
          filled: true,
          fillColor: const Color(0xFF1E293B),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
        ),
        validator: (v) => (v == null || v.isEmpty) ? 'Wajib diisi' : null,
      ),
    );
  }
}
