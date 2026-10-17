import 'package:flutter/material.dart';
import '../config/theme.dart';
import '../services/api_service.dart';
import '../widgets/brand_header.dart';
import '../widgets/heading.dart';
import '../widgets/metric.dart';
import '../widgets/panel.dart';
import '../widgets/quick_action.dart';
import '../services/nav_service.dart';
import 'add_product_page.dart';
import 'market_insight_page.dart';
import 'documents/financial_report_page.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  bool loading = true;
  int totalProducts = 0;
  int totalCategories = 0;
  int totalSellers = 0;
  bool connected = false;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => loading = true);
    try {
      final products = await ApiService().getProducts(limit: 100);
      final categories = await ApiService().getCategories();
      final sellers = products.map((p) => p.businessName).toSet();

      if (!mounted) return;
      setState(() {
        totalProducts = products.length;
        totalCategories = categories.length;
        totalSellers = sellers.length;
        loading = false;
        connected = true;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        loading = false;
        connected = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) => RefreshIndicator(
        color: brandRed,
        onRefresh: _loadData,
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            const BrandHeader(),
            const Heading('Ringkasan bisnis', 'Data live dari marketplace'),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 1.55,
                children: [
                  Metric(
                    'Produk aktif',
                    loading ? '...' : '$totalProducts',
                    loading ? 'Memuat' : 'Live dari API',
                    Icons.inventory_2_outlined,
                    brandRed,
                  ),
                  Metric(
                    'Kategori',
                    loading ? '...' : '$totalCategories',
                    loading ? 'Memuat' : 'Live dari API',
                    Icons.category_outlined,
                    oceanBlue,
                  ),
                  Metric(
                    'Mitra usaha',
                    loading ? '...' : '$totalSellers',
                    loading ? 'Memuat' : 'Live dari API',
                    Icons.storefront_outlined,
                    orange,
                  ),
                  const Metric(
                    'Status server',
                    'OK',
                    'Terhubung',
                    Icons.cloud_done_outlined,
                    emeraldGreen,
                  ),
                ],
              ),
            ),

            // ===== Highlight Banner =====
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: brandGradient,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: brandRed.withValues(alpha: 0.35),
                      blurRadius: 22,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: const Icon(
                        Icons.workspace_premium_rounded,
                        color: Colors.white,
                        size: 28,
                      ),
                    ),
                    const SizedBox(width: 14),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'STATUS TOKO',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 9,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 1.2,
                            ),
                          ),
                          SizedBox(height: 3),
                          Text(
                            'Premium Partner',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 17,
                              fontWeight: FontWeight.w900,
                              letterSpacing: -0.3,
                            ),
                          ),
                          SizedBox(height: 2),
                          Text(
                            'Prioritas tampil di katalog',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 10,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Icon(
                      Icons.arrow_forward_rounded,
                      color: Colors.white,
                      size: 22,
                    ),
                  ],
                ),
              ),
            ),

            const Heading('Akses cepat', 'Kelola bisnis dari satu aplikasi'),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Panel(
                child: Column(
                  children: [
                    QuickAction(
                      Icons.add_box_outlined,
                      'Tambah produk',
                      'Buat produk baru untuk katalog',
                      () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => const AddProductPage(),
                          ),
                        );
                      },
                    ),
                    const Divider(color: line),
                    QuickAction(
                      Icons.receipt_long_outlined,
                      'Kelola pesanan',
                      'Buka tab Pesanan',
                      () => NavService.switchTab(1),
                    ),
                    const Divider(color: line),
                    QuickAction(
                      Icons.palette_outlined,
                      'Branding toko',
                      'Logo, cover, dan identitas bisnis',
                      () => NavService.switchTab(4),
                    ),
                    const Divider(color: line),
                    QuickAction(
                      Icons.assessment_outlined,
                      'Laporan Keuangan',
                      'Ringkasan pendapatan & transaksi',
                      () async {
                        // Ambil business dulu
                        final business =
                            await ApiService().getMyBusiness();
                        if (!context.mounted) return;
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => FinancialReportPage(
                              business: business,
                            ),
                          ),
                        );
                      },
                    ),
                    const Divider(color: line),
                    QuickAction(
                      Icons.insights_outlined,
                      'Market insight',
                      'Harga pangan & ikan terkini',
                      () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => const MarketInsightPage(),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),

            const Heading('Insight pasar', 'Pantau harga komoditas terkini'),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  Expanded(
                    child: _InsightCard(
                      icon: '🍚',
                      label: 'Beras Medium',
                      value: 'Rp 14.012',
                      trend: '-0.5%',
                      trendUp: false,
                    ),
                  ),
                  SizedBox(width: 10),
                  Expanded(
                    child: _InsightCard(
                      icon: '🐟',
                      label: 'Ikan Tongkol',
                      value: 'Rp 40.449',
                      trend: '+1.2%',
                      trendUp: true,
                    ),
                  ),
                ],
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(20),
              child: Text(
                connected
                    ? 'LIVE — Terhubung ke marketplace API (port 4000).'
                    : 'OFFLINE — Tidak dapat terhubung ke server.',
                style: TextStyle(
                  color: connected ? emeraldGreen : brandRed,
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  height: 1.5,
                ),
              ),
            ),
          ],
        ),
      );
}

class _InsightCard extends StatelessWidget {
  final String icon;
  final String label;
  final String value;
  final String trend;
  final bool trendUp;

  const _InsightCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.trend,
    required this.trendUp,
  });

  @override
  Widget build(BuildContext context) {
    final trendColor = trendUp ? emeraldGreen : brandRed;

    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFFE5232E),
            Color(0xFFC41E28),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: brandRed.withValues(alpha: 0.35),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Decorative circle (pojok kanan atas)
          Positioned(
            right: -20,
            top: -20,
            child: Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.08),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Positioned(
            right: 20,
            bottom: -30,
            child: Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.05),
                shape: BoxShape.circle,
              ),
            ),
          ),
          // Content
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 14, 12, 14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        icon,
                        style: const TextStyle(fontSize: 22),
                      ),
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        trend,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 9,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                    letterSpacing: -1,
                    height: 1.1,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 10,
                    color: Colors.white.withValues(alpha: 0.85),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}