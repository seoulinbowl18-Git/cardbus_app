import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/promo.dart';
import '../providers/search_provider.dart';
import '../theme/app_colors.dart';
import 'section_title.dart';
import 'tag_chip.dart';

/// Aksi tombol di banner: info "segera hadir" atau langsung cari rute.
void handlePromoTap(BuildContext context, Promo promo) {
  if (promo.soonMessage != null || !promo.hasRoute) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(promo.soonMessage ?? promo.title)));
    return;
  }
  context.read<SearchProvider>().searchRoute(promo.from!, promo.to!);
  Navigator.pushNamed(context, '/results');
}

/// Satu banner: foto + gradasi teal + teks + tombol emas.
class PromoBannerCard extends StatelessWidget {
  const PromoBannerCard({super.key, required this.promo, this.height = 150});

  final Promo promo;
  final double height;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(18),
      child: SizedBox(
        height: height,
        child: Stack(fit: StackFit.expand, children: [
          Image.asset(promo.image, fit: BoxFit.cover, errorBuilder: (_, __, ___) => Container(color: const Color(0xFFDCE4E4))),
          const DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xF0042E31), Color(0xB3042E31), Color(0x00042E31)],
                stops: [0, 0.5, 0.85],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
            child: FractionallySizedBox(
              widthFactor: 0.66,
              alignment: Alignment.centerLeft,
              child: Column(mainAxisAlignment: MainAxisAlignment.center, crossAxisAlignment: CrossAxisAlignment.start, children: [
                TagChip(promo.tag),
                const SizedBox(height: 4),
                Text(promo.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(color: AppColors.white, fontSize: 16, fontWeight: FontWeight.w800, height: 1.22)),
                const SizedBox(height: 2),
                Text(promo.subtitle,
                    maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(color: Color(0xFFDCEFEE), fontSize: 11)),
                const SizedBox(height: 6),
                Material(
                  color: AppColors.gold,
                  borderRadius: BorderRadius.circular(999),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(999),
                    onTap: () => handlePromoTap(context, promo),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                      child: Text('${promo.ctaLabel} →',
                          style: const TextStyle(color: AppColors.ink, fontSize: 12, fontWeight: FontWeight.w800)),
                    ),
                  ),
                ),
              ]),
            ),
          ),
        ]),
      ),
    );
  }
}

/// "Promo spesial" — banner geser di bawah Produk unggulan.
class PromoSpecialSection extends StatelessWidget {
  const PromoSpecialSection({super.key, required this.promos});
  final List<Promo> promos;

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.sizeOf(context).width * 0.84;
    return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      SectionTitle(
        title: 'Promo spesial',
        trailing: Text('${promos.length} promo', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: AppColors.teal)),
      ),
      const SizedBox(height: 10),
      SizedBox(
        height: 150,
        child: ListView.separated(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          scrollDirection: Axis.horizontal,
          itemCount: promos.length,
          separatorBuilder: (_, __) => const SizedBox(width: 10),
          itemBuilder: (_, i) => SizedBox(width: w, child: PromoBannerCard(promo: promos[i])),
        ),
      ),
    ]);
  }
}
