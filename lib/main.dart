import 'dart:async';
import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'config/theme.dart';
import 'services/auth_service.dart';
import 'screens/login_screen.dart';
import 'screens/customer/customer_shell.dart';

// Global keys — untuk navigation & snackbar dari luar BuildContext
final GlobalKey<NavigatorState> appNavigatorKey = GlobalKey<NavigatorState>();
final GlobalKey<ScaffoldMessengerState> appScaffoldMessengerKey =
    GlobalKey<ScaffoldMessengerState>();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  _setupErrorHandlers();
  await initializeDateFormatting('id_ID', null);

  final loggedIn = await AuthService().isLoggedIn();

  runApp(NusadhipaCustomerApp(isLoggedIn: loggedIn));
}

void _setupErrorHandlers() {
  FlutterError.onError = (details) {
    FlutterError.presentError(details);
    if (kReleaseMode) {
      // TODO: kirim ke Crashlytics/Sentry/API
      debugPrint('[FlutterError] ${details.exceptionAsString()}');
    }
  };

  PlatformDispatcher.instance.onError = (error, stack) {
    if (kReleaseMode) {
      // TODO: kirim ke Crashlytics/Sentry/API
      debugPrint('[PlatformError] $error\n$stack');
    }
    return true;
  };
}

class NusadhipaCustomerApp extends StatelessWidget {
  final bool isLoggedIn;
  const NusadhipaCustomerApp({super.key, required this.isLoggedIn});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'NUSA-DHIPA Customer',
      debugShowCheckedModeBanner: false,

      // Keys global
      navigatorKey: appNavigatorKey,
      scaffoldMessengerKey: appScaffoldMessengerKey,

      // Theme
      theme: buildNusadhipaTheme(),

      // Lokalisasi Indonesia
      locale: const Locale('id', 'ID'),
      supportedLocales: const [
        Locale('id', 'ID'),
        Locale('en', 'US'),
      ],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],

      // Scroll behavior premium
      scrollBehavior: const MaterialScrollBehavior().copyWith(
        physics: const BouncingScrollPhysics(
          parent: AlwaysScrollableScrollPhysics(),
        ),
        dragDevices: {
          PointerDeviceKind.touch,
          PointerDeviceKind.mouse,
          PointerDeviceKind.trackpad,
          PointerDeviceKind.stylus,
        },
      ),

      // Batasi text scaling
      builder: (context, child) {
        final mq = MediaQuery.of(context);
        return MediaQuery(
          data: mq.copyWith(
            textScaler:
                mq.textScaler.clamp(minScaleFactor: 1.0, maxScaleFactor: 1.3),
          ),
          child: child!,
        );
      },

      // Route
      home: isLoggedIn ? const CustomerShell() : const LoginScreen(),
    );
  }
}
