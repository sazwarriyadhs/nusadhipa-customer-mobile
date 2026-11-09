import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../config/theme.dart';
import '../../services/cart_badge.dart';
import 'home_screen.dart';
import 'cart_screen.dart';
import 'orders_screen.dart';
import 'profile_screen.dart';

// KEY GLOBAL: Agar bisa dipanggil dari CartScreen
final GlobalKey<_CustomerShellState> customerShellKey = GlobalKey<_CustomerShellState>();

class CustomerShell extends StatefulWidget {
  const CustomerShell({super.key});

  @override
  State<CustomerShell> createState() => _CustomerShellState();
}

class _CustomerShellState extends State<CustomerShell> {
  int _index = 0;

  final _pages = const [
    HomeScreen(),
    CartScreen(),
    OrdersScreen(),
    ProfileScreen(),
  ];

  final _labels = const ['Beranda', 'Keranjang', 'Pesanan', 'Profil'];

  final _icons = const [
    Icons.home_rounded,
    Icons.shopping_cart_rounded,
    Icons.receipt_long_rounded,
    Icons.person_rounded,
  ];

  // FUNGSI BARU: Untuk pindah tab dari luar
  void changeTab(int index) {
    if (_index == index) return;
    HapticFeedback.selectionClick();
    setState(() => _index = index);
  }

  void _onTabTap(int index) => changeTab(index);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: canvas,
      body: IndexedStack(index: _index, children: _pages),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  Widget _buildBottomNav() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 16,
            offset: const Offset(0, -6),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
          child: Row(
            children: List.generate(_pages.length, (i) {
              final isActive = _index == i;
              return Expanded(
                child: _NavItem(
                  icon: _icons[i],
                  label: _labels[i],
                  isActive: isActive,
                  showBadge: i == 1,
                  onTap: () => _onTabTap(i),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isActive;
  final bool showBadge;
  final VoidCallback onTap;

  const _NavItem({
    required this.icon,
    required this.label,
    required this.isActive,
    required this.showBadge,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 220),
              curve: Curves.easeOutCubic,
              padding: EdgeInsets.symmetric(
                horizontal: isActive ? 18 : 10,
                vertical: 6,
              ),
              decoration: BoxDecoration(
                gradient: isActive ? brandGradient : null,
                borderRadius: BorderRadius.circular(AppRadius.pill),
              ),
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  Icon(
                    icon,
                    color: isActive ? Colors.white : muted,
                    size: 22,
                  ),
                  if (showBadge)
                    Positioned(
                      top: -6,
                      right: -8,
                      child: ValueListenableBuilder<int>(
                        valueListenable: cartBadgeNotifier,
                        builder: (_, count, __) {
                          if (count <= 0) return const SizedBox.shrink();
                          return Container(
                            padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                            decoration: BoxDecoration(
                              color: isActive ? Colors.white : brandRed,
                              borderRadius: BorderRadius.circular(AppRadius.pill),
                              border: Border.all(
                                color: isActive ? brandRed : Colors.white,
                                width: 1.5,
                              ),
                            ),
                            constraints: const BoxConstraints(minWidth: 16),
                            child: Text(
                              count > 99 ? '99+' : '$count',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 9,
                                fontWeight: FontWeight.w900,
                                color: isActive ? brandRed : Colors.white,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 4),
            AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 200),
              style: TextStyle(
                fontSize: 10,
                fontWeight: isActive ? FontWeight.w900 : FontWeight.w600,
                color: isActive ? brandRed : muted,
              ),
              child: Text(label),
            ),
          ],
        ),
      ),
    );
  }
}