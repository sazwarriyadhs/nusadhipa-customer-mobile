import 'package:flutter/material.dart';
import '../../config/theme.dart';
import '../../widgets/heading.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          const Heading('Profil', 'Akun customer'),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [Color(0xFFE5232E), Color(0xFFC41E28)]),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                children: [
                  Container(
                    width: 64, height: 64,
                    decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.2), shape: BoxShape.circle, border: Border.all(color: Colors.white, width: 2)),
                    child: const Icon(Icons.person, color: Colors.white, size: 36),
                  ),
                  const SizedBox(width: 14),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Azwar Riyadh', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w900)),
                        SizedBox(height: 4),
                        Text('azwar@customer.com', style: TextStyle(color: Colors.white70, fontSize: 12)),
                        SizedBox(height: 4),
                        Text('Member sejak Okt 2026', style: TextStyle(color: Colors.white70, fontSize: 10)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          _menuSection('Akun', [
            _menuItem(Icons.person_outline, 'Edit Profil', () {}),
            _menuItem(Icons.location_on_outlined, 'Alamat Pengiriman', () {}),
            _menuItem(Icons.credit_card, 'Metode Pembayaran', () {}),
          ]),
          _menuSection('Aktivitas', [
            _menuItem(Icons.receipt_long_outlined, 'Pesanan Saya', () {}),
            _menuItem(Icons.favorite_border, 'Wishlist', () {}),
            _menuItem(Icons.star_outline, 'Ulasan Saya', () {}),
          ]),
          _menuSection('Pengaturan', [
            _menuItem(Icons.notifications_outlined, 'Notifikasi', () {}),
            _menuItem(Icons.language, 'Bahasa', () {}),
            _menuItem(Icons.help_outline, 'Bantuan', () {}),
            _menuItem(Icons.info_outline, 'Tentang NUSA-DHIPA', () {}),
          ]),
          Padding(
            padding: const EdgeInsets.all(16),
            child: OutlinedButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.logout, color: brandRed),
              label: const Text('Keluar', style: TextStyle(color: brandRed, fontWeight: FontWeight.bold)),
              style: OutlinedButton.styleFrom(side: const BorderSide(color: brandRed), padding: const EdgeInsets.symmetric(vertical: 14), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
            ),
          ),
          const Padding(
            padding: EdgeInsets.all(16),
            child: Text('© 2026 PT DIGI MEDIA KOMUNIKA', textAlign: TextAlign.center, style: TextStyle(fontSize: 10, color: muted)),
          ),
        ],
      ),
    );
  }

  Widget _menuSection(String title, List<Widget> items) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 4, bottom: 8),
            child: Text(title.toUpperCase(), style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: muted, letterSpacing: 0.5)),
          ),
          Container(
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: line)),
            child: Column(children: items),
          ),
        ],
      ),
    );
  }

  Widget _menuItem(IconData icon, String label, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        child: Row(
          children: [
            Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: brandRed.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)), child: Icon(icon, color: brandRed, size: 18)),
            const SizedBox(width: 12),
            Expanded(child: Text(label, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600))),
            const Icon(Icons.chevron_right, color: muted, size: 20),
          ],
        ),
      ),
    );
  }
}
