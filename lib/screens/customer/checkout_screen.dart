import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../../config/theme.dart';
import '../../services/api_service.dart';

class CheckoutScreen extends StatefulWidget {
  final List<dynamic> cartItems;
  const CheckoutScreen({super.key, required this.cartItems});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _addressCtrl = TextEditingController();
  final _cityCtrl = TextEditingController();
  final _provinceCtrl = TextEditingController();

  LatLng? _selectedLatLng;
  final MapController _mapController = MapController();
  final String _selectedCourier = 'NUSA-DHIPA';
  bool _loading = false;
  bool _loadingAddress = true;
  double _totalWeightKg = 0;

  @override
  void initState() {
    super.initState();
    _calculateTotalWeight();
    _loadAddress();
  }

  Future<void> _loadAddress() async {
    try {
      final list = await ApiService().getAddresses();
      if (list.isNotEmpty && mounted) {
        final addr = list.first;
        setState(() {
          _nameCtrl.text = addr['recipient_name'] ?? '';
          _phoneCtrl.text = addr['phone'] ?? '';
          _addressCtrl.text = addr['address_line'] ?? '';
          _cityCtrl.text = addr['city'] ?? '';
          _provinceCtrl.text = addr['province'] ?? '';
          
          // Tarik koordinat dari database
          if (addr['latitude'] != null && addr['longitude'] != null) {
            _selectedLatLng = LatLng(
              double.parse(addr['latitude'].toString()),
              double.parse(addr['longitude'].toString()),
            );
            // Geser peta ke titik tersebut
            _mapController.move(_selectedLatLng!, 15);
          }
        });
      }
    } catch (e) {
      // Abaikan jika belum ada alamat
    } finally {
      if (mounted) setState(() => _loadingAddress = false);
    }
  }

  void _calculateTotalWeight() {
    _totalWeightKg = widget.cartItems.fold(0.0, (sum, item) {
      final qty = (item['quantity'] as num?)?.toInt() ?? 1;
      final weight = (item['weight_grams'] as num?)?.toDouble() ?? 500.0;
      return sum + ((weight * qty) / 1000);
    });
  }

  double _calculateDistanceKm(LatLng store, LatLng buyer) {
    const distance = Distance();
    return distance.as(LengthUnit.Kilometer, store, buyer);
  }

  Future<void> _submitOrder() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedLatLng == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pilih lokasi pengiriman di peta'), backgroundColor: Colors.orange),
      );
      return;
    }

    setState(() => _loading = true);

    try {
      final rawLat = widget.cartItems.first['business_lat'] as num?;
      final rawLng = widget.cartItems.first['business_lng'] as num?;
      if (rawLat == null || rawLng == null) throw Exception('Lokasi toko tidak ditemukan.');
      
      final storeLatLng = LatLng(rawLat.toDouble(), rawLng.toDouble());
      final distanceKm = _calculateDistanceKm(storeLatLng, _selectedLatLng!);

      final body = {
        'items': widget.cartItems.map((item) => {
          'variant_id': item['variant_id'],
          'quantity': item['quantity'],
          'selling_mode': item['selling_mode'] ?? 'package',
        }).toList(),
        'shipping_address': {
          'name': _nameCtrl.text.trim(),
          'phone': _phoneCtrl.text.trim(),
          'address': _addressCtrl.text.trim(),
          'city': _cityCtrl.text.trim(),
          'province': _provinceCtrl.text.trim(),
        },
        'courier': _selectedCourier,
        'shipping_distance_km': distanceKm,
        'customer_note': '',
      };

      final response = await ApiService().createOrder(body);

      if (response['success'] == true) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Pesanan berhasil dibuat!'), backgroundColor: Colors.green),
          );
          Navigator.pop(context, true);
        }
      } else {
        throw Exception(response['message'] ?? 'Gagal membuat pesanan');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      appBar: AppBar(
        title: const Text('Checkout'),
        backgroundColor: const Color(0xFF1E293B),
        foregroundColor: Colors.white,
      ),
      body: _loadingAddress 
        ? const Center(child: CircularProgressIndicator(color: brandRed))
        : Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              const Text('Alamat Pengiriman', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
              const SizedBox(height: 12),
              _buildField(_nameCtrl, 'Nama Penerima', Icons.person),
              _buildField(_phoneCtrl, 'No. Telepon', Icons.phone),
              _buildField(_addressCtrl, 'Alamat Lengkap', Icons.location_on, maxLines: 2),
              _buildField(_cityCtrl, 'Kota', Icons.location_city),
              _buildField(_provinceCtrl, 'Provinsi', Icons.map),

              const SizedBox(height: 24),
              const Text('Pilih Lokasi di Peta', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
              const SizedBox(height: 8),
              SizedBox(
                height: 200,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: FlutterMap(
                    mapController: _mapController,
                    options: MapOptions(
                      initialCenter: _selectedLatLng ?? const LatLng(-6.2, 106.816),
                      initialZoom: 13,
                      onTap: (tapPosition, point) => setState(() => _selectedLatLng = point),
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
                    ? 'Ketuk peta untuk menentukan lokasi'
                    : 'Lat: ${_selectedLatLng!.latitude.toStringAsFixed(5)}, Lng: ${_selectedLatLng!.longitude.toStringAsFixed(5)}',
                style: const TextStyle(fontSize: 11, color: Colors.white54),
              ),

              const SizedBox(height: 24),
              const Text('Pilih Kurir', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(vertical: 8),
                decoration: BoxDecoration(
                  color: brandRed.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: brandRed),
                ),
                child: const RadioListTile<String>(
                  title: Text('NUSA-DHIPA', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
                  subtitle: Text('Instant/Same Day (Wajib)', style: TextStyle(color: Colors.white70)),
                  value: 'NUSA-DHIPA',
                  groupValue: 'NUSA-DHIPA',
                  onChanged: null,
                  activeColor: brandRed,
                ),
              ),

              const SizedBox(height: 24),
              Text(
                'Berat total: ${_totalWeightKg.toStringAsFixed(2)} kg',
                style: const TextStyle(fontSize: 12, color: Colors.white54),
              ),
              const SizedBox(height: 8),
              SizedBox(
                height: 50,
                child: ElevatedButton(
                  onPressed: _loading ? null : _submitOrder,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: brandRed,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: _loading
                      ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                      : const Text('Buat Pesanan', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                ),
              ),
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
