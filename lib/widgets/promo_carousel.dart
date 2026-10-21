import 'dart:async';

import 'package:flutter/material.dart';

import '../models/promo.dart';
import '../theme/app_colors.dart';
import 'promo_banner_widget.dart';

/// Carousel "Promo & Info" (geser otomatis tiap 4 detik).
class PromoCarousel extends StatefulWidget {
  const PromoCarousel({super.key, required this.promos});
  final List<Promo> promos;

  @override
  State<PromoCarousel> createState() => _PromoCarouselState();
}

class _PromoCarouselState extends State<PromoCarousel> {
  final _controller = PageController(viewportFraction: 0.92);
  Timer? _timer;
  int _index = 0;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 4), (_) {
      if (!_controller.hasClients || widget.promos.isEmpty) return;
      final next = (_index + 1) % widget.promos.length;
      _controller.animateToPage(next, duration: const Duration(milliseconds: 400), curve: Curves.easeOut);
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      SizedBox(
        height: 188,
        child: PageView.builder(
          controller: _controller,
          itemCount: widget.promos.length,
          onPageChanged: (i) => setState(() => _index = i),
          itemBuilder: (_, i) => Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: PromoBannerCard(promo: widget.promos[i], height: 188),
          ),
        ),
      ),
      const SizedBox(height: 8),
      Row(mainAxisAlignment: MainAxisAlignment.center, children: [
        for (var i = 0; i < widget.promos.length; i++)
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            margin: const EdgeInsets.symmetric(horizontal: 3),
            width: i == _index ? 22 : 8,
            height: 8,
            decoration: BoxDecoration(
              color: i == _index ? AppColors.teal : const Color(0xFFCED8D8),
              borderRadius: BorderRadius.circular(4),
            ),
          ),
      ]),
    ]);
  }
}
