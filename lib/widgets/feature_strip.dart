import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

/// 4 keunggulan CardBus (2 x 2) di paling bawah beranda.
class FeatureStrip extends StatelessWidget {
  const FeatureStrip({super.key});

  static const _items = [
    (Icons.confirmation_number_outlined, 'Pesan Tiket\nMudah'),
    (Icons.verified_user_outlined, 'Aman &\nTerpercaya'),
    (Icons.directions_bus_filled_rounded, 'Banyak Pilihan\nPO Bus'),
    (Icons.update_rounded, 'Cepat &\nPraktis'),
  ];

  @override
  Widget build(BuildContext context) {
    const line = BorderSide(color: Color(0xFFCFE3E1));
    Widget cell(int i) {
      final item = _items[i];
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
        decoration: BoxDecoration(
          border: Border(
            right: i.isEven ? line : BorderSide.none,
            bottom: i < 2 ? line : BorderSide.none,
          ),
        ),
        child: Row(children: [
          Icon(item.$1, color: AppColors.teal, size: 32),
          const SizedBox(width: 10),
          Expanded(child: Text(item.$2, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, height: 1.35))),
        ]),
      );
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(color: AppColors.tealSoft2, borderRadius: BorderRadius.circular(22)),
      clipBehavior: Clip.antiAlias,
      child: Column(children: [
        Row(children: [Expanded(child: cell(0)), Expanded(child: cell(1))]),
        Row(children: [Expanded(child: cell(2)), Expanded(child: cell(3))]),
      ]),
    );
  }
}
