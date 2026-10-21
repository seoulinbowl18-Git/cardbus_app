import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

/// Ikon aplikasi CardBus (assets/images/cardbus_icon.png).
class CardBusIcon extends StatelessWidget {
  const CardBusIcon({super.key, this.size = 40});
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(size * 0.27),
        boxShadow: const [BoxShadow(color: Color(0x59FFFFFF), spreadRadius: 2)],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(size * 0.27),
        child: Image.asset('assets/images/cardbus_icon.png', fit: BoxFit.cover),
      ),
    );
  }
}

/// Tulisan "CardBus" — Card putih, Bus emas.
class CardBusWordmark extends StatelessWidget {
  const CardBusWordmark({super.key, this.fontSize = 23, this.cardColor = AppColors.white});
  final double fontSize;
  final Color cardColor;

  @override
  Widget build(BuildContext context) {
    final style = TextStyle(fontSize: fontSize, fontWeight: FontWeight.w800, fontStyle: FontStyle.italic, letterSpacing: -0.4);
    return Text.rich(TextSpan(children: [
      TextSpan(text: 'Card', style: style.copyWith(color: cardColor)),
      TextSpan(text: 'Bus', style: style.copyWith(color: AppColors.gold)),
    ]));
  }
}
