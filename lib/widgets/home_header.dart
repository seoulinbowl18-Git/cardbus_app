import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import 'avatar_widget.dart';
import 'cardbus_logo.dart';

/// Latar teal melengkung di belakang header + kartu pencarian.
class HomeHeaderBackground extends StatelessWidget {
  const HomeHeaderBackground({super.key, required this.height});
  final double height;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      decoration: const BoxDecoration(
        gradient: AppColors.headerGradient,
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(28)),
      ),
      child: CustomPaint(painter: _RoadPainter(), size: Size.infinite),
    );
  }
}

/// Logo + nama + avatar + sapaan "Halo, …! Mau ke mana?"
class HomeHeader extends StatelessWidget {
  const HomeHeader({super.key, required this.userName, required this.onAvatarTap});

  final String userName;
  final VoidCallback onAvatarTap;

  @override
  Widget build(BuildContext context) {
    final top = MediaQuery.paddingOf(context).top;
    return Padding(
      padding: EdgeInsets.fromLTRB(20, top + 14, 20, 0),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          const CardBusIcon(size: 40),
          const SizedBox(width: 10),
          const CardBusWordmark(),
          const Spacer(),
          AvatarWidget(size: 46, onTap: onAvatarTap),
        ]),
        const SizedBox(height: 12),
        Text(
          'Halo, $userName! Mau ke mana?',
          style: const TextStyle(color: AppColors.white, fontSize: 20, fontWeight: FontWeight.w700, height: 1.25),
        ),
      ]),
    );
  }
}

class _RoadPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final road = Paint()
      ..color = const Color(0x1AFFFFFF)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 34
      ..strokeCap = StrokeCap.round;
    final path = Path()
      ..moveTo(size.width - 190, size.height + 20)
      ..cubicTo(size.width - 140, size.height - 60, size.width - 80, size.height - 110, size.width + 20, size.height - 130);
    canvas.drawPath(path, road);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
