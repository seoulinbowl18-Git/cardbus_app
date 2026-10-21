import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

/// Chip pilihan 2 baris (jam berangkat / varian kursi), gaya varian produk.
class OptionChip extends StatelessWidget {
  const OptionChip({
    super.key,
    required this.title,
    required this.subtitle,
    required this.selected,
    required this.onTap,
    this.disabled = false,
  });

  final String title;
  final String subtitle;
  final bool selected;
  final bool disabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final Color bg = disabled ? AppColors.bg : (selected ? AppColors.tealSoft : AppColors.white);
    final Color fg = disabled ? const Color(0xFFAEBBBC) : (selected ? AppColors.darkTeal : AppColors.ink);
    return InkWell(
      onTap: disabled ? null : onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        constraints: const BoxConstraints(minHeight: 52),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: disabled ? const Color(0xFFCED8D8) : (selected ? AppColors.teal : const Color(0xFFCED8D8)),
            width: selected ? 2 : 1,
          ),
        ),
        child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(title, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: fg)),
          Text(subtitle, style: TextStyle(fontSize: 11, color: fg)),
        ]),
      ),
    );
  }
}
