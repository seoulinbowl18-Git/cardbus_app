import 'package:flutter/material.dart';

/// Palet resmi CardBus.
class AppColors {
  AppColors._();

  static const teal = Color(0xFF087F78);
  static const darkTeal = Color(0xFF064E52);
  static const gold = Color(0xFFFFC247);
  static const white = Color(0xFFFFFFFF);

  static const ink = Color(0xFF13272B);
  static const muted = Color(0xFF5E6E70);
  static const faint = Color(0xFF7E8C8E);
  static const border = Color(0xFFE1E8E8);
  static const bg = Color(0xFFF4F7F7);
  static const tealSoft = Color(0xFFE3F2F1);
  static const tealSoft2 = Color(0xFFE9F5F4);
  static const promoRed = Color(0xFFE5484D);
  static const error = Color(0xFF9B1C1C);
  static const success = Color(0xFF1F6A3A);

  static const headerGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF0A8C84), teal, darkTeal],
    stops: [0, 0.35, 1],
  );
}
