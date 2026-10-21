import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

/// Label kecil di atas foto: PROMO (merah), BARU / SEGERA HADIR (teal), lainnya emas.
class TagChip extends StatelessWidget {
  const TagChip(this.text, {super.key});
  final String text;

  @override
  Widget build(BuildContext context) {
    final bg = text == 'PROMO'
        ? AppColors.promoRed
        : (text == 'BARU' || text == 'SEGERA HADIR')
            ? AppColors.teal
            : AppColors.gold;
    final fg = bg == AppColors.gold ? AppColors.ink : AppColors.white;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(999)),
      child: Text(text, style: TextStyle(color: fg, fontSize: 10, fontWeight: FontWeight.w800, letterSpacing: 0.4)),
    );
  }
}
