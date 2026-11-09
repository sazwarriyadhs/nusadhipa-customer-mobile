import 'package:flutter/material.dart';

// ============================================================
// NUSA-DHIPA Brand Colors
// ============================================================

const brandRed = Color(0xFFE5232E);
const deepRed = Color(0xFF98182A);
const crimson = Color(0xFFFF3B47);

const gold = Color(0xFFD4A24C);
const goldLight = Color(0xFFF4D58D);
const goldDeep = Color(0xFF9C7220);

const orange = Color(0xFFF59E0B);
const orangeLight = Color(0xFFFFF1D6);

const ink = Color(0xFF19191D);
const muted = Color(0xFF777782);
const canvas = Color(0xFFF6F6F8);
const line = Color(0xFFECECF0);

const emeraldGreen = Color(0xFF15803D);
const oceanBlue = Color(0xFF0369A1);
const successGreen = Color(0xFF16A34A);
const dangerRed = Color(0xFFDC2626);

// ============================================================
// Gradients
// ============================================================
const brandGradient = LinearGradient(
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
  colors: [crimson, brandRed, deepRed],
  stops: [0.0, 0.5, 1.0],
);

const goldGradient = LinearGradient(
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
  colors: [goldLight, gold, goldDeep],
);

const heroGradient = LinearGradient(
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
  colors: [brandRed, deepRed],
);

// ============================================================
// Spacing & Radius Constants
// ============================================================
class AppSpacing {
  static const double xxs = 4;
  static const double xs = 8;
  static const double sm = 12;
  static const double md = 16;
  static const double lg = 20;
  static const double xl = 24;
  static const double xxl = 32;
  static const double huge = 40;
}

class AppRadius {
  static const double xs = 8;
  static const double sm = 12;
  static const double md = 16;
  static const double lg = 20;
  static const double xl = 24;
  static const double pill = 100;
}

// ============================================================
// Text Theme
// ============================================================
const _textTheme = TextTheme(
  displayLarge: TextStyle(
    fontSize: 34,
    fontWeight: FontWeight.w900,
    letterSpacing: -0.8,
    height: 1.1,
    color: ink,
  ),
  displayMedium: TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.w800,
    letterSpacing: -0.5,
    height: 1.15,
    color: ink,
  ),
  displaySmall: TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.w800,
    letterSpacing: -0.3,
    height: 1.2,
    color: ink,
  ),
  headlineLarge: TextStyle(
    fontSize: 22,
    fontWeight: FontWeight.w800,
    letterSpacing: -0.2,
    height: 1.25,
    color: ink,
  ),
  headlineMedium: TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w700,
    height: 1.3,
    color: ink,
  ),
  headlineSmall: TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w700,
    height: 1.3,
    color: ink,
  ),
  titleLarge: TextStyle(
    fontSize: 17,
    fontWeight: FontWeight.w700,
    height: 1.35,
    color: ink,
  ),
  titleMedium: TextStyle(
    fontSize: 15,
    fontWeight: FontWeight.w600,
    height: 1.35,
    color: ink,
  ),
  titleSmall: TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    height: 1.35,
    color: ink,
  ),
  bodyLarge: TextStyle(
    fontSize: 15,
    fontWeight: FontWeight.w400,
    height: 1.5,
    color: ink,
  ),
  bodyMedium: TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    height: 1.5,
    color: ink,
  ),
  bodySmall: TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    height: 1.4,
    color: muted,
  ),
  labelLarge: TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w700,
    letterSpacing: 0.2,
    color: ink,
  ),
  labelMedium: TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.2,
    color: ink,
  ),
  labelSmall: TextStyle(
    fontSize: 11,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.3,
    color: muted,
  ),
);

// ============================================================
// Shadow Constants
// ============================================================
const softShadow = [
  BoxShadow(color: Color(0x0A000000), blurRadius: 12, offset: Offset(0, 2)),
];
const elevatedShadow = [
  BoxShadow(color: Color(0x14000000), blurRadius: 20, offset: Offset(0, 8)),
];
const brandShadow = [
  BoxShadow(color: Color(0x33E5232E), blurRadius: 16, offset: Offset(0, 6)),
];

// ============================================================
// Theme Builder
// ============================================================
ThemeData buildNusadhipaTheme() {
  final colorScheme = ColorScheme.fromSeed(
    seedColor: brandRed,
    brightness: Brightness.light,
    primary: brandRed,
    onPrimary: Colors.white,
    secondary: gold,
    onSecondary: ink,
    surface: Colors.white,
    onSurface: ink,
    error: dangerRed,
  );

  return ThemeData(
    useMaterial3: true,
    fontFamily: 'Roboto',
    scaffoldBackgroundColor: canvas,
    colorScheme: colorScheme,
    textTheme: _textTheme,
    cardTheme: CardThemeData(
      color: Colors.white,
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.md),
        side: const BorderSide(color: line, width: 1),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.white,
      hintStyle: const TextStyle(color: muted, fontSize: 14),
      labelStyle: const TextStyle(color: muted, fontSize: 14),
      floatingLabelStyle: const TextStyle(color: brandRed, fontSize: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadius.sm),
        borderSide: const BorderSide(color: line, width: 1),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadius.sm),
        borderSide: const BorderSide(color: line, width: 1),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadius.sm),
        borderSide: const BorderSide(color: brandRed, width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadius.sm),
        borderSide: const BorderSide(color: dangerRed, width: 1),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    ),
    chipTheme: ChipThemeData(
      backgroundColor: Colors.white,
      selectedColor: brandRed,
      disabledColor: line,
      labelStyle: const TextStyle(
        fontWeight: FontWeight.w600,
        fontSize: 12,
        color: ink,
      ),
      secondaryLabelStyle: const TextStyle(
        fontWeight: FontWeight.w700,
        fontSize: 12,
        color: Colors.white,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.pill),
      ),
      side: const BorderSide(color: line),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
    ),
    dialogTheme: DialogThemeData(
      backgroundColor: Colors.white,
      elevation: 12,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.lg),
      ),
      titleTextStyle: _textTheme.headlineSmall,
      contentTextStyle: _textTheme.bodyMedium,
    ),
    snackBarTheme: SnackBarThemeData(
      behavior: SnackBarBehavior.floating,
      backgroundColor: ink,
      contentTextStyle: const TextStyle(
        color: Colors.white,
        fontSize: 14,
        fontWeight: FontWeight.w500,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.sm),
      ),
      elevation: 8,
      insetPadding: const EdgeInsets.all(16),
    ),
    dividerTheme: const DividerThemeData(
      color: line,
      thickness: 1,
      space: 1,
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: brandRed,
        foregroundColor: Colors.white,
        disabledBackgroundColor: line,
        disabledForegroundColor: muted,
        minimumSize: const Size(0, 52),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.sm),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        textStyle: const TextStyle(
          fontWeight: FontWeight.w800,
          letterSpacing: 0.3,
          fontSize: 15,
        ),
        elevation: 0,
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: brandRed,
        foregroundColor: Colors.white,
        disabledBackgroundColor: line,
        disabledForegroundColor: muted,
        minimumSize: const Size(0, 52),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.sm),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        textStyle: const TextStyle(
          fontWeight: FontWeight.w800,
          letterSpacing: 0.3,
          fontSize: 15,
        ),
        elevation: 0,
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: brandRed,
        side: const BorderSide(color: brandRed, width: 1.5),
        minimumSize: const Size(0, 52),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.sm),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        textStyle: const TextStyle(
          fontWeight: FontWeight.w700,
          letterSpacing: 0.2,
          fontSize: 14,
        ),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: brandRed,
        textStyle: const TextStyle(
          fontWeight: FontWeight.w700,
          fontSize: 14,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      ),
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: canvas,
      foregroundColor: ink,
      elevation: 0,
      scrolledUnderElevation: 0.5,
      centerTitle: false,
      titleTextStyle: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w800,
        color: ink,
        letterSpacing: -0.3,
      ),
      iconTheme: IconThemeData(color: ink, size: 24),
    ),
    bottomSheetTheme: const BottomSheetThemeData(
      backgroundColor: Colors.white,
      modalBackgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.xl)),
      ),
      elevation: 12,
    ),
    tabBarTheme: const TabBarThemeData(
      labelColor: brandRed,
      unselectedLabelColor: muted,
      indicatorColor: brandRed,
      indicatorSize: TabBarIndicatorSize.label,
      labelStyle: TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
      unselectedLabelStyle: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
      dividerColor: Colors.transparent,
    ),
    progressIndicatorTheme: const ProgressIndicatorThemeData(
      color: brandRed,
      linearTrackColor: line,
      circularTrackColor: line,
    ),
    pageTransitionsTheme: const PageTransitionsTheme(
      builders: {
        TargetPlatform.android: PredictiveBackPageTransitionsBuilder(),
        TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
        TargetPlatform.macOS: CupertinoPageTransitionsBuilder(),
        TargetPlatform.windows: FadeUpwardsPageTransitionsBuilder(),
        TargetPlatform.linux: FadeUpwardsPageTransitionsBuilder(),
      },
    ),
    splashFactory: InkSparkle.splashFactory,
    highlightColor: brandRed.withValues(alpha: 0.06),
    splashColor: brandRed.withValues(alpha: 0.10),
  );
}