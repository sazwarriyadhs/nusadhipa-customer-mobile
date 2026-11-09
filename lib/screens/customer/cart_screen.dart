import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../config/theme.dart';
import '../../services/api_service.dart';
import '../../services/cart_badge.dart';
import 'checkout_screen.dart';
import 'customer_shell.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  final ApiService _api = ApiService();
  final NumberFormat _currencyFormat = NumberFormat('#,##0', 'id_ID');

  List<dynamic> _cartItems = [];
  final Set<String> _busyItemIds = {};

  bool _loading = true;
  bool _checkoutLoading = false;
  String? _errorMessage;

  // Dark Theme Colors
  final Color _bgColor = const Color(0xFF0F172A);
  final Color _cardColor = const Color(0xFF1E293B);
  final Color _textColor = Colors.white;
  final Color _subTextColor = Colors.white70;
  final Color _borderColor = Colors.white24;

  @override
  void initState() {
    super.initState();
    _loadCart();
  }

  int _toInt(dynamic value, {int fallback = 0}) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    if (value is String) {
      final parsed = num.tryParse(value.trim());
      return parsed?.toInt() ?? fallback;
    }
    return fallback;
  }

  double _toDouble(dynamic value, {double fallback = 0}) {
    if (value is num) return value.toDouble();
    if (value is String) {
      final parsed = num.tryParse(value.trim());
      return parsed?.toDouble() ?? fallback;
    }
    return fallback;
  }

  String _itemKey(dynamic id) => id?.toString() ?? '';

  int _quantity(dynamic item) {
    if (item is! Map) return 0;
    return _toInt(item['quantity'], fallback: 0);
  }

  double _price(dynamic item) {
    if (item is! Map) return 0;
    return _toDouble(
      item['price'] ?? item['unit_price'] ?? item['selling_price'],
    );
  }

  int get _totalItems {
    return _cartItems.fold<int>(0, (sum, item) => sum + _quantity(item));
  }

  double get _totalPrice {
    return _cartItems.fold<double>(
      0,
      (sum, item) => sum + (_price(item) * _quantity(item)),
    );
  }

  bool get _hasBusyItems => _busyItemIds.isNotEmpty;

  Future<void> _loadCart({bool showLoading = true}) async {
    if (showLoading && mounted) {
      setState(() {
        _loading = true;
        _errorMessage = null;
      });
    }

    try {
      final items = await _api.getCart();
      if (!mounted) return;

      setState(() {
        _cartItems = items;
        _loading = false;
        _errorMessage = null;
      });
      
      // Update badge global
      cartBadgeNotifier.value = _cartItems.fold<int>(0, (sum, item) => sum + _quantity(item));
      
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _errorMessage = e.toString();
      });
    }
  }

  void _showMessage(String message, {bool isError = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: isError ? dangerRed : successGreen,
          behavior: SnackBarBehavior.floating,
        ),
      );
  }

  Future<void> _removeItem(dynamic cartItemId) async {
    final key = _itemKey(cartItemId);
    if (key.isEmpty || _busyItemIds.contains(key)) return;

    setState(() => _busyItemIds.add(key));

    try {
      await _api.removeFromCart(cartItemId);
      if (!mounted) return;

      setState(() {
        _cartItems.removeWhere((item) => _itemKey(item['id']) == key);
      });
      _showMessage('Produk berhasil dihapus.');
      _loadCart(showLoading: false); // Refresh badge & total
    } catch (e) {
      _showMessage('Gagal menghapus produk: $e', isError: true);
      await _loadCart(showLoading: false);
    } finally {
      if (mounted) setState(() => _busyItemIds.remove(key));
    }
  }

  Future<void> _changeQuantity(Map item, int newQuantity) async {
    final cartItemId = item['id'];
    final key = _itemKey(cartItemId);
    final oldQuantity = _quantity(item);

    if (key.isEmpty || _busyItemIds.contains(key)) return;
    if (newQuantity < 1) {
      await _removeItem(cartItemId);
      return;
    }
    if (newQuantity == oldQuantity) return;

    setState(() => _busyItemIds.add(key));

    try {
      await _api.updateCartItem(cartItemId, newQuantity);
      if (!mounted) return;
      await _loadCart(showLoading: false);
    } catch (e) {
      if (mounted) {
        _showMessage('Gagal memperbarui jumlah: ${e.toString()}', isError: true);
        await _loadCart(showLoading: false);
      }
    } finally {
      if (mounted) setState(() => _busyItemIds.remove(key));
    }
  }

  Future<void> _openCheckout() async {
    if (_loading || _checkoutLoading || _hasBusyItems || _cartItems.isEmpty) {
      return;
    }

    setState(() => _checkoutLoading = true);

    try {
      final result = await Navigator.push<bool>(
        context,
        MaterialPageRoute(
          builder: (_) => CheckoutScreen(cartItems: List<dynamic>.from(_cartItems)),
        ),
      );

      if (!mounted) return;

      if (result == true) {
        // 1. Paksa kosongkan list lokal keranjang saat itu juga agar UI langsung berubah
        setState(() {
          _cartItems.clear(); 
        });

        // 2. Paksa badge cart jadi 0
        cartBadgeNotifier.value = 0;

        // 3. Pindah ke Tab Pesanan (Index 2)
        customerShellKey.currentState?.changeTab(2);

        // 4. Tarik data terbaru dari API di belakang layar
        Future.delayed(const Duration(milliseconds: 500), () {
          if (mounted) _loadCart();
        });
      }
    } catch (e) {
      _showMessage('Gagal membuka checkout: $e', isError: true);
    } finally {
      if (mounted) setState(() => _checkoutLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bgColor,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            if (_loading)
              const Expanded(child: Center(child: CircularProgressIndicator(color: brandRed)))
            else if (_cartItems.isEmpty && _errorMessage != null)
              Expanded(child: _buildErrorState())
            else if (_cartItems.isEmpty)
              Expanded(child: _buildEmptyState())
            else
              Expanded(child: _buildCartList()),
            if (!_loading && _cartItems.isNotEmpty) _buildBottomBar(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 14),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text('Keranjang', style: TextStyle(fontSize: 26, fontWeight: FontWeight.w900, color: Colors.white, letterSpacing: -0.5)),
                SizedBox(height: 4),
                Text('Produk yang akan dibeli', style: TextStyle(fontSize: 13, color: Colors.white54)),
              ],
            ),
          ),
          IconButton(
            tooltip: 'Muat ulang keranjang',
            onPressed: _loading ? null : () => _loadCart(),
            icon: const Icon(Icons.refresh, color: Colors.white),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(28),
              decoration: BoxDecoration(color: brandRed.withValues(alpha: 0.1), shape: BoxShape.circle),
              child: const Icon(Icons.shopping_cart_outlined, size: 56, color: brandRed),
            ),
            const SizedBox(height: 24),
            const Text('Keranjang Kosong', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: Colors.white)),
            const SizedBox(height: 8),
            const Text('Yuk mulai belanja dari UMKM lokal!', textAlign: TextAlign.center, style: TextStyle(fontSize: 13, color: Colors.white54)),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.cloud_off_outlined, size: 60, color: Colors.orangeAccent),
            const SizedBox(height: 16),
            const Text('Keranjang gagal dimuat', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            Text(_errorMessage ?? 'Terjadi kesalahan.', textAlign: TextAlign.center, style: const TextStyle(color: Colors.white54, fontSize: 12)),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: () => _loadCart(),
              icon: const Icon(Icons.refresh),
              label: const Text('Coba lagi'),
              style: ElevatedButton.styleFrom(backgroundColor: brandRed, foregroundColor: Colors.white),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCartList() {
    return RefreshIndicator(
      color: brandRed,
      onRefresh: () => _loadCart(showLoading: false),
      child: ListView.builder(
        padding: const EdgeInsets.fromLTRB(20, 4, 20, 20),
        itemCount: _cartItems.length,
        itemBuilder: (context, index) {
          final rawItem = _cartItems[index];
          if (rawItem is! Map) return const SizedBox.shrink();

          final item = rawItem;
          final price = _price(item);
          final qty = _quantity(item);
          final name = (item['product_name'] ?? item['name'] ?? item['variant_name'] ?? 'Produk').toString();
          final businessName = (item['business_name'] ?? 'UMKM').toString();
          final cartId = item['id'];
          final key = _itemKey(cartId);
          final busy = _busyItemIds.contains(key);

          return Container(
            margin: const EdgeInsets.only(bottom: 16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: _cardColor,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: _borderColor),
              boxShadow: [
                BoxShadow(color: Colors.black.withValues(alpha: 0.2), blurRadius: 10, offset: const Offset(0, 4)),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Image
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Container(
                        width: 70,
                        height: 70,
                        color: Colors.black26,
                        child: item['image_url'] != null
                            ? Image.network(item['image_url'], fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) => const Icon(Icons.image_outlined, color: Colors.white30, size: 30))
                            : const Icon(Icons.image_outlined, color: Colors.white30, size: 30),
                      ),
                    ),
                    const SizedBox(width: 14),
                    // Info
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(name, maxLines: 2, overflow: TextOverflow.ellipsis,
                              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: Colors.white)),
                          const SizedBox(height: 6),
                          Row(
                            children: [
                              const Icon(Icons.storefront, color: brandRed, size: 14),
                              const SizedBox(width: 4),
                              Expanded(child: Text(businessName, maxLines: 1, overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(fontSize: 11, color: Colors.white54))),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text('Rp ${_currencyFormat.format(price)}',
                              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w900, color: brandRed)),
                        ],
                      ),
                    ),
                    // Delete
                    IconButton(
                      onPressed: busy || cartId == null ? null : () => _removeItem(cartId),
                      icon: const Icon(Icons.delete_outline, color: Colors.redAccent, size: 20),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                const Divider(color: Colors.white12, height: 1),
                const SizedBox(height: 12),
                // Qty Control
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Jumlah', style: TextStyle(fontSize: 12, color: Colors.white54)),
                    Container(
                      decoration: BoxDecoration(color: Colors.black26, borderRadius: BorderRadius.circular(20)),
                      child: Row(
                        children: [
                          _quantityButton(icon: Icons.remove, enabled: !busy && qty > 1, onPressed: () => _changeQuantity(item, qty - 1)),
                          SizedBox(
                            width: 32,
                            child: Center(
                              child: busy
                                  ? const SizedBox(width: 14, height: 14, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                                  : Text('$qty', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.white)),
                            ),
                          ),
                          _quantityButton(icon: Icons.add, enabled: !busy && qty > 0, onPressed: () => _changeQuantity(item, qty + 1)),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _quantityButton({required IconData icon, required bool enabled, required VoidCallback onPressed}) {
    return IconButton(
      onPressed: enabled ? onPressed : null,
      icon: Icon(icon, size: 16, color: enabled ? Colors.white : Colors.white30),
      constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
      padding: EdgeInsets.zero,
      visualDensity: VisualDensity.compact,
    );
  }

  Widget _buildBottomBar() {
    final canCheckout = !_loading && !_checkoutLoading && !_hasBusyItems && _cartItems.isNotEmpty;

    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
      decoration: BoxDecoration(
        color: _cardColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.4), blurRadius: 20, offset: const Offset(0, -5))],
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Text('Total ($_totalItems item)', style: const TextStyle(fontSize: 13, color: Colors.white70)),
                const Spacer(),
                Text('Rp ${_currencyFormat.format(_totalPrice)}',
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: brandRed)),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: canCheckout ? _openCheckout : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: brandRed,
                  disabledBackgroundColor: Colors.grey.shade800,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  elevation: 0,
                ),
                child: _checkoutLoading
                    ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                    : const Text('Checkout', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}