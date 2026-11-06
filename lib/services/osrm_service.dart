import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';

class OsrmService {
  static Future<List<LatLng>> getRoute(LatLng pickup, LatLng dropoff) async {
    if (pickup.latitude == 0 && pickup.longitude == 0) {
      debugPrint('❌ Pickup koordinat kosong');
      return [];
    }
    if (dropoff.latitude == 0 && dropoff.longitude == 0) {
      debugPrint('❌ Dropoff koordinat kosong');
      return [];
    }

    final url = 'https://router.project-osrm.org/route/v1/driving/'
        '${pickup.longitude},${pickup.latitude};${dropoff.longitude},${dropoff.latitude}'
        '?overview=full&geometries=geojson';

    debugPrint('🔗 OSRM URL: $url');

    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final routes = data['routes'] as List?;
        if (routes != null && routes.isNotEmpty) {
          final coordinates = routes[0]['geometry']['coordinates'] as List;
          return coordinates
              .map((c) => LatLng(c[1].toDouble(), c[0].toDouble()))
              .toList();
        }
      }
    } catch (e) {
      debugPrint('Error OSRM: $e');
    }
    return [];
  }
}
