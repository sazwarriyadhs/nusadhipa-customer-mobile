/// Konfigurasi logistik NUSA-DHIPA
class DeliveryConfig {
  /// Radius gratis ongkir (km)
  static const double freeShippingRadiusKm = 5.0;

  /// Minimal berat order (kg)
  static const double minOrderWeightKg = 10.0;

  /// Ongkir per km di luar radius (Rp)
  static const double shippingCostPerKm = 2000.0;

  /// Ongkir dasar (Rp)
  static const double baseShippingCost = 5000.0;

  /// Hitung ongkir berdasarkan jarak
  static double calculateShippingCost(double distanceKm) {
    if (distanceKm <= freeShippingRadiusKm) {
      return 0; // Gratis
    }
    return baseShippingCost + (distanceKm - freeShippingRadiusKm) * shippingCostPerKm;
  }

  /// Cek apakah alamat masuk radius gratis
  static bool isFreeShipping(double distanceKm) {
    return distanceKm <= freeShippingRadiusKm;
  }

  /// Cek apakah order memenuhi minimal berat
  static bool meetsMinWeight(double totalWeightKg) {
    return totalWeightKg >= minOrderWeightKg;
  }
}