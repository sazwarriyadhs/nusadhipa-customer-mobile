import 'package:flutter/material.dart';
import '../../config/theme.dart';

import '../../widgets/heading.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  final List<CartItem> items = [
    CartItem(
      name: 'Bunga Papan Custom',
      businessName: 'Fajar Florist',
      price: 1350000,
      quantity: 1,
      imageUrl: 'https://api.nusadhipa.shop/uploads/products/fajar-florist/20-papan-custom.jpg',
    ),
    CartItem(
      name: 'Boneless Dada',
      businessName: 'PT SAURI',
      price: 48000,
      quantity: 2,
      imageUrl: 'https://api.nusadhipa.shop/sauri/SAURI_29_Foto_Produk_Cropped/01_boneless-dada.jpg',
    ),
  ];

  int get total => items.fold(0, (sum, item) => sum + (item.price * item.quantity));
  int get totalItems => items.fold(0, (sum, item) => sum + item.quantity);

  void _removeItem(int index) => setState(() => items.removeAt(index));
  void _updateQuantity(int index, int delta) {
    setState(() {
      final newQty = items[index].quantity + delta;
      if (newQty > 0) items[index].quantity = newQty;
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        children: [
          const Heading('Keranjang', 'Produk yang akan dibeli'),
          if (items.isEmpty)
            Expanded(child: _buildEmptyState())
          else
            Expanded(child: _buildCartList()),
          if (items.isNotEmpty) _buildBottomBar(),
        ],
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
          const Text('Keranjang Kosong', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900)),
          const SizedBox(height: 8),
          const Text('Yuk mulai belanja dari UMKM lokal!', style: TextStyle(fontSize: 13, color: muted)),
        ],
      ),
    );
  }

  Widget _buildCartList() {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: line)),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Container(
                  width: 70, height: 70, color: Colors.grey.shade100,
                  child: Image.network(item.imageUrl, fit: BoxFit.cover, errorBuilder: (_, _, _) => const Icon(Icons.image_outlined, color: brandRed)),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(item.name, maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w900)),
                    const SizedBox(height: 4),
                    Row(children: [
                      const Icon(Icons.verified, color: brandRed, size: 11),
                      const SizedBox(width: 2),
                      Text(item.businessName, style: const TextStyle(fontSize: 10, color: muted)),
                    ]),
                    const SizedBox(height: 6),
                    Text('Rp ${_formatRupiah(item.price)}', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w900, color: brandRed)),
                  ],
                ),
              ),
              Column(
                children: [
                  IconButton(onPressed: () => _removeItem(index), icon: const Icon(Icons.delete_outline, color: Colors.red, size: 20)),
                  Container(
                    decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(8)),
                    child: Row(
                      children: [
                        IconButton(onPressed: () => _updateQuantity(index, -1), icon: const Icon(Icons.remove, size: 16), constraints: const BoxConstraints(minWidth: 28, minHeight: 28)),
                        Text('${item.quantity}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                        IconButton(onPressed: () => _updateQuantity(index, 1), icon: const Icon(Icons.add, size: 16), constraints: const BoxConstraints(minWidth: 28, minHeight: 28)),
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
        color: Colors.white,
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.08), blurRadius: 16, offset: const Offset(0, -4))],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Text('Total ($totalItems item)', style: const TextStyle(fontSize: 12, color: muted)),
              const Spacer(),
              Text('Rp ${_formatRupiah(total)}', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: brandRed)),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity, height: 50,
            child: ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(backgroundColor: brandRed, foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
              child: const Text('Checkout', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }

  String _formatRupiah(int value) {
    return value.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.');
  }
}

class CartItem {
  final String name;
  final String businessName;
  final int price;
  int quantity;
  final String imageUrl;
  CartItem({required this.name, required this.businessName, required this.price, required this.quantity, required this.imageUrl});
}

