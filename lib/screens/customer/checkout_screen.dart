import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:intl/intl.dart';
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

  String _selectedCourier = 'J&T Express';
  bool _isCourierLocked = false;
  String _lockReason = '';
  bool _loading = false;

  double _totalWeightKg = 0;

  final List<String> _courierOptions = ['J&T Express', 'JNE', 'NUSA-DHIPA'];

  @override
  void initState() {
    super.initState();
    _calculateTotalWeight();
  }

  void _calculateTotalWeight() {
    _totalWeightKg = widget.cartItems.fold(0.0, (sum, item) {
      final qty = (item['quantity'] as num?)?.toInt() ?? 1;
      final weight = (item['weight_grams'] as num?)?.toDouble() ?? 500.0;
      return sum + ((weight * qty) / 1000); // gram → kg
    });
  }

  void _checkCourierRules() {
    if (widget.cartItems.isEmpty) return;

    final sellerCity = (widget.cartItems.first['business_city'] ?? '').toString().toLowerCase().trim();
    final buyerCity = _cityCtrl.text.toLowerCase().trim();

    final isOutsideCity = sellerCity.isNotEmpty && buyerCity.isNotEmpty && sellerCity != buyerCity;
    final isOver100Kg = _totalWeightKg > 100;

    setState(() {
      if (isOutsideCity || isOver100Kg) {
        _isCourierLocked = true;
        _selectedCourier = 'NUSA-DHIPA';
        _lockReason = isOutsideCity
            ? 'Pesanan luar kota wajib NUSA-DHIPA'
            : 'Berat >100kg wajib NUSA-DHIPA';
      } else {
        _isCourierLocked = false;
        _lockReason = '';
      }
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
        const SnackBar(content: Text('Pilih lokasi pengiriman di peta')),
      );
      return;
    }

    setState(() => _loading = true);

    try {
      final storeLat = (widget.cartItems.first['business_lat'] as num?)?.toDouble() ?? -6.2;
      final storeLng = (widget.cartItems.first['business_lng'] as num?)?.toDouble() ?? 106.816;
      final storeLatLng = LatLng(storeLat, storeLng);
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
            const SnackBar(content: Text('Pesanan berhasil dibuat!')),
          );
          Navigator.pop(context, true);
        }
      } else {
        throw Exception(response['message'] ?? 'Gagal membuat pesanan');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Checkout'),
        backgroundColor: brandRed,
        foregroundColor: Colors.white,
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            const Text('Alamat Pengiriman', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            _buildTextField(_nameCtrl, 'Nama Penerima', Icons.person),
            _buildTextField(_phoneCtrl, 'No. Telepon', Icons.phone),
            _buildTextField(_addressCtrl, 'Alamat Lengkap', Icons.location_on),
            _buildTextField(_cityCtrl, 'Kota', Icons.location_city, onChanged: (_) => _checkCourierRules()),
            _buildTextField(_provinceCtrl, 'Provinsi', Icons.map),

            const SizedBox(height: 24),
            const Text('Pilih Lokasi di Peta', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            SizedBox(
              height: 250,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: FlutterMap(
                  mapController: _mapController,
                  options: MapOptions(
                    initialCenter: _selectedLatLng ?? const LatLng(-6.2, 106.816),
                    initialZoom: 13,
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
                  ? 'Ketuk peta untuk menentukan lokasi'
                  : 'Lat: ${_selectedLatLng!.latitude.toStringAsFixed(5)}, Lng: ${_selectedLatLng!.longitude.toStringAsFixed(5)}',
              style: const TextStyle(fontSize: 11, color: Colors.grey),
            ),

            const SizedBox(height: 24),
            const Text('Pilih Kurir', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            if (_isCourierLocked)
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(color: Colors.orange.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(8)),
                child: Row(
                  children: [
                    const Icon(Icons.lock, size: 16, color: Colors.orange),
                    const SizedBox(width: 6),
                    Expanded(child: Text(_lockReason, style: const TextStyle(fontSize: 11, color: Colors.orange))),
                  ],
                ),
              ),
            const SizedBox(height: 8),
            ..._courierOptions.map((courier) {
              final disabled = _isCourierLocked && courier != 'NUSA-DHIPA';
              return RadioListTile<String>(
                title: Text(courier, style: TextStyle(color: disabled ? Colors.grey : null)),
                value: courier,
                groupValue: _selectedCourier,
                onChanged: disabled ? null : (val) => setState(() => _selectedCourier = val!),
              );
            }),

            const SizedBox(height: 24),
            Text(
              'Berat total: ${_totalWeightKg.toStringAsFixed(2)} kg',
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
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

  Widget _buildTextField(TextEditingController ctrl, String label, IconData icon, {ValueChanged<String>? onChanged}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextFormField(
        controller: ctrl,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        ),
        onChanged: onChanged,
        validator: (val) => (val == null || val.trim().isEmpty) ? '$label wajib diisi' : null,
      ),
    );
  }
}