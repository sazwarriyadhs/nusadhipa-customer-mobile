import 'package:flutter/material.dart';
import '../../config/theme.dart';
import '../../config/api_config.dart';
import '../../models/product.dart';
import '../../services/api_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Product> products = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    _loadProducts();
  }

  Future<void> _loadProducts() async {
    setState(() => loading = true);
    try {
      final result = await ApiService().getProducts(limit: 100);
      if (!mounted) return;
      setState(() {
        products = result;
        loading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: RefreshIndicator(
        color: brandRed,
        onRefresh: _loadProducts,
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            _buildHeaderTop(),
            _buildUserCard(),
            _buildJaminan(),
            _buildKategori12(),
            _buildMarketInsight(),
            _buildStatistik(),
            _buildProdukPilihan(),
            _buildPromoMitra(),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // 0. HEADER PUTIH — LOGO + CART
  // ============================================================
  Widget _buildHeaderTop() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      child: Row(
        children: [
          Image.asset(
            'assets/branding/logo_nusadhipa.png',
            height: 36,
            errorBuilder: (_, _, _) => const Text(
              'NUSA-DHIPA',
              style: TextStyle(
                color: brandRed,
                fontWeight: FontWeight.w900,
                fontSize: 16,
              ),
            ),
          ),
          const Spacer(),
          Stack(
            children: [
              IconButton(
                onPressed: () {},
                icon: const Icon(Icons.shopping_cart_outlined, color: ink, size: 24),
              ),
              Positioned(
                right: 6,
                top: 6,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: const BoxDecoration(color: brandRed, shape: BoxShape.circle),
                  child: const Text('2', style: TextStyle(color: Colors.white, fontSize: 8, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ============================================================
  // 1. USER CARD — GAMBAR COVER + HALO + NUSAPAY
  // ============================================================
  Widget _buildUserCard() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Stack(
          children: [
            // Gambar cover
            Positioned.fill(
              child: Image.asset(
                'assets/branding/header_marketplace.jpg',
                fit: BoxFit.cover,
                errorBuilder: (_, _, _) => Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [Color(0xFFE5232E), Color(0xFFC41E28)],
                    ),
                  ),
                ),
              ),
            ),
            // Gradient overlay
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.black.withValues(alpha: 0.4),
                      Colors.black.withValues(alpha: 0.7),
                    ],
                  ),
                ),
              ),
            ),
            // Content
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Row(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.3),
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 1.5),
                        ),
                        child: const Icon(Icons.person, color: Colors.white, size: 22),
                      ),
                      const SizedBox(width: 10),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Halo, Azwar Riyadh', style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold, shadows: [Shadow(blurRadius: 4, color: Colors.black54)])),
                            Text('Customer', style: TextStyle(color: Colors.white70, fontSize: 11)),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Divider(color: Colors.white.withValues(alpha: 0.3), height: 1),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Saldo NusaPay', style: TextStyle(color: Colors.white70, fontSize: 10)),
                            const SizedBox(height: 2),
                            const Text('Rp 1.250.000', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w900, shadows: [Shadow(blurRadius: 4, color: Colors.black54)])),
                            const SizedBox(height: 4),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.25),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: const Text('+ Top Up', style: TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold)),
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Nusa Poin', style: TextStyle(color: Colors.white70, fontSize: 10)),
                            const SizedBox(height: 2),
                            const Text('4.850 Poin', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w900, shadows: [Shadow(blurRadius: 4, color: Colors.black54)])),
                            const SizedBox(height: 4),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.25),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: const Text('Tukar Voucher', style: TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold)),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // 2. JAMINAN
  // ============================================================
  Widget _buildJaminan() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: brandRed.withValues(alpha: 0.2)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _jaminanItem(Icons.verified_user, 'UMKM\nTerverifikasi'),
            _jaminanItem(Icons.description, 'Legal'),
            _jaminanItem(Icons.people, 'Terhubung'),
          ],
        ),
      ),
    );
  }

  Widget _jaminanItem(IconData icon, String label) {
    return Column(
      children: [
        Icon(icon, color: brandRed, size: 22),
        const SizedBox(height: 4),
        Text(label, textAlign: TextAlign.center, style: const TextStyle(fontSize: 9, color: brandRed, fontWeight: FontWeight.bold)),
      ],
    );
  }

  // ============================================================
  // 3. 12 KATEGORI DENGAN GAMBAR
  // ============================================================
  Widget _buildKategori12() {
    final categories = [
      _Kategori('Kuliner', '01-makanan-minuman'),
      _Kategori('Pertanian', '02-pertanian-hasil-bumi'),
      _Kategori('Peternakan', '03-peternakan-daging-perikanan'),
      _Kategori('Petfood', '04-petfood-kebutuhan-hewan'),
      _Kategori('Fashion', '05-fashion-aksesori'),
      _Kategori('Kriya', '06-kerajinan-produk-kreatif'),
      _Kategori('Rumah', '07-rumah-tangga-perlengkapan'),
      _Kategori('Kecantikan', '08-kecantikan-perawatan-diri'),
      _Kategori('Florist', '09-tanaman-bunga-florist'),
      _Kategori('Elektronik', '10-elektronik-peralatan'),
      _Kategori('Jasa', '11-jasa-layanan-bisnis'),
      _Kategori('Industri', '12-industri-grosir-b2b'),
    ];

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text('12 KATEGORI', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w900, letterSpacing: 0.5)),
              const Spacer(),
              Text('Lihat semua →', style: TextStyle(fontSize: 10, color: brandRed, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 12),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 4,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
              childAspectRatio: 0.85,
            ),
            itemCount: categories.length,
            itemBuilder: (context, index) {
              final cat = categories[index];
              final imageUrl = 'https://nusadhipa.shop/kategori/${cat.slug}.png';
              return Column(
                children: [
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Image.network(
                        imageUrl,
                        fit: BoxFit.cover,
                        width: double.infinity,
                        errorBuilder: (_, _, _) => Container(
                          color: Colors.grey.shade100,
                          child: const Icon(Icons.category_outlined, color: brandRed),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(cat.name, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 9, fontWeight: FontWeight.bold)),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  // ============================================================
  // 4. MARKET INSIGHT
  // ============================================================
  Widget _buildMarketInsight() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: line),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('📊 MARKET INSIGHT', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w900, letterSpacing: 0.5)),
            const SizedBox(height: 4),
            const Text('Harga pangan realtime', style: TextStyle(fontSize: 10, color: muted)),
            const SizedBox(height: 12),
            _hargaItem('Beras Medium', 'Rp 12.850', '/kg', const Color(0xFF059669)),
            const SizedBox(height: 8),
            _hargaItem('Daging Sapi', 'Rp 142.500', '/kg', brandRed),
            const SizedBox(height: 8),
            _hargaItem('Cabai Merah', 'Rp 38.000', '/kg', const Color(0xFFF59E0B)),
          ],
        ),
      ),
    );
  }

  Widget _hargaItem(String label, String harga, String unit, Color color) {
    return Row(
      children: [
        Expanded(child: Text(label, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600))),
        Text(harga, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w900, color: color)),
        Text(unit, style: const TextStyle(fontSize: 9, color: muted)),
      ],
    );
  }

  // ============================================================
  // 5. STATISTIK
  // ============================================================
  Widget _buildStatistik() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFFE5232E), Color(0xFFC41E28)],
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('📈 EKOSISTEM NUSA-DHIPA', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w900, color: Colors.white70, letterSpacing: 0.5)),
            const SizedBox(height: 10),
            Row(
              children: [
                _statItem('90+', 'Produk'),
                const SizedBox(width: 16),
                _statItem('3+', 'Mitra'),
                const SizedBox(width: 16),
                _statItem('34', 'Pemasok'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _statItem(String value, String label) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(value, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: Colors.white)),
        Text(label, style: const TextStyle(fontSize: 9, color: Colors.white70)),
      ],
    );
  }

  // ============================================================
  // 6. PRODUK PILIHAN
  // ============================================================
  Widget _buildProdukPilihan() {
    final featured = products.take(4).toList();

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('⭐ PRODUK PILIHAN', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w900, letterSpacing: 0.5)),
          const SizedBox(height: 12),
          if (loading)
            const Center(child: CircularProgressIndicator(color: brandRed))
          else
            Column(children: featured.map((p) => _produkItem(p)).toList()),
        ],
      ),
    );
  }

  Widget _produkItem(Product product) {
    final imageUrl = ApiConfig.resolveImageUrl(product.imageUrl);
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: line),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Container(
              width: 60,
              height: 60,
              color: Colors.grey.shade100,
              child: imageUrl != null ? Image.network(imageUrl, fit: BoxFit.cover) : const Icon(Icons.image_outlined, color: brandRed),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(product.name, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                const SizedBox(height: 2),
                Row(
                  children: [
                    const Icon(Icons.verified, color: Color(0xFF059669), size: 10),
                    const SizedBox(width: 2),
                    Expanded(child: Text(product.businessName, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 8, color: muted))),
                  ],
                ),
                const SizedBox(height: 4),
                Text('Rp ${product.minPrice}', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w900, color: brandRed)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // 7. PROMO MITRA
  // ============================================================
  Widget _buildPromoMitra() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFFE5232E), Color(0xFFC41E28)],
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.store, color: Colors.white, size: 22),
                SizedBox(width: 8),
                Expanded(
                  child: Text('Jadi Mitra Bisnis NUSA-DHIPA', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w900, color: Colors.white)),
                ),
              ],
            ),
            const SizedBox(height: 6),
            const Text('Relaunch lebih cerdas, bisnis mudah berkembang', style: TextStyle(fontSize: 10, color: Colors.white70)),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8)),
              child: const Text('Pelajari Selengkapnya', style: TextStyle(color: brandRed, fontSize: 10, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }
}

class _Kategori {
  final String name;
  final String slug;
  _Kategori(this.name, this.slug);
}
