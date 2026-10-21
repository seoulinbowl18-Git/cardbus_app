import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app_colors.dart';

ThemeData buildAppTheme() {
  final base = ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: AppColors.teal,
      primary: AppColors.teal,
      secondary: AppColors.gold,
      surface: AppColors.white,
    ),
    scaffoldBackgroundColor: AppColors.bg,
  );

  OutlineInputBorder border(Color c, [double w = 1]) => OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: c, width: w),
      );

  return base.copyWith(
    textTheme: GoogleFonts.plusJakartaSansTextTheme(base.textTheme)
        .apply(bodyColor: AppColors.ink, displayColor: AppColors.ink),
    appBarTheme: AppBarTheme(
      backgroundColor: AppColors.teal,
      foregroundColor: AppColors.white,
      elevation: 0,
      titleTextStyle: GoogleFonts.plusJakartaSans(fontSize: 17, fontWeight: FontWeight.w800, color: AppColors.white),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: const Color(0xFFF9FBFB),
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      border: border(AppColors.border),
      enabledBorder: border(AppColors.border),
      focusedBorder: border(AppColors.teal, 1.6),
      errorBorder: border(AppColors.error),
      focusedErrorBorder: border(AppColors.error, 1.6),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.teal,
        foregroundColor: AppColors.white,
        minimumSize: const Size(64, 50),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        textStyle: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w800, fontSize: 15),
      ),
    ),
  );
}

/// Tombol emas (CTA utama: Cari tiket, Beli sekarang).
/// [expand] = true untuk tombol selebar layar (jangan dipakai di dalam Row).
ButtonStyle goldButtonStyle({double height = 54, bool expand = true}) => ElevatedButton.styleFrom(
      backgroundColor: AppColors.gold,
      foregroundColor: AppColors.ink,
      disabledBackgroundColor: const Color(0xFFDCE4E4),
      disabledForegroundColor: AppColors.muted,
      minimumSize: expand ? Size.fromHeight(height) : Size(0, height),
      padding: const EdgeInsets.symmetric(horizontal: 18),
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      textStyle: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w800, fontSize: 16),
    );
