import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

/// Logo PO (gambar) atau kotak warna berisi singkatan.
class PoBadge extends StatelessWidget {
  const PoBadge({super.key, required this.short, required this.color, this.logo, this.size = 32, this.radius = 9});

  final String short;
  final Color color;
  final String? logo;
  final double size;
  final double radius;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: logo == null ? color : AppColors.white,
        borderRadius: BorderRadius.circular(radius),
        border: Border.all(color: AppColors.white, width: 2),
        boxShadow: const [BoxShadow(color: Color(0x26000000), blurRadius: 6, offset: Offset(0, 2))],
      ),
      clipBehavior: Clip.antiAlias,
      alignment: Alignment.center,
      child: logo != null
          ? Image.asset(logo!, fit: BoxFit.cover, width: size, height: size)
          : Text(short,
              style: TextStyle(color: AppColors.white, fontWeight: FontWeight.w800, fontSize: short.length > 2 ? size * 0.28 : size * 0.36)),
    );
  }
}
