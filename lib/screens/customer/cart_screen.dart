import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../config/theme.dart';
import '../../widgets/heading.dart';
import '../../services/api_service.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  List<dynamic> _cartItems = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadCart();
  }

  Future<void> _loadCart() async {
    setState(() => _loading = true);
    try {
      final items = await ApiService().getCart();
      if (mounted) {
        setState(() {
          _cartItems = items;
          _loading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _removeItem(dynamic cartItemId) async {
    try {
      await ApiService().removeFromCart(cartItemId);
      _loadCart(); // Refresh
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal menghapus: $e')),
        );
      }
    }
  }

  int get _totalItems => _cartItems.fold(0, (sum, item) => sum + ((item['quantity'] as num?)?.toInt() ?? 0));
  int get _totalPrice => _cartItems.fold(0, (sum, item) => sum + (((item['price'] as num?)?.toInt() ?? 0) * ((item['quantity'] as num?)?.toInt() ?? 0)));

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F172A), // Navy gelap
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Keranjang', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white)),
                  SizedBox(height: 4),
                  Text('Produk yang akan dibeli', style: TextStyle(fontSize: 14, color: Colors.white70)),
                ],
              ),
            ),
            if (_loading)
              const Expanded(child: Center(child: CircularProgressIndicator(color: brandRed)))
            else if (_cartItems.isEmpty)
              Expanded(child: _buildEmptyState())
            else
              Expanded(child: _buildCartList()),
            if (_cartItems.isNotEmpty) _buildBottomBar(),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(color: brandRed.withValues(alpha: 0.1), shape: BoxShape.circle),
            child: const Icon(Icons.shopping_cart_outlined, size: 64, color: brandRed),
          ),
          const SizedBox(height: 24),
          const Text('Keranjang Kosong', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: Colors.white)),
          const SizedBox(height: 8),
          const Text('Yuk mulai belanja dari UMKM lokal!', style: TextStyle(fontSize: 13, color: Colors.white70)),
        ],
      ),
    );
  }

  Widget _buildCartList() {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: _cartItems.length,
      itemBuilder: (context, index) {
        final item = _cartItems[index];
        final price = item['price'] ?? 0;
        final qty = item['quantity'] ?? 1;
        final imageUrl = item['image_url'] ?? '';
        final name = item['product_name'] ?? item['name'] ?? 'Produk';
        final businessName = item['business_name'] ?? 'UMKM';
        final cartId = item['id'];

        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: const Color(0xFF1E293B),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
          ),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Container(
                  width: 70, height: 70, color: Colors.grey.shade800,
                  child: Image.network(
                    imageUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (_, _, _) => const Icon(Icons.image_outlined, color: Colors.white54),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(name, maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w900, color: Colors.white)),
                    const SizedBox(height: 4),
                    Row(children: [
                      const Icon(Icons.verified, color: brandRed, size: 11),
                      const SizedBox(width: 2),
                      Text(businessName, style: const TextStyle(fontSize: 10, color: Colors.white70)),
                    ]),
                    const SizedBox(height: 6),
                    Text('Rp ${NumberFormat('#,##0', 'id_ID').format(price)}', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w900, color: Colors.greenAccent)),
                  ],
                ),
              ),
              Column(
                children: [
                  IconButton(
                    onPressed: () => _removeItem(cartId),
                    icon: const Icon(Icons.delete_outline, color: Colors.redAccent, size: 20),
                  ),
                  Container(
                    decoration: BoxDecoration(color: Colors.black26, borderRadius: BorderRadius.circular(8)),
                    child: Row(
                      children: [
                        IconButton(
                          onPressed: () {}, // Nanti sesuaikan dengan API update quantity
                          icon: const Icon(Icons.remove, size: 16, color: Colors.white),
                          constraints: const BoxConstraints(minWidth: 28, minHeight: 28),
                        ),
                        Text('$qty', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.white)),
                        IconButton(
                          onPressed: () {}, // Nanti sesuaikan dengan API update quantity
                          icon: const Icon(Icons.add, size: 16, color: Colors.white),
                          constraints: const BoxConstraints(minWidth: 28, minHeight: 28),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildBottomBar() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.3), blurRadius: 16, offset: const Offset(0, -4))],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Text('Total ($_totalItems item)', style: const TextStyle(fontSize: 12, color: Colors.white70)),
              const Spacer(),
              Text('Rp ${NumberFormat('#,##0', 'id_ID').format(_totalPrice)}', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: Colors.greenAccent)),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity, height: 50,
            child: ElevatedButton(
              onPressed: () {
                // TODO: Implementasi checkout ke API
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Fitur checkout akan segera hadir!')),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: brandRed,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text('Checkout', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }
}