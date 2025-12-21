//
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// =======================
/// LIGHT THEME
/// =======================
final ThemeData lightTheme = ThemeData(
  useMaterial3: true,
  brightness: Brightness.light,

  colorScheme: ColorScheme.fromSeed(
    seedColor: const Color(0xFFcc392f), // Professional blue
    brightness: Brightness.light,
    primary: const Color(0xFFcc392f),
    secondary: const Color(0xFF1E40AF),
    surface: const Color(0xFFF8FAFF),
  ),

  scaffoldBackgroundColor: const Color(0xFFF9FAFB),

  appBarTheme: const AppBarTheme(
    elevation: 0,
    centerTitle: false,
    backgroundColor: Colors.transparent,
    foregroundColor: Color(0xFF0F172A),
  ),

  textTheme: GoogleFonts.interTextTheme().copyWith(
    headlineLarge: GoogleFonts.inter(
      fontWeight: FontWeight.w700,
      fontSize: 28,
      color: Color(0xFF0F172A),
    ),
    headlineSmall: GoogleFonts.inter(
      fontWeight: FontWeight.w600,
      fontSize: 20,
      color: Color(0xFF1E293B),
    ),
    titleMedium: GoogleFonts.inter(
      fontWeight: FontWeight.w500,
      color: Color(0xFF334155),
    ),
    bodyLarge: GoogleFonts.inter(
      fontSize: 15,
      height: 1.5,
      color: Color(0xFF475569),
    ),
    bodyMedium: GoogleFonts.inter(
      fontSize: 14,
      height: 1.5,
      color: Color(0xFF475569),
    ),
  ),

  cardTheme: CardThemeData(
    color: Colors.white,
    elevation: 1.5,
    shadowColor: Colors.black12,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
  ),

  inputDecorationTheme: InputDecorationTheme(
    filled: true,
    fillColor: const Color(0xFFF1F5F9),
    hintStyle: const TextStyle(color: Color(0xFF94A3B8)),
    border: OutlineInputBorder(
      borderSide: BorderSide.none,
      borderRadius: BorderRadius.circular(14),
    ),
  ),

  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: const Color(0xFF2563EB),
      foregroundColor: Colors.white,
      elevation: 0,
      padding: const EdgeInsets.symmetric(horizontal: 26, vertical: 14),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      textStyle: const TextStyle(fontWeight: FontWeight.w600),
    ),
  ),

  iconTheme: const IconThemeData(color: Color(0xFF2563EB)),

  dividerColor: const Color(0xFFE2E8F0),
  splashFactory: InkSparkle.splashFactory,
);

/// =======================
/// DARK THEME
/// =======================
final ThemeData darkTheme = ThemeData(
  useMaterial3: true,
  brightness: Brightness.dark,

  colorScheme: ColorScheme.fromSeed(
    seedColor: const Color(0xFF3B82F6),
    brightness: Brightness.dark,
    primary: const Color(0xFF3B82F6),
    secondary: const Color(0xFF60A5FA),
    surface: const Color(0xFF0B1220),
  ),

  scaffoldBackgroundColor: const Color(0xFF0B1220),

  appBarTheme: const AppBarTheme(
    elevation: 0,
    centerTitle: false,
    backgroundColor: Colors.transparent,
    foregroundColor: Colors.white70,
  ),

  textTheme: GoogleFonts.interTextTheme().copyWith(
    headlineLarge: GoogleFonts.inter(
      fontWeight: FontWeight.w700,
      fontSize: 28,
      color: Colors.white,
    ),
    headlineSmall: GoogleFonts.inter(
      fontWeight: FontWeight.w600,
      fontSize: 20,
      color: Colors.white,
    ),
    titleMedium: GoogleFonts.inter(color: Colors.white70),
    bodyLarge: GoogleFonts.inter(color: Colors.white70, height: 1.5),
    bodyMedium: GoogleFonts.inter(color: Colors.white60, height: 1.5),
  ),

  cardTheme: CardThemeData(
    color: const Color(0xFF111827),
    elevation: 2,
    shadowColor: Colors.black54,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
  ),

  inputDecorationTheme: InputDecorationTheme(
    filled: true,
    fillColor: const Color(0xFF1E293B),
    hintStyle: const TextStyle(color: Color(0xFF94A3B8)),
    border: OutlineInputBorder(
      borderSide: BorderSide.none,
      borderRadius: BorderRadius.circular(14),
    ),
  ),

  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: const Color(0xFF3B82F6),
      foregroundColor: Colors.white,
      elevation: 0,
      padding: const EdgeInsets.symmetric(horizontal: 26, vertical: 14),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      textStyle: const TextStyle(fontWeight: FontWeight.w600),
    ),
  ),

  iconTheme: const IconThemeData(color: Color(0xFF60A5FA)),

  dividerColor: Colors.white10,
  splashFactory: InkSparkle.splashFactory,
);
