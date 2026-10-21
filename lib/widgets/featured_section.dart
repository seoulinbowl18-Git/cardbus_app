import 'package:flutter/material.dart';

import '../models/featured_product.dart';
import 'promo_card_widget.dart';
import 'quick_checkout_sheet.dart';
import 'section_title.dart';

/// "Produk unggulan" — grid 2 kolom, ketuk kartu = panel checkout cepat.
class FeaturedSection extends StatelessWidget {
  const FeaturedSection({super.key, required this.products});
  final List<FeaturedProduct> products;

  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      SectionTitle(
        title: 'Produk unggulan',
        subtitle: 'Rute favorit dari PO mitra CardBus',
        trailing: Text('${products.length} rute',
            style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: Theme.of(context).colorScheme.primary)),
      ),
      const SizedBox(height: 10),
      GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: products.length,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: 10,
          crossAxisSpacing: 10,
          mainAxisExtent: 316,
        ),
        itemBuilder: (context, i) {
          final p = products[i];
          return PromoCardWidget(
            product: p,
            onTap: () {
              if (p.comingSoon || p.poId == null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('PO ${p.poName} ${p.from} → ${p.to}: jadwal segera hadir di CardBus')),
                );
                return;
              }
              QuickCheckoutSheet.show(
                context,
                poId: p.poId!,
                poName: p.poName,
                from: p.from,
                to: p.to,
                image: p.image,
                preferredClass: p.busClass,
              );
            },
          );
        },
      ),
    ]);
  }
}
