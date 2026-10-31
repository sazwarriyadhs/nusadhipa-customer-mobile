import 'package:flutter/foundation.dart'
    show kIsWeb, kDebugMode, debugPrint, defaultTargetPlatform, TargetPlatform;

class ApiConfig {
  /// ============================================================
  /// MODE: Ganti ke `true` untuk pakai PRODUCTION API
  ///       Ganti ke `false` untuk pakai LOCAL DEV
  /// ============================================================
  static const bool kUseProductionApi = bool.fromEnvironment(
    'USE_PROD',
    defaultValue: true,
  );

  /// Base URL PRODUCTION (Railway + Custom Domain)
  static const String _productionBaseUrl = 'https://api.nusadhipa.shop';

  /// ============================================================
  /// Base URL LOCAL DEV (per platform)
  /// ============================================================
  /// Web/Chrome
  static const String _webBaseUrl = 'http://127.0.0.1:4000';

  /// Android emulator (10.0.2.2 = localhost PC host)
  static const String _androidBaseUrl = 'http://10.0.2.2:4000';

  /// iOS Simulator / macOS / Linux / Windows
  static const String _otherBaseUrl = 'http://127.0.0.1:4000';

  /// Untuk device fisik, ganti ini dengan IP LAN PC
  /// Contoh: 'http://192.168.1.10:4000'
  static const String kDeviceBaseUrl = 'http://192.168.1.10:4000';

  /// ============================================================
  /// Base URL otomatis per platform
  /// ============================================================
  static String get kApiBaseUrl {
    final url = _buildBaseUrl();
    assert(
      !kUseProductionApi || url.startsWith('https://'),
      '⚠️ Production API harus HTTPS!',
    );
    return url;
  }

  static String _buildBaseUrl() {
    // Production mode
    if (kUseProductionApi) {
      return '$_productionBaseUrl/api/v1';
    }

    // Local dev mode — per platform
    if (kIsWeb) return '$_webBaseUrl/api/v1';
    if (defaultTargetPlatform == TargetPlatform.android) {
      return '$_androidBaseUrl/api/v1';
    }
    return '$_otherBaseUrl/api/v1';
  }

  static const int kTimeoutMs = 30000;  // 30 detik untuk production

  // ============================================================
  // Endpoint paths
  // ============================================================
  static const String kProducts = '/products';
  static const String kCategories = '/categories';
  static const String kAuthLogin = '/auth/login';
  static const String kAuthRegister = '/auth/register';
  static const String kBusinessMe = '/businesses/me';
  static const String kOrders = '/orders';
  static const String kShipments = '/shipments';
  static const String kReportFinancial = '/reports/financial';

  /// Resolve URL gambar — handle relative & absolute
  static String? resolveImageUrl(String? url) {
    if (url == null || url.isEmpty) return null;
    if (url.startsWith("http://") || url.startsWith("https://")) return url;

    // Base URL backend (tanpa /api/v1)
    final baseUrl = kApiBaseUrl.replaceAll(RegExp(r"/api/v\d+/?$"), "");

    // Handle path relatif
    return url.startsWith("/") ? "$baseUrl$url" : "$baseUrl/$url";
  }

  /// Helper untuk debug: print URL yang sedang dipakai
  static void printCurrentConfig() {
    if (!kDebugMode) return;
    debugPrint('🔧 ApiConfig: ${kUseProductionApi ? "PRODUCTION" : "LOCAL DEV"}');
    debugPrint('🔧 Base URL: $kApiBaseUrl');
  }
}
