import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../utils/formatters.dart';

/// Pilihan 7 hari ke depan.
class DateChips extends StatelessWidget {
  const DateChips({super.key, required this.selected, required this.onSelect, this.days = 7, this.compact = false});

  final int selected;
  final ValueChanged<int> onSelect;
  final int days;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final w = compact ? 58.0 : 64.0;
    final h = compact ? 62.0 : 68.0;
    return SizedBox(
      height: h,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: days,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, i) {
          final d = dayFromToday(i);
          final on = i == selected;
          final fg = on ? AppColors.white : AppColors.ink;
          return InkWell(
            borderRadius: BorderRadius.circular(14),
            onTap: () => onSelect(i),
            child: Container(
              width: w,
              decoration: BoxDecoration(
                color: on ? AppColors.teal : AppColors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: on ? AppColors.teal : AppColors.border),
              ),
              child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                Text(i == 0 ? 'Hari ini' : dowShort(d), style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: fg)),
                Text('${d.day}', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800, color: fg)),
                Text(monShort(d), style: TextStyle(fontSize: 11, color: fg)),
              ]),
            ),
          );
        },
      ),
    );
  }
}
