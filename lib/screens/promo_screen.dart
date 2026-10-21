import 'package:flutter/material.dart';

import '../data/mock_data.dart';
import '../widgets/promo_banner_widget.dart';

class PromoScreen extends StatelessWidget {
  const PromoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final all = [...MockData.topPromos, ...MockData.midPromos];
    return Scaffold(
      appBar: AppBar(title: const Text('Promo & Info')),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: all.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (_, i) => PromoBannerCard(promo: all[i], height: 170),
      ),
    );
  }
}
