import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';

class OsrmService {
  static Future<List<LatLng>> getRoute(LatLng pickup, LatLng dropoff) async {
    if (pickup.latitude == 0 || pickup.longitude == 0) {
      print('❌ Pickup koordinat kosong');
      return [];
    }
    if (dropoff.latitude == 0 || dropoff.longitude == 0) {
      print('❌ Dropoff koordinat kosong');
      return [];
    }

    // OSRM format: lng,lat;lng,lat
    final url = 'https://router.project-osrm.org/route/v1/driving/'
        '${pickup.longitude},${pickup.latitude};'
        '${dropoff.longitude},${dropoff.latitude}'
        '?geometries=geojson&overview=full';

    print('🔗 OSRM URL: $url');

    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['code'] == 'Ok' && data['routes'].isNotEmpty) {
          final coords = data['routes'][0]['geometry']['coordinates'] as List;
          return coords.map((c) => LatLng(c[1] as double, c[0] as double)).toList();
        }
      }
    } catch (e) {
      print('Error OSRM: $e');
    }
    return [];
  }
}
