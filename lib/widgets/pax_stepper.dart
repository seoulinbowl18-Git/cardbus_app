import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

/// Tombol − / + kecil.
class StepButton extends StatelessWidget {
  const StepButton({super.key, required this.symbol, required this.onTap, this.filled = false, this.semanticLabel});

  final String symbol;
  final VoidCallback? onTap;
  final bool filled;
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: semanticLabel,
      child: Material(
        color: filled ? AppColors.tealSoft : AppColors.white,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: onTap,
          child: Container(
            width: 44,
            height: 44,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: filled ? null : Border.all(color: AppColors.border),
            ),
            child: Text(symbol, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: AppColors.teal)),
          ),
        ),
      ),
    );
  }
}

/// Baris "Jumlah penumpang" di kartu pencarian.
class PaxStepper extends StatelessWidget {
  const PaxStepper({super.key, required this.value, required this.onMinus, required this.onPlus, this.max = 4});

  final int value;
  final int max;
  final VoidCallback onMinus;
  final VoidCallback onPlus;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 6, 8, 6),
      decoration: BoxDecoration(border: Border.all(color: AppColors.border), borderRadius: BorderRadius.circular(14)),
      child: Row(children: [
        const Icon(Icons.person_rounded, color: AppColors.teal),
        const SizedBox(width: 12),
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('Jumlah penumpang · maks. $max', style: const TextStyle(fontSize: 11, color: AppColors.faint, fontWeight: FontWeight.w600)),
            Text('$value Penumpang', style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800)),
          ]),
        ),
        StepButton(symbol: '−', onTap: onMinus, semanticLabel: 'Kurangi penumpang'),
        const SizedBox(width: 8),
        StepButton(symbol: '+', onTap: onPlus, filled: true, semanticLabel: 'Tambah penumpang'),
      ]),
    );
  }
}
