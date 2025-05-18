import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Colors
  static const primaryGrey = Color(0xFF161A1C);
  static const secondaryGrey = Color(0xFF1E2428);
  static const surfaceGrey = Color(0xFF262B2F);
  static const white = Colors.white;
  static const orange = Color(0xFFFFAC1C);
  static const green = Color(0xFF4CAF50);
  static const lightGreen = Color(0xFF81C784);
  static const darkGreen = Color(0xFF388E3C);
  
  // Gradients
  static const greenGradient = LinearGradient(
    colors: [darkGreen, green],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Shadows
  static final elevation1 = [
    BoxShadow(
      color: Colors.black.withOpacity(0.2),
      blurRadius: 8,
      offset: const Offset(0, 2),
    ),
  ];

  static final elevation2 = [
    BoxShadow(
      color: Colors.black.withOpacity(0.25),
      blurRadius: 12,
      offset: const Offset(0, 4),
    ),
  ];

  // Theme Data
  static ThemeData get theme => ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.dark(
      primary: green,
      secondary: white,
      tertiary: orange,
      background: primaryGrey,
      surface: surfaceGrey,
      onPrimary: white,
      onSecondary: white,
      onTertiary: primaryGrey,
      onBackground: white,
      onSurface: white,
    ),
    scaffoldBackgroundColor: primaryGrey,
    textTheme: GoogleFonts.interTextTheme(ThemeData.dark().textTheme),
    appBarTheme: AppBarTheme(
      elevation: 0,
      backgroundColor: secondaryGrey,
      foregroundColor: white,
      centerTitle: true,
      titleTextStyle: GoogleFonts.inter(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: white,
      ),
    ),
    drawerTheme: DrawerThemeData(
      backgroundColor: secondaryGrey,
      elevation: 0,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: green,
        foregroundColor: white,
        elevation: 0,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    ),
    cardTheme: CardTheme(
      color: surfaceGrey,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      margin: const EdgeInsets.all(8),
    ),
    iconTheme: const IconThemeData(
      color: white,
      size: 24,
    ),
    snackBarTheme: const SnackBarThemeData(
      backgroundColor: surfaceGrey,
      contentTextStyle: TextStyle(color: white),
    ),
  );
} 