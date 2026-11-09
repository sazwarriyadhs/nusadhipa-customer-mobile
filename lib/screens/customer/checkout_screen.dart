import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import '../../config/theme.dart';
import '../../services/api_service.dart';
import '../../services/auth_service.dart';

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

  // Dark Theme Colors
  final Color _bgColor = const Color(0xFF0F172A);
  final Color _cardColor = const Color(0xFF1E293B);
  final Color _textColor = Colors.white;
  final Color _subTextColor = Colors.white70;
  final Color _borderColor = Colors.white24;

  bool _loading = false;
  bool _loadingAddress = true;
  bool _gpsLoading = false;
  double _totalWeightKg = 0;

  @override
  void initState() {
    super.initState();
    _calculateTotalWeight();
    _loadUserAndAddress();
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _phoneCtrl.dispose();
    _addressCtrl.dispose();
    _cityCtrl.dispose();
    _provinceCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadUserAndAddress() async {
    try {
      final user = await AuthService().getUser();
      if (user != null && mounted) {
        final email = user['email'] ?? '';
        final name = user['fullName'] ??
            user['full_name'] ??
            user['name'] ??
            (email.contains('@') ? email.split('@')[0] : 'Pelanggan');
        setState(() {
          _nameCtrl.text = name.toString();
          if (_phoneCtrl.text.isEmpty) {
            _phoneCtrl.text = (user['phone'] ?? user['phone_number'] ?? '').toString();
          }
        });
      }

      final list = await ApiService().getAddresses();
      if (list.isNotEmpty && mounted) {
        final addr = list.firstWhere(
          (a) => a['is_default'] == true,
          orElse: () => list.first,
        );

        setState(() {
          if (addr['recipient_name'] != null && addr['recipient_name'].toString().isNotEmpty) {
            _nameCtrl.text = addr['recipient_name'];
          }
          if (addr['phone'] != null && addr['phone'].toString().isNotEmpty) {
            _phoneCtrl.text = addr['phone'];
          }
          _addressCtrl.text = addr['address_line'] ?? addr['address'] ?? '';
          _cityCtrl.text = addr['city'] ?? '';
          _provinceCtrl.text = addr['province'] ?? '';

          if (addr['latitude'] != null && addr['longitude'] != null) {
            final lat = double.tryParse(addr['latitude'].toString());
            final lng = double.tryParse(addr['longitude'].toString());
            if (lat != null && lng != null) {
              _selectedLatLng = LatLng(lat, lng);
              Future.delayed(const Duration(milliseconds: 500), () {
                if (mounted && _selectedLatLng != null) {
                  _mapController.move(_selectedLatLng!, 16);
                }
              });
            }
          }
        });

        if (_formKey.currentState != null) {
          _formKey.currentState!.validate();
        }
      }
    } catch (e) {
      debugPrint('Error loading address: $e');
    } finally {
      if (mounted) setState(() => _loadingAddress = false);
    }
  }

  Future<void> _useGPS() async {
    setState(() => _gpsLoading = true);
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) throw Exception('GPS tidak aktif.');

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          throw Exception('Izin lokasi ditolak.');
        }
      }

      if (permission == LocationPermission.deniedForever) {
        throw Exception('Izin lokasi diblokir permanen.');
      }

      Position position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(accuracy: LocationAccuracy.high),
      );

      final newLatLng = LatLng(position.latitude, position.longitude);

      if (!mounted) return;
      setState(() => _selectedLatLng = newLatLng);
      _mapController.move(newLatLng, 16);

      await _reverseGeocode(position.latitude, position.longitude);

    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('❌ Gagal mendapatkan lokasi: $e'), backgroundColor: dangerRed),
        );
      }
    } finally {
      if (mounted) setState(() => _gpsLoading = false);
    }
  }

  Future<void> _reverseGeocode(double lat, double lng) async {
    try {
      final uri = Uri.parse(
        'https://nominatim.openstreetmap.org/reverse?format=json&lat=$lat&lon=$lng&zoom=18&addressdetails=1',
      );

      final response = await http.get(
        uri,
        headers: {
          'Accept': 'application/json',
          'User-Agent': 'NusadhipaCustomerApp/1.0',
        },
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final address = data['address'] ?? {};

        String road = address['road'] ?? address['pedestrian'] ?? address['footway'] ?? '';
        String suburb = address['suburb'] ?? address['village'] ?? address['neighbourhood'] ?? '';
        String city = address['city'] ?? address['town'] ?? address['county'] ?? address['municipality'] ?? '';
        String state = address['state'] ?? '';
        String postcode = address['postcode'] ?? '';

        List<String> parts = [];
        if (road.isNotEmpty) parts.add(road);
        if (suburb.isNotEmpty) parts.add(suburb);
        if (city.isNotEmpty) parts.add(city);
        if (postcode.isNotEmpty) parts.add(postcode);

        if (mounted) {
          setState(() {
            if (parts.isNotEmpty) {
              _addressCtrl.text = '${parts.join(', ')}, ';
            } else {
              _addressCtrl.text = 'Lokasi GPS terdeteksi, ';
            }
            if (city.isNotEmpty) _cityCtrl.text = city;
            if (state.isNotEmpty) _provinceCtrl.text = state;
            
            if (_nameCtrl.text.isEmpty) _nameCtrl.text = 'Pelanggan';
            if (_phoneCtrl.text.isEmpty) _phoneCtrl.text = '08123456789';
          });

          if (_formKey.currentState != null) {
            _formKey.currentState!.validate();
          }

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('✅ Alamat dasar terisi. Silakan lengkapi nama komplek/no rumah.'),
              backgroundColor: successGreen,
            ),
          );
        }
      } else {
        throw Exception('API Nominatim error: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Reverse geocode error: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('⚠️ Gagal melengkapi alamat otomatis. Silakan isi manual.'),
            backgroundColor: Colors.orange,
          ),
        );
      }
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
        const SnackBar(content: Text('Pilih lokasi pengiriman di peta / GPS'), backgroundColor: Colors.orange),
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
          // Tutup halaman checkout dan kembalikan nilai true
          Navigator.pop(context, true);
        }
      } else {
        throw Exception(response['message'] ?? 'Gagal membuat pesanan');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: dangerRed),
        );
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bgColor,
      appBar: AppBar(
        title: const Text('Checkout', style: TextStyle(fontWeight: FontWeight.w800)),
        backgroundColor: _cardColor,
        foregroundColor: _textColor,
        elevation: 0,
      ),
      body: _loadingAddress
          ? const Center(child: CircularProgressIndicator(color: brandRed))
          : Form(
              key: _formKey,
              child: Column(
                children: [
                  Expanded(
                    child: ListView(
                      padding: const EdgeInsets.all(20),
                      children: [
                        const Text('Pilih Lokasi Pengiriman',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: Colors.white)),
                        const SizedBox(height: 12),
                        Container(
                          height: 220,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: _borderColor),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.3),
                                blurRadius: 10,
                                offset: const Offset(0, 5),
                              ),
                            ],
                          ),
                          clipBehavior: Clip.antiAlias,
                          child: Stack(
                            children: [
                              FlutterMap(
                                mapController: _mapController,
                                options: MapOptions(
                                  initialCenter: _selectedLatLng ?? const LatLng(-6.2, 106.816),
                                  initialZoom: 13,
                                  onTap: (tapPosition, point) =>
                                      setState(() => _selectedLatLng = point),
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
                                          child: const Icon(Icons.location_pin,
                                              color: brandRed, size: 40),
                                        ),
                                      ],
                                    ),
                                ],
                              ),
                              Positioned(
                                bottom: 12,
                                right: 12,
                                child: Material(
                                  color: Colors.black.withValues(alpha: 0.7),
                                  borderRadius: BorderRadius.circular(30),
                                  child: InkWell(
                                    borderRadius: BorderRadius.circular(30),
                                    onTap: _gpsLoading ? null : _useGPS,
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 16, vertical: 10),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          _gpsLoading
                                              ? const SizedBox(
                                                  width: 16,
                                                  height: 16,
                                                  child: CircularProgressIndicator(
                                                      strokeWidth: 2, color: brandRed),
                                                )
                                              : const Icon(Icons.my_location,
                                                  color: brandRed, size: 18),
                                          const SizedBox(width: 8),
                                          const Text('Gunakan GPS',
                                              style: TextStyle(
                                                  fontSize: 13,
                                                  fontWeight: FontWeight.w700,
                                                  color: Colors.white)),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _selectedLatLng == null
                              ? 'Ketuk peta untuk menentukan titik lokasi'
                              : 'Titik terpilih: ${_selectedLatLng!.latitude.toStringAsFixed(5)}, ${_selectedLatLng!.longitude.toStringAsFixed(5)}',
                          style: TextStyle(fontSize: 11, color: _subTextColor),
                          textAlign: TextAlign.center,
                        ),

                        const SizedBox(height: 24),
                        const Text('Alamat Pengiriman',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: Colors.white)),
                        const SizedBox(height: 12),
                        _buildField(_nameCtrl, 'Nama Penerima', Icons.person),
                        _buildField(_phoneCtrl, 'No. Telepon', Icons.phone, keyboardType: TextInputType.phone),
                        _buildField(_addressCtrl, 'Alamat Lengkap (Sertakan Komplek/RT/RW)', Icons.location_on, maxLines: 3),
                        _buildField(_cityCtrl, 'Kota / Kabupaten', Icons.location_city),
                        _buildField(_provinceCtrl, 'Provinsi', Icons.map),

                        const SizedBox(height: 24),
                        const Text('Pilih Kurir',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: Colors.white)),
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.symmetric(vertical: 4),
                          decoration: BoxDecoration(
                            color: brandRed.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: brandRed.withValues(alpha: 0.5)),
                          ),
                          child: const ListTile(
                            leading: Icon(Icons.check_circle, color: brandRed),
                            title: Text('NUSA-DHIPA',
                                style: TextStyle(
                                    fontWeight: FontWeight.w800, color: Colors.white)),
                            subtitle: Text('Instant / Same Day (Wajib)',
                                style: TextStyle(color: Colors.white70, fontSize: 12)),
                          ),
                        ),

                        const SizedBox(height: 24),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Total Berat',
                                style: TextStyle(fontSize: 13, color: Colors.white70)),
                            Text('${_totalWeightKg.toStringAsFixed(2)} kg',
                                style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w800,
                                    color: Colors.white)),
                          ],
                        ),
                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                  
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: _cardColor,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.2),
                          blurRadius: 10,
                          offset: const Offset(0, -5),
                        ),
                      ],
                    ),
                    child: SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton(
                        onPressed: _loading ? null : _submitOrder,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: brandRed,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14)),
                          elevation: 0,
                        ),
                        child: _loading
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                    color: Colors.white, strokeWidth: 2))
                            : const Text('Buat Pesanan',
                                style: TextStyle(
                                    fontSize: 16, fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildField(TextEditingController ctrl, String label, IconData icon,
      {int maxLines = 1, TextInputType? keyboardType}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Focus(
        onFocusChange: (hasFocus) {
          setState(() {}); 
        },
        child: TextFormField(
          controller: ctrl,
          maxLines: maxLines,
          keyboardType: keyboardType,
          style: const TextStyle(color: Colors.white, fontSize: 14),
          decoration: InputDecoration(
            labelText: label,
            labelStyle: TextStyle(color: _subTextColor),
            prefixIcon: Icon(icon, color: brandRed, size: 20),
            filled: true,
            fillColor: _cardColor,
            border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none),
            enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: _borderColor)),
            focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: brandRed, width: 2)),
          ),
          validator: (v) => (v == null || v.isEmpty) ? 'Wajib diisi' : null,
        ),
      ),
    );
  }
}