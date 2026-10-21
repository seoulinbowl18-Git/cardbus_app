import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

/// Kolom "Dari" / "Ke" di kartu pencarian.
class LocationField extends StatelessWidget {
  const LocationField({
    super.key,
    required this.label,
    required this.title,
    required this.subtitle,
    required this.pinColor,
    required this.onTap,
  });

  final String label;
  final String title;
  final String subtitle;
  final Color pinColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.white,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: Container(
          constraints: const BoxConstraints(minHeight: 60),
          padding: const EdgeInsets.fromLTRB(14, 8, 56, 8),
          decoration: BoxDecoration(
            border: Border.all(color: AppColors.border),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Row(children: [
            Icon(Icons.location_on_rounded, color: pinColor, size: 24),
            const SizedBox(width: 12),
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(label, style: const TextStyle(fontSize: 11, color: AppColors.faint, fontWeight: FontWeight.w600)),
                Text(title, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800)),
                Text(subtitle, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 11, color: AppColors.muted)),
              ]),
            ),
          ]),
        ),
      ),
    );
  }
}
