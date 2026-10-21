import 'package:flutter/material.dart';

import '../models/featured_product.dart';
import '../theme/app_colors.dart';
import '../utils/formatters.dart';
import 'po_badge.dart';
import 'tag_chip.dart';

/// Kartu produk ala e-commerce: foto, label, logo PO, kelas, rute, harga, tombol Pesan.
class PromoCardWidget extends StatelessWidget {
  const PromoCardWidget({super.key, required this.product, required this.onTap});

  final FeaturedProduct product;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final p = product;
    final priceColor = p.comingSoon ? AppColors.muted : (p.oldPrice != null ? AppColors.promoRed : AppColors.teal);

    return Material(
      color: AppColors.white,
      borderRadius: BorderRadius.circular(16),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            border: Border.all(color: AppColors.border),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            SizedBox(
              height: 112,
              child: Stack(clipBehavior: Clip.none, fit: StackFit.expand, children: [
                Image.asset(p.image, fit: BoxFit.cover, errorBuilder: (_, __, ___) => Container(color: const Color(0xFFDCE4E4))),
                Positioned(left: 8, top: 8, child: TagChip(p.tag)),
                Positioned(left: 8, bottom: -14, child: PoBadge(short: p.poShort, color: p.poColor, logo: p.logo)),
              ]),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(10, 18, 10, 10),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text('PO ${p.poName} · ${p.busClass}',
                      maxLines: 1, overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 11, color: AppColors.muted, fontWeight: FontWeight.w700)),
                  const SizedBox(height: 6),
                  _routeLine(p.from, AppColors.teal),
                  Container(width: 2, height: 6, margin: const EdgeInsets.only(left: 3), color: const Color(0xFFCED8D8)),
                  _routeLine(p.to, AppColors.gold),
                  const SizedBox(height: 6),
                  Text('Titik naik: ${p.boardPoint}',
                      maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 11, color: AppColors.muted)),
                  const Spacer(),
                  const Divider(height: 12, color: Color(0xFFDCE4E4)),
                  Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
                    Expanded(
                      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Text(p.comingSoon ? 'Jadwal' : 'Mulai dari',
                            style: const TextStyle(fontSize: 10, color: AppColors.faint, fontWeight: FontWeight.w600)),
                        if (p.oldPrice != null)
                          Text(rupiah(p.oldPrice!),
                              style: const TextStyle(fontSize: 11, color: AppColors.faint, decoration: TextDecoration.lineThrough)),
                        FittedBox(
                          fit: BoxFit.scaleDown,
                          alignment: Alignment.centerLeft,
                          child: Text(p.comingSoon ? 'Segera hadir' : rupiah(p.price ?? 0),
                              style: TextStyle(fontSize: p.comingSoon ? 12 : 14, fontWeight: FontWeight.w800, color: priceColor)),
                        ),
                      ]),
                    ),
                    Container(
                      height: 30,
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: p.comingSoon ? AppColors.tealSoft : AppColors.teal,
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(p.comingSoon ? 'Info' : 'Pesan',
                          style: TextStyle(
                              fontSize: 12, fontWeight: FontWeight.w800, color: p.comingSoon ? AppColors.teal : AppColors.white)),
                    ),
                  ]),
                ]),
              ),
            ),
          ]),
        ),
      ),
    );
  }

  Widget _routeLine(String city, Color dot) => Row(children: [
        Container(width: 8, height: 8, decoration: BoxDecoration(color: dot, shape: BoxShape.circle)),
        const SizedBox(width: 6),
        Expanded(child: Text(city, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800))),
      ]);
}
