import 'package:flutter/material.dart';
import '../../config/theme.dart';
import '../../widgets/heading.dart';
import 'tracking_screen.dart';

class OrdersScreen extends StatelessWidget {
  const OrdersScreen({super.key});

  final List<Order> orders = const [
    Order(
      id: 'ORD-2026-10-001', date: '17 Okt 2026', status: 'Dikirim',
      statusColor: Color(0xFFE5232E), items: 2, total: 1350000,
      businessName: 'Fajar Florist', productName: 'Bunga Papan Custom',
      imageUrl: 'https://api.nusadhipa.shop/uploads/products/fajar-florist/20-papan-custom.jpg',
    ),
    Order(
      id: 'ORD-2026-10-002', date: '16 Okt 2026', status: 'Selesai',
      statusColor: Color(0xFF1A1A1A), items: 3, total: 144000,
      businessName: 'PT SAURI', productName: 'Boneless Dada + Test Ikan',
      imageUrl: 'https://api.nusadhipa.shop/sauri/SAURI_29_Foto_Produk_Cropped/01_boneless-dada.jpg',
    ),
    Order(
      id: 'ORD-2026-10-003', date: '15 Okt 2026', status: 'Menunggu Pembayaran',
      statusColor: Color(0xFFC41E28), items: 1, total: 500000,
      businessName: 'PT DIGI MEDIA KOMUNIKA', productName: 'AI Transformation Consulting',
      imageUrl: 'https://api.nusadhipa.shop/uploads/services/01_konsultasi_transformasi_ai.png',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          const Heading('Pesanan', 'Riwayat belanja Anda'),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: ['Semua', 'Aktif', 'Selesai'].asMap().entries.map((e) {
                final isActive = e.key == 0;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: isActive ? brandRed : Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: isActive ? brandRed : line),
                    ),
                    child: Text(e.value, style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: isActive ? Colors.white : ink)),
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 16),
          ...orders.map((order) => _buildOrderCard(context, order)),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildOrderCard(BuildContext context, Order order) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      child: Container(
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: line)),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  const Icon(Icons.receipt_long, color: brandRed, size: 16),
                  const SizedBox(width: 6),
                  Text(order.id, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(color: order.statusColor.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(6)),
                    child: Text(order.status, style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: order.statusColor)),
                  ),
                ],
              ),
            ),
            const Divider(height: 1, color: line),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Container(
                      width: 64, height: 64, color: Colors.grey.shade100,
                      child: Image.network(order.imageUrl, fit: BoxFit.cover, errorBuilder: (_, _, _) => const Icon(Icons.image_outlined, color: brandRed)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(order.productName, maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 4),
                        Row(children: [
                          const Icon(Icons.verified, color: brandRed, size: 10),
                          const SizedBox(width: 2),
                          Text(order.businessName, style: const TextStyle(fontSize: 9, color: muted)),
                        ]),
                        const SizedBox(height: 4),
                        Row(children: [
                          Text('${order.items} item', style: const TextStyle(fontSize: 10, color: muted)),
                          const Spacer(),
                          Text('Rp ${_formatRupiah(order.total)}', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w900, color: brandRed)),
                        ]),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const Divider(height: 1, color: line),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  Text(order.date, style: const TextStyle(fontSize: 10, color: muted)),
                  const Spacer(),
                  OutlinedButton(
                    onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => TrackingScreen(orderId: order.id))),
                    style: OutlinedButton.styleFrom(foregroundColor: brandRed, side: const BorderSide(color: brandRed), padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
                    child: const Text('Lacak', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatRupiah(int value) {
    return value.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.');
  }
}

class Order {
  final String id;
  final String date;
  final String status;
  final Color statusColor;
  final int items;
  final int total;
  final String businessName;
  final String productName;
  final String imageUrl;
  const Order({required this.id, required this.date, required this.status, required this.statusColor, required this.items, required this.total, required this.businessName, required this.productName, required this.imageUrl});
}
