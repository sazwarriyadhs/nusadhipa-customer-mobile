import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../../config/theme.dart';

class TrackingScreen extends StatefulWidget {
  final String orderId;
  const TrackingScreen({super.key, required this.orderId});

  @override
  State<TrackingScreen> createState() => _TrackingScreenState();
}

class _TrackingScreenState extends State<TrackingScreen> {
  final MapController mapController = MapController();

  // Sample lokasi
  final LatLng storeLocation = const LatLng(-6.6041669, 106.8088693);
  final LatLng customerLocation = const LatLng(-6.5980000, 106.8050000);
  final LatLng courierLocation = const LatLng(-6.6005000, 106.8070000);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Lacak ${widget.orderId}'),
        backgroundColor: brandRed,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Stack(
        children: [
          // MAP
          FlutterMap(
            mapController: mapController,
            options: MapOptions(
              initialCenter: courierLocation,
              initialZoom: 15,
              minZoom: 10,
              maxZoom: 18,
              interactionOptions: const InteractionOptions(
                flags: InteractiveFlag.all & ~InteractiveFlag.rotate,
              ),
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.nusadhipa.customer',
                maxZoom: 19,
              ),
              PolylineLayer(
                polylines: [
                  Polyline(
                    points: [storeLocation, courierLocation, customerLocation],
                    strokeWidth: 4,
                    color: brandRed,
                    borderStrokeWidth: 1,
                    borderColor: Colors.white,
                  ),
                ],
              ),
              MarkerLayer(
                markers: [
                  _buildMarker(storeLocation, Icons.store, 'Toko', brandRed),
                  _buildMarker(courierLocation, Icons.delivery_dining, 'Kurir', const Color(0xFFF59E0B)),
                  _buildMarker(customerLocation, Icons.home, 'Rumah', Colors.black87),
                ],
              ),
            ],
          ),
          // BOTTOM CARD
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 16,
                    offset: const Offset(0, -4),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          gradient: brandGradient,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(Icons.delivery_dining, color: Colors.white, size: 24),
                      ),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Budi Santoso', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w900)),
                            SizedBox(height: 2),
                            Text('Kurir NUSA-DHIPA · Honda Vario', style: TextStyle(fontSize: 11, color: muted)),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: brandRed.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Row(
                          children: [
                            Icon(Icons.phone, color: brandRed, size: 16),
                            SizedBox(width: 4),
                            Text('Hubungi', style: TextStyle(fontSize: 11, color: brandRed, fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const Divider(height: 1, color: line),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      _statusItem(Icons.check_circle, 'Diterima', true),
                      Expanded(child: _statusLine(true)),
                      _statusItem(Icons.shopping_bag, 'Diproses', true),
                      Expanded(child: _statusLine(true)),
                      _statusItem(Icons.delivery_dining, 'Dikirim', true),
                      Expanded(child: _statusLine(false)),
                      _statusItem(Icons.home, 'Diterima', false),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: brandRed.withValues(alpha: 0.05),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: brandRed.withValues(alpha: 0.2)),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.access_time, color: brandRed, size: 20),
                        const SizedBox(width: 8),
                        const Expanded(
                          child: Text('Estimasi tiba dalam', style: TextStyle(fontSize: 12, color: muted)),
                        ),
                        const Text('15 menit', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: brandRed)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: OutlinedButton.icon(
                      onPressed: () {
                        mapController.move(courierLocation, 17);
                      },
                      icon: const Icon(Icons.gps_fixed, color: brandRed),
                      label: const Text('Fokus ke Kurir', style: TextStyle(color: brandRed, fontWeight: FontWeight.bold)),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: brandRed),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Marker _buildMarker(LatLng point, IconData icon, String label, Color color) {
    return Marker(
      point: point,
      width: 60,
      height: 60,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 2),
              boxShadow: [
                BoxShadow(color: color.withValues(alpha: 0.4), blurRadius: 8, offset: const Offset(0, 4)),
              ],
            ),
            child: Icon(icon, color: Colors.white, size: 20),
          ),
          const SizedBox(height: 2),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(4)),
            child: Text(label, style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: color)),
          ),
        ],
      ),
    );
  }

  Widget _statusItem(IconData icon, String label, bool done) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: done ? brandRed : Colors.grey.shade300,
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: Colors.white, size: 14),
        ),
        const SizedBox(height: 4),
        Text(label, style: TextStyle(fontSize: 9, color: done ? brandRed : muted, fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _statusLine(bool done) {
    return Container(
      height: 2,
      margin: const EdgeInsets.only(bottom: 18),
      decoration: BoxDecoration(color: done ? brandRed : Colors.grey.shade300),
    );
  }
}
