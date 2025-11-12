import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

//LIGHT THEME
final ThemeData lightTheme = ThemeData(
  useMaterial3: true,
  brightness: Brightness.light,
  colorScheme: ColorScheme.fromSeed(
    seedColor: const Color(0xFF4F46E5),
    brightness: Brightness.light,
    surface: const Color(0xFFF8FAFF),
  ),
  scaffoldBackgroundColor: const Color(0xFFF9FAFB),
  appBarTheme: const AppBarTheme(
    elevation: 0,
    centerTitle: false,
    backgroundColor: Colors.transparent,
    foregroundColor: Colors.black87,
  ),
  textTheme: GoogleFonts.interTextTheme().copyWith(
    headlineLarge: GoogleFonts.inter(fontWeight: FontWeight.w700, fontSize: 28),
    headlineSmall: GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 20),
    titleMedium: GoogleFonts.inter(fontWeight: FontWeight.w500),
    bodyLarge: GoogleFonts.inter(fontSize: 15, height: 1.4),
    bodyMedium: GoogleFonts.inter(fontSize: 14, height: 1.4),
  ),
  cardTheme: CardThemeData(
    color: Colors.white,
    elevation: 1,
    shadowColor: Colors.black12,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
  ),
  inputDecorationTheme: InputDecorationTheme(
    filled: true,
    fillColor: const Color(0xFFF3F4F6),
    border: OutlineInputBorder(
      borderSide: BorderSide.none,
      borderRadius: BorderRadius.circular(16),
    ),
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: const Color(0xFF4F46E5),
      foregroundColor: Colors.white,
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
      textStyle: const TextStyle(fontWeight: FontWeight.w600),
    ),
  ),
  iconTheme: const IconThemeData(color: Color(0xFF4F46E5)),
  dividerColor: Colors.grey.shade300,
  splashFactory: InkSparkle.splashFactory,
);

//DARK THEME

final ThemeData darkTheme = ThemeData(
  useMaterial3: true,
  brightness: Brightness.dark,
  colorScheme: ColorScheme.fromSeed(
    seedColor: const Color(0xFF6366F1),
    brightness: Brightness.dark,
    surface: const Color(0xFF0F111A),
  ),
  scaffoldBackgroundColor: const Color(0xFF0F111A),
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
    titleLarge: GoogleFonts.inter(color: Colors.white70, height: 1.4),
    bodyLarge: GoogleFonts.inter(color: Colors.white70, height: 1.4),
    bodyMedium: GoogleFonts.inter(color: Colors.white60, height: 1.4),
  ),
  cardTheme: CardThemeData(
    color: const Color(0xFF1B1E2A),
    elevation: 2,
    shadowColor: Colors.black54,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
  ),
  inputDecorationTheme: InputDecorationTheme(
    filled: true,
    fillColor: const Color(0xFF1E2233),
    border: OutlineInputBorder(
      borderSide: BorderSide.none,
      borderRadius: BorderRadius.circular(16),
    ),
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: const Color(0xFF6366F1),
      foregroundColor: Colors.white,
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
      textStyle: const TextStyle(fontWeight: FontWeight.w600),
    ),
  ),
  iconTheme: const IconThemeData(color: Color(0xFF818CF8)),
  dividerColor: Colors.white10,
  splashFactory: InkSparkle.splashFactory,
);
