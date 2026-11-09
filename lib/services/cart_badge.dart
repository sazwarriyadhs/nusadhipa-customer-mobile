import 'package:flutter/foundation.dart';

/// Global notifier untuk jumlah item di cart.
/// Dipakai oleh customer_shell (badge) dan cart_screen (update).
final ValueNotifier<int> cartBadgeNotifier = ValueNotifier<int>(0);