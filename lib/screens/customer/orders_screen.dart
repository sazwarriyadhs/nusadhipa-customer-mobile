import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../config/theme.dart';
import '../../models/order.dart';
import '../../services/api_service.dart';
import 'tracking_screen.dart';

class OrdersScreen extends StatefulWidget {
  const OrdersScreen({super.key});

  @override
  State<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> {
  List<Order> _orders = [];
  bool _loading = true;
  String _filter = 'Semua';

  @override
  void initState() {
    super.initState();
    _loadOrders();
  }

  // Fungsi ini dipanggil dari luar (CustomerShell) saat pindah tab
  void refreshFromShell() {
    if (mounted) {
      setState(() => _loading = true);
      // Beri jeda 1 detik agar backend selesai membuat pesanan
      Future.delayed(const Duration(seconds: 1), () {
        _loadOrders();
      });
    }
  }

  Future<void> _loadOrders() async {
    try {
      final orders = await ApiService().getOrders();
      if (mounted) {
        setState(() {
          _orders = orders;
          _loading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _loading = false);
    }
  }

  List<Order> get _filteredOrders {
    if (_filter == 'Semua') return _orders;
    if (_filter == 'Aktif') {
      return _orders
          .where((o) =>
              o.status == 'processing' ||
              o.status == 'shipped' ||
              o.status == 'pending')
          .toList();
    }
    return _orders
        .where((o) => o.status == 'completed' || o.status == 'delivered')
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text('Pesanan',
                      style: TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                          letterSpacing: -0.5)),
                  SizedBox(height: 4),
                  Text('Riwayat belanja Anda',
                      style: TextStyle(fontSize: 13, color: Colors.white54)),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              child: Row(
                children: [
                  _buildFilterChip('Semua'),
                  const SizedBox(width: 8),
                  _buildFilterChip('Aktif'),
                  const SizedBox(width: 8),
                  _buildFilterChip('Selesai'),
                ],
              ),
            ),
            Expanded(
              child: _loading
                  ? const Center(child: CircularProgressIndicator(color: brandRed))
                  : _filteredOrders.isEmpty
                      ? _buildEmptyState()
                      : RefreshIndicator(
                          color: brandRed,
                          backgroundColor: const Color(0xFF1E293B),
                          onRefresh: _loadOrders,
                          child: ListView.builder(
                            padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
                            itemCount: _filteredOrders.length,
                            itemBuilder: (context, index) {
                              final order = _filteredOrders[index];
                              return _buildOrderCard(order);
                            },
                          ),
                        ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChip(String label) {
    final isActive = _filter == label;
    return GestureDetector(
      onTap: () => setState(() => _filter = label),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: isActive ? brandRed : const Color(0xFF1E293B),
          borderRadius: BorderRadius.circular(30),
          border: Border.all(
            color: isActive ? brandRed : Colors.white24,
            width: 1.2,
          ),
          boxShadow: isActive
              ? [BoxShadow(color: brandRed.withValues(alpha: 0.4), blurRadius: 12, offset: const Offset(0, 4))]
              : [],
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: isActive ? FontWeight.w800 : FontWeight.w600,
            color: isActive ? Colors.white : Colors.white70,
          ),
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
            padding: const EdgeInsets.all(28),
            decoration: BoxDecoration(color: brandRed.withValues(alpha: 0.1), shape: BoxShape.circle),
            child: const Icon(Icons.receipt_long_outlined, size: 56, color: brandRed),
          ),
          const SizedBox(height: 24),
          const Text('Belum Ada Pesanan',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: Colors.white)),
          const SizedBox(height: 8),
          const Text('Yuk mulai belanja dari UMKM lokal!',
              style: TextStyle(fontSize: 13, color: Colors.white54)),
        ],
      ),
    );
  }

  Widget _buildOrderCard(Order order) {
    final statusColor = _getStatusColor(order.status);
    final statusText = order.statusLabel;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white24),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.2), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(order.orderNumber,
                  style: const TextStyle(fontSize: 11, color: Colors.white54, fontWeight: FontWeight.bold, letterSpacing: 0.5)),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: statusColor.withValues(alpha: 0.4)),
                ),
                child: Text(statusText, style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: statusColor)),
              ),
            ],
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 12),
            child: Divider(color: Colors.white12, height: 1),
          ),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(color: brandRed.withValues(alpha: 0.1), shape: BoxShape.circle),
                child: const Icon(Icons.storefront_rounded, color: brandRed, size: 16),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(order.buyerName,
                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white),
                    maxLines: 1, overflow: TextOverflow.ellipsis),
              ),
              Text('Rp ${NumberFormat('#,##0', 'id_ID').format(order.grandTotal)}',
                  style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w900, color: brandRed)),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Icons.calendar_today_rounded, size: 12, color: Colors.white54),
                  const SizedBox(width: 6),
                  Text(
                    order.placedAt != null ? DateFormat('dd MMM yyyy', 'id_ID').format(order.placedAt!) : '-',
                    style: const TextStyle(fontSize: 11, color: Colors.white54),
                  ),
                ],
              ),
              SizedBox(
                height: 32,
                child: OutlinedButton.icon(
                  onPressed: () => Navigator.push(context,
                      MaterialPageRoute(builder: (_) => TrackingScreen(orderId: order.publicId))),
                  icon: const Icon(Icons.near_me_rounded, size: 14),
                  label: const Text('Lacak', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: brandRed,
                    side: BorderSide(color: brandRed.withValues(alpha: 0.5)),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(String? status) {
    switch (status) {
      case 'pending': return Colors.orange;
      case 'processing': return Colors.blueAccent;
      case 'shipped': return Colors.purpleAccent;
      case 'delivered': return Colors.greenAccent;
      case 'completed': return Colors.greenAccent;
      case 'cancelled': return Colors.redAccent;
      default: return Colors.grey;
    }
  }
}