// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';

// Centralized design system: warna, typography, dan komponen tema aplikasi.
// Semua konstanta visual didefinisikan di sini agar mudah diubah.

// Palet Warna Utama
class AppColors {
  AppColors._(); // Prevent instantiation

  // Primary
  static const Color primary = Color(0xFF1E3A8A);       // Biru navy doff
  static const Color primaryLight = Color(0xFFEFF6FF);  // Biru sangat muda
  static const Color primaryDark = Color(0xFF1E40AF);   // Biru gelap

  // Background & Surface
  static const Color background = Color(0xFFF8FAFC);    // Abu-abu sangat muda
  static const Color surface = Color(0xFFFFFFFF);       // Putih
  static const Color surfaceAlt = Color(0xFFF1F5F9);    // Abu-abu muda

  // Text
  static const Color textPrimary = Color(0xFF0F172A);   // Hampir hitam
  static const Color textSecondary = Color.fromARGB(255, 110, 128, 152); // Abu-abu sedang
  static const Color textHint = Color(0xFFCBD5E1);      // Abu-abu muda

  // Border
  static const Color border = Color(0xFFE2E8F0);
  static const Color borderFocus = Color.fromARGB(255, 22, 47, 115);

  // BMI Category Colors
  static const Color bmiUnderweight = Color.fromARGB(255, 59, 144, 255);  
  static const Color bmiNormal = Color.fromARGB(255, 64, 204, 89);       
  static const Color bmiOverweight = Color.fromARGB(241, 237, 217, 44);   
  static const Color bmiObesity1 = Color.fromARGB(255, 254, 177, 53);   
  static const Color bmiObesity2 = Color(0xFFF97316);   
  static const Color bmiObesity3 = Color.fromARGB(255, 255, 62, 62);   

  // Status
  static const Color error = Color(0xFFEF4444);
  static const Color success = Color(0xFF10B981);
}

// Tema Utama Aplikasi
ThemeData appTheme = ThemeData(
  useMaterial3: true,
  colorScheme: ColorScheme.fromSeed(
    seedColor: AppColors.primary,
    brightness: Brightness.light,
  ),
  scaffoldBackgroundColor: AppColors.background,
  fontFamily: 'Roboto',

  // AppBar
  appBarTheme: const AppBarTheme(
    backgroundColor: AppColors.surface,
    foregroundColor: AppColors.textPrimary,
    elevation: 0,
    centerTitle: false,
    titleTextStyle: TextStyle(
      color: AppColors.textPrimary,
      fontSize: 18,
      fontWeight: FontWeight.w600,
    ),
    iconTheme: IconThemeData(color: AppColors.textPrimary),
  ),

  // Input Fields
  inputDecorationTheme: InputDecorationTheme(
    filled: true,
    fillColor: AppColors.surface,
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: AppColors.border),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: AppColors.border),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: AppColors.borderFocus, width: 2),
    ),
    errorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: AppColors.error),
    ),
    focusedErrorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: AppColors.error, width: 2),
    ),
    labelStyle: const TextStyle(color: AppColors.textSecondary, fontSize: 14),
    floatingLabelStyle: const TextStyle(color: AppColors.textPrimary, fontSize: 18, fontWeight: FontWeight.w500),
    suffixStyle: const TextStyle(color: AppColors.textSecondary, fontSize: 14, fontWeight: FontWeight.w600),
    hintStyle: const TextStyle(color: AppColors.textHint, fontSize: 14),
    errorStyle: const TextStyle(color: AppColors.error, fontSize: 12),
  ),

  // Elevated Button
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: AppColors.primary,
      foregroundColor: Colors.white,
      minimumSize: const Size(double.infinity, 52),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
      elevation: 0,
    ),
  ),

  // Card
  cardTheme: CardThemeData(
    color: AppColors.surface,
    elevation: 0,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(16),
      side: const BorderSide(color: AppColors.border),
    ),
    margin: EdgeInsets.zero,
  ),

  // Divider
  dividerTheme: const DividerThemeData(
    color: AppColors.border,
    thickness: 1,
    space: 0,
  ),
);