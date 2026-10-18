import 'package:flutter/material.dart';
import '../config/theme.dart';
import '../models/business.dart';

import 'demo_message.dart';

// ============================================================
// KBLI → Kategori Cover Image
// ============================================================
const Map<String, String> kbliToCover = {
  // 01 - Makanan & Minuman
  "56101": "01-makanan-minuman",
  "56102": "01-makanan-minuman",
  "56201": "01-makanan-minuman",
  
  // 03 - Peternakan, Daging, Perikanan
  "46322": "03-peternakan-daging-perikanan",
  "46325": "03-peternakan-daging-perikanan",
  "46205": "03-peternakan-daging-perikanan",
  "46311": "03-peternakan-daging-perikanan",
  "46319": "03-peternakan-daging-perikanan",
  "47211": "03-peternakan-daging-perikanan",
  "47212": "03-peternakan-daging-perikanan",
  
  // 04 - Petfood & Kebutuhan Hewan
  "47731": "04-petfood-kebutuhan-hewan",
  "47732": "04-petfood-kebutuhan-hewan",
  "47733": "04-petfood-kebutuhan-hewan",
  
  // 05 - Fashion & Aksesori
  "14111": "05-fashion-aksesori",
  "14112": "05-fashion-aksesori",
  "47511": "05-fashion-aksesori",
  "47512": "05-fashion-aksesori",
  "47711": "05-fashion-aksesori",
  
  // 06 - Kerajinan & Produk Kreatif
  "16101": "06-kerajinan-produk-kreatif",
  "16291": "06-kerajinan-produk-kreatif",
  "32901": "06-kerajinan-produk-kreatif",
  
  // 07 - Rumah Tangga & Perlengkapan
  "47531": "07-rumah-tangga-perlengkapan",
  "47532": "07-rumah-tangga-perlengkapan",
  "47781": "07-rumah-tangga-perlengkapan",
  
  // 08 - Kecantikan & Perawatan Diri
  "47721": "08-kecantikan-perawatan-diri",
  "47722": "08-kecantikan-perawatan-diri",
  "96011": "08-kecantikan-perawatan-diri",
  
  // 09 - Tanaman, Bunga & Florist
  "47761": "09-tanaman-bunga-florist",
  "47762": "09-tanaman-bunga-florist",
  "01301": "09-tanaman-bunga-florist",
  "01309": "09-tanaman-bunga-florist",
  
  // 10 - Elektronik & Peralatan
  "47411": "10-elektronik-peralatan",
  "47412": "10-elektronik-peralatan",
  "47413": "10-elektronik-peralatan",
  
  // 11 - Jasa & Layanan Bisnis
  "62010": "11-jasa-layanan-bisnis",
  "62020": "11-jasa-layanan-bisnis",
  "62900": "11-jasa-layanan-bisnis",
  "70201": "11-jasa-layanan-bisnis",
  "73100": "11-jasa-layanan-bisnis",
  
  // 12 - Industri, Grosir & B2B
  "46900": "12-industri-grosir-b2b",
};

String getCoverImageForBusiness(Business? business) {
  if (business == null) return "01-makanan-minuman";
  
  // 1. Cek dari kbli_code (kalau ada)
  final kbli = business.kbliCode;
  if (kbli != null && kbliToCover.containsKey(kbli)) {
    return kbliToCover[kbli]!;
  }
  
  // 2. Fallback: dari nama bisnis
  final name = business.businessName.toLowerCase();
  if (name.contains("bunga") || name.contains("florist")) {
    return "09-tanaman-bunga-florist";
  }
  if (name.contains("ayam") || name.contains("daging") || name.contains("ikan") || name.contains("unggas")) {
    return "03-peternakan-daging-perikanan";
  }
  if (name.contains("kucing") || name.contains("anjing") || name.contains("pet")) {
    return "04-petfood-kebutuhan-hewan";
  }
  if (name.contains("digital") || name.contains("media") || name.contains("teknologi") || name.contains("komunika")) {
    return "11-jasa-layanan-bisnis";
  }
  
  // 3. Default
  return "01-makanan-minuman";
}

class BrandHeader extends StatefulWidget {
  const BrandHeader({super.key});

  @override
  State<BrandHeader> createState() => _BrandHeaderState();
}

class _BrandHeaderState extends State<BrandHeader> {
  Business? business;
  bool loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final result = null /* TODO: fix getMyBusiness */;
      if (!mounted) return;
      setState(() {
        business = result;
        loading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // ===== TOP BAR PUTIH =====
        const _WhiteTopHeader(),

        // ===== COVER IMAGE =====
        _CoverImage(business: business),

        // ===== TENANT CARD (rapih, di bawah cover) =====
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
          child: _TenantCard(
            business: business,
            loading: loading,
          ),
        ),
      ],
    );
  }
}

// ============================================================
// TOP HEADER
// ============================================================
class _WhiteTopHeader extends StatelessWidget {
  const _WhiteTopHeader();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 10, 16, 12),
          child: Row(
            children: [
              Image.asset(
                'assets/branding/logo_nusadhipa.png',
                height: 36,
                fit: BoxFit.contain,
                errorBuilder: (_, _, _) => const Text(
                  'NUSA-DHIPA',
                  style: TextStyle(
                    color: brandRed,
                    fontWeight: FontWeight.w900,
                    fontSize: 16,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
              const Spacer(),
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: canvas,
                  shape: BoxShape.circle,
                  border: Border.all(color: line),
                ),
                child: IconButton(
                  padding: EdgeInsets.zero,
                  onPressed: () => demoMessage(
                      context, 'Notifikasi demo belum terhubung.'),
                  icon: const Icon(
                    Icons.notifications_none_rounded,
                    color: ink,
                    size: 20,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ============================================================
// COVER IMAGE
// ============================================================
class _CoverImage extends StatelessWidget {
  final Business? business;
  const _CoverImage({this.business});

  @override
  Widget build(BuildContext context) {
    final coverSlug = getCoverImageForBusiness(business);
    final coverUrl = 'https://nusadhipa.shop/kategori/$coverSlug.png';

    return SizedBox(
      height: 160,
      width: double.infinity,
      child: Image.network(
        coverUrl,
        fit: BoxFit.cover,
        errorBuilder: (_, _, _) => Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFFE5232E), Color(0xFFC41E28)],
            ),
          ),
          child: const Center(
            child: Icon(Icons.storefront, color: Colors.white, size: 48),
          ),
        ),
      ),
    );
  }
}

// ============================================================
// TENANT CARD — rapih, mirip card panel di Toko & Bisnis
// ============================================================
class _TenantCard extends StatelessWidget {
  final Business? business;
  final bool loading;

  const _TenantCard({this.business, required this.loading});

  @override
  Widget build(BuildContext context) {
    final name = business?.businessName ?? 'Toko Saya';
    final location = business?.locationDisplay ?? 'Lokasi belum diisi';
    final isVerified = business?.isVerified ?? false;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: line),
        boxShadow: [
          BoxShadow(
            color: brandRed.withValues(alpha: 0.06),
            blurRadius: 16,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Logo tenant
          Stack(
            children: [
              Container(
                width: 64,
                height: 64,
                padding: const EdgeInsets.all(5),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(color: line, width: 1.5),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(11),
                  child: business?.logoUrl != null
                      ? Image.network(
                          business!.logoUrl!.startsWith('http')
                              ? business!.logoUrl!
                              : 'https://api.nusadhipa.shop${business!.logoUrl}',
                          fit: BoxFit.contain,
                          errorBuilder: (_, _, _) => const Icon(
                            Icons.storefront,
                            color: brandRed,
                            size: 32,
                          ),
                        )
                      : const Icon(
                          Icons.storefront,
                          color: brandRed,
                          size: 32,
                        ),
                ),
              ),
              if (isVerified)
                Positioned(
                  right: -2,
                  bottom: -2,
                  child: Container(
                    padding: const EdgeInsets.all(3),
                    decoration: BoxDecoration(
                      gradient: brandGradient,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                    child: const Icon(
                      Icons.check,
                      color: Colors.white,
                      size: 10,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(width: 12),
          // Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Badge verifikasi
                if (isVerified)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      gradient: brandGradient,
                      borderRadius: BorderRadius.circular(999),
                      boxShadow: [
                        BoxShadow(
                          color: brandRed.withValues(alpha: 0.25),
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.verified,
                            color: Colors.white, size: 10),
                        SizedBox(width: 4),
                        Text(
                          'UMKM TERVERIFIKASI',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 8,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                const SizedBox(height: 6),
                // Nama toko
                Text(
                  loading ? 'Memuat...' : name,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: ink,
                    fontSize: 14,
                    fontWeight: FontWeight.w900,
                    letterSpacing: -0.3,
                    height: 1.2,
                  ),
                ),
                const SizedBox(height: 5),
                // Lokasi
                Row(
                  children: [
                    const Icon(Icons.location_on_outlined,
                        color: brandRed, size: 11),
                    const SizedBox(width: 3),
                    Flexible(
                      child: Text(
                        location,
                        style: const TextStyle(
                          color: muted,
                          fontSize: 10.5,
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

