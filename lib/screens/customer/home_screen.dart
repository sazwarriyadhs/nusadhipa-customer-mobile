import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../config/theme.dart';
import '../../models/product.dart';
import '../../services/api_service.dart';
import '../../services/auth_service.dart';
import '../../services/cart_badge.dart';
import '../../widgets/product_card.dart';
import '../../widgets/section_header.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/skeleton_loader.dart';
import 'product_detail_screen.dart';
import 'cart_screen.dart';
import 'all_products_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _searchCtrl = TextEditingController();
  final _scrollCtrl = ScrollController();

  List<Product> _products = [];
  List<Category> _categories = [];
  Map<String, dynamic> _wallet = {'balance': 0, 'points': 0};
  String _userName = 'Pelanggan';
  bool _loading = true;
  String _selectedCategory = '';
  String _searchQuery = '';
  double _scrollOffset = 0;

  @override
  void initState() {
    super.initState();
    _scrollCtrl.addListener(() {
      setState(() => _scrollOffset = _scrollCtrl.offset);
    });
    _loadData();
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    _scrollCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() => _loading = true);
    try {
      final results = await Future.wait([
        ApiService().getProducts(limit: 100),
        ApiService().getCategories(),
        ApiService().getWallet(),
        AuthService().getUser(),
      ]);

      final products = results[0] as List<Product>;
      final categories = results[1] as List<Category>;
      final wallet = results[2] as Map<String, dynamic>;
      final user = results[3] as Map<String, dynamic>?;

      final email = user?['email'] ?? '';
      final name = user?['fullName']
          ?? user?['full_name']
          ?? user?['name']
          ?? (email.contains('@') ? email.split('@')[0] : 'Pelanggan');

      if (mounted) {
        setState(() {
          _products = products;
          _categories = categories;
          _wallet = wallet;
          _userName = name.toString();
          _loading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _loading = false);
    }
  }

  List<Product> get _filteredProducts {
    var filtered = _products;
    if (_selectedCategory.isNotEmpty) {
      filtered = filtered.where((p) => p.categoryName == _selectedCategory).toList();
    }
    if (_searchQuery.isNotEmpty) {
      final q = _searchQuery.toLowerCase();
      filtered = filtered.where((p) => p.name.toLowerCase().contains(q)).toList();
    }
    return filtered;
  }

  Future<void> _quickAdd(Product product) async {
    try {
      await ApiService().addToCart(product.slug, 1);
      cartBadgeNotifier.value = cartBadgeNotifier.value + 1;
      if (!mounted) return;
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            content: Text('${product.name} ditambahkan ke keranjang'),
            duration: const Duration(seconds: 2),
            backgroundColor: successGreen,
          ),
        );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal menambahkan: $e'), backgroundColor: dangerRed),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(
        backgroundColor: canvas,
        body: HomeSkeleton(),
      );
    }

    return Scaffold(
      backgroundColor: canvas,
      body: RefreshIndicator(
        color: brandRed,
        onRefresh: _loadData,
        child: CustomScrollView(
          controller: _scrollCtrl,
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            SliverToBoxAdapter(child: _buildTopBar()),
            SliverToBoxAdapter(child: _buildHero()),
            SliverToBoxAdapter(child: _buildWalletCard()),
            SliverToBoxAdapter(
              child: SectionHeader(
                title: 'Kategori Pilihan',
                actionLabel: 'Lihat Semua',
                onAction: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const AllProductsScreen()),
                  );
                },
              ),
            ),
            SliverToBoxAdapter(child: _buildCategories()),
            SliverToBoxAdapter(
              child: SectionHeader(
                title: 'Produk Marketplace',
                actionLabel: '${_filteredProducts.length} produk',
              ),
            ),
            if (_filteredProducts.isEmpty)
              const SliverFillRemaining(
                hasScrollBody: false,
                child: EmptyState(
                  icon: Icons.search_off_rounded,
                  title: 'Produk tidak ditemukan',
                  subtitle: 'Coba ubah kata kunci atau pilih kategori lain',
                ),
              )
            else
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                sliver: SliverGrid(
                  gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                    maxCrossAxisExtent: 200,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 0.72,
                  ),
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final product = _filteredProducts[index];
                      return ProductCard(
                        product: product,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => ProductDetailScreen(slug: product.slug),
                            ),
                          );
                        },
                        onQuickAdd: () => _quickAdd(product),
                      );
                    },
                    childCount: _filteredProducts.length,
                  ),
                ),
              ),
            const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.huge)),
          ],
        ),
      ),
    );
  }

  Widget _buildTopBar() {
    return Container(
      color: Colors.white,
      padding: EdgeInsets.fromLTRB(
        AppSpacing.lg,
        MediaQuery.of(context).padding.top + AppSpacing.sm,
        AppSpacing.lg,
        AppSpacing.sm,
      ),
      child: Row(
        children: [
          Image.asset('assets/branding/logo_nusadhipa.png', height: 32, fit: BoxFit.contain),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Halo, $_userName',
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: ink,
                    letterSpacing: -0.2,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const Text(
                  'Mau belanja apa hari ini?',
                  style: TextStyle(fontSize: 11, color: muted),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.notifications_outlined, color: ink),
            visualDensity: VisualDensity.compact,
          ),
          ValueListenableBuilder<int>(
            valueListenable: cartBadgeNotifier,
            builder: (_, count, _) {
              return Stack(
                clipBehavior: Clip.none,
                children: [
                  IconButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const CartScreen()),
                      );
                    },
                    icon: const Icon(Icons.shopping_cart_outlined, color: ink),
                    visualDensity: VisualDensity.compact,
                  ),
                  if (count > 0)
                    Positioned(
                      top: 4,
                      right: 4,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                        decoration: BoxDecoration(
                          color: brandRed,
                          borderRadius: BorderRadius.circular(AppRadius.pill),
                          border: Border.all(color: Colors.white, width: 1.5),
                        ),
                        constraints: const BoxConstraints(minWidth: 16),
                        child: Text(
                          count > 99 ? '99+' : '$count',
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.w900,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildHero() {
    final parallax = _scrollOffset * 0.4;

    return Container(
      height: 200,
      margin: const EdgeInsets.fromLTRB(AppSpacing.lg, AppSpacing.sm, AppSpacing.lg, 0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppRadius.md),
        boxShadow: elevatedShadow,
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        fit: StackFit.expand,
        children: [
          Transform.translate(
            offset: Offset(0, -parallax),
            child: Transform.scale(
              scale: 1.15,
              child: Image.asset(
                'assets/branding/header_marketplace.jpg',
                fit: BoxFit.cover,
              ),
            ),
          ),
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black.withValues(alpha: 0.1),
                  Colors.black.withValues(alpha: 0.6),
                ],
              ),
            ),
          ),
          Positioned(
            left: AppSpacing.md,
            right: AppSpacing.md,
            top: AppSpacing.md,
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: gold,
                    borderRadius: BorderRadius.circular(AppRadius.pill),
                  ),
                  child: const Text(
                    'UMKM Pilihan',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                      letterSpacing: 0.3,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            left: AppSpacing.md,
            right: AppSpacing.md,
            bottom: AppSpacing.md,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Belanja Produk\nUMKM Nusantara',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                    height: 1.15,
                    letterSpacing: -0.3,
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                Container(
                  height: 46,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(AppRadius.pill),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x33000000),
                        blurRadius: 12,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                  child: TextField(
                    controller: _searchCtrl,
                    onChanged: (v) => setState(() => _searchQuery = v),
                    textInputAction: TextInputAction.search,
                    decoration: const InputDecoration(
                      hintText: 'Cari produk atau UMKM...',
                      hintStyle: TextStyle(fontSize: 13, color: muted),
                      prefixIcon: Icon(Icons.search_rounded, color: muted, size: 20),
                      filled: false,
                      border: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(vertical: 12),
                    ),
                    style: const TextStyle(fontSize: 13, color: ink),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWalletCard() {
    final currency = NumberFormat('#,##0', 'id_ID');
    final balance = _wallet['balance'] ?? 0;
    final points = _wallet['points'] ?? 0;

    return Container(
      margin: const EdgeInsets.fromLTRB(AppSpacing.lg, AppSpacing.md, AppSpacing.lg, 0),
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF1A1A2E), Color(0xFF16213E)],
        ),
        borderRadius: BorderRadius.circular(AppRadius.md),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF16213E).withValues(alpha: 0.3),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: _walletColumn(
              label: 'Saldo Nusadhipa',
              value: 'Rp ${currency.format(balance)}',
              icon: Icons.account_balance_wallet_rounded,
              color: gold,
            ),
          ),
          Container(width: 1, height: 40, color: Colors.white.withValues(alpha: 0.15)),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: _walletColumn(
              label: 'Poin Reward',
              value: '$points poin',
              icon: Icons.stars_rounded,
              color: Colors.amberAccent,
            ),
          ),
          const SizedBox(width: AppSpacing.xs),
          Material(
            color: gold,
            borderRadius: BorderRadius.circular(AppRadius.pill),
            child: InkWell(
              borderRadius: BorderRadius.circular(AppRadius.pill),
              onTap: () {},
              child: const Padding(
                padding: EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                child: Text(
                  'Top Up',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _walletColumn({
    required String label,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 13, color: color),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                color: Colors.white.withValues(alpha: 0.7),
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Text(
          value,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w900,
            color: Colors.white,
            letterSpacing: -0.3,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }

  Widget _buildCategories() {
    if (_categories.isEmpty) {
      return const SizedBox(height: 100);
    }

    return SizedBox(
      height: 100,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
        itemCount: _categories.length,
        separatorBuilder: (_, _) => const SizedBox(width: AppSpacing.sm),
        itemBuilder: (context, index) {
          final cat = _categories[index];
          final isActive = _selectedCategory == cat.name;

          return GestureDetector(
            onTap: () => setState(
              () => _selectedCategory = isActive ? '' : cat.name,
            ),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 84,
              padding: const EdgeInsets.symmetric(
                vertical: AppSpacing.sm,
                horizontal: AppSpacing.xs,
              ),
              decoration: BoxDecoration(
                color: isActive ? brandRed : Colors.white,
                borderRadius: BorderRadius.circular(AppRadius.md),
                border: Border.all(
                  color: isActive ? brandRed : line,
                  width: 1.2,
                ),
                boxShadow: isActive ? brandShadow : softShadow,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: isActive
                          ? Colors.white.withValues(alpha: 0.2)
                          : canvas,
                      borderRadius: BorderRadius.circular(AppRadius.xs),
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: cat.imageUrl != null && cat.imageUrl!.isNotEmpty
                        ? Image.network(
                            cat.imageUrl!,
                            fit: BoxFit.cover,
                            errorBuilder: (_, _, _) => Icon(
                              Icons.category_rounded,
                              color: isActive ? Colors.white : brandRed,
                              size: 22,
                            ),
                          )
                        : Icon(
                            Icons.category_rounded,
                            color: isActive ? Colors.white : brandRed,
                            size: 22,
                          ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    cat.name,
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: isActive ? Colors.white : ink,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}