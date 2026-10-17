import 'package:flutter/material.dart';

// ============================================================
// NUSA-DHIPA Brand Colors (updated dari referensi)
// ============================================================

// Primary — Merah Nusantara (lebih cerah)
const brandRed = Color(0xFFE5232E);   // ← dari referensi
const deepRed = Color(0xFF98182A);
const crimson = Color(0xFFFF3B47);    // merah lebih cerah untuk gradient

// Gold — aksen kemewahan
const gold = Color(0xFFD4A24C);
const goldLight = Color(0xFFF4D58D);
const goldDeep = Color(0xFF9C7220);

// Orange — untuk status "menunggu"
const orange = Color(0xFFF59E0B);
const orangeLight = Color(0xFFFFF1D6);

// Netral
const ink = Color(0xFF19191D);
const muted = Color(0xFF777782);
const canvas = Color(0xFFF6F6F8);
const line = Color(0xFFECECF0);

// Aksen tambahan
const emeraldGreen = Color(0xFF15803D);
const oceanBlue = Color(0xFF0369A1);

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
// App Theme
// ============================================================
ThemeData buildNusadhipaTheme() {
  return ThemeData(
    useMaterial3: true,
    scaffoldBackgroundColor: canvas,
    colorScheme: ColorScheme.fromSeed(
      seedColor: brandRed,
      primary: brandRed,
      secondary: gold,
      surface: Colors.white,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: canvas,
      foregroundColor: ink,
      elevation: 0,
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: brandRed,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        textStyle: const TextStyle(
          fontWeight: FontWeight.w800,
          letterSpacing: 0.3,
        ),
      ),
    ),
  );
}