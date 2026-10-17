import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'config/theme.dart';
import 'services/auth_service.dart';
import 'screens/login_screen.dart';
import 'screens/customer/customer_shell.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('id_ID', null);

  final loggedIn = await AuthService().isLoggedIn();

  runApp(NusadhipaCustomerApp(isLoggedIn: loggedIn));
}

class NusadhipaCustomerApp extends StatelessWidget {
  final bool isLoggedIn;
  const NusadhipaCustomerApp({super.key, required this.isLoggedIn});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'NUSA-DHIPA Customer',
      debugShowCheckedModeBanner: false,
      theme: buildNusadhipaTheme(),
      home: isLoggedIn ? const CustomerShell() : const LoginScreen(),
    );
  }
}
