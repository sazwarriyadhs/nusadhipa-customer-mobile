import 'package:flutter/material.dart';

/// Service untuk navigasi antar tab dari mana saja
class NavService {
  static final GlobalKey<NavigatorState> navigatorKey =
      GlobalKey<NavigatorState>();

  static void Function(int)? _tabSwitcher;

  /// Daftarkan callback dari TenantShell
  static void registerTabSwitcher(void Function(int) fn) {
    _tabSwitcher = fn;
  }

  /// Ganti tab: 0=Beranda, 1=Pesanan, 2=Produk, 3=Kirim, 4=Toko
  static void switchTab(int index) {
    _tabSwitcher?.call(index);
  }
}