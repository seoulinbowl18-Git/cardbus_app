import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

/// Menu bawah: Beranda · Tiket Saya · Promo · Akun.
class CardBusBottomNav extends StatelessWidget {
  const CardBusBottomNav({super.key, required this.currentIndex, required this.onTap, this.ticketBadge = 0});

  final int currentIndex;
  final ValueChanged<int> onTap;
  final int ticketBadge;

  @override
  Widget build(BuildContext context) {
    final items = [
      (Icons.home_rounded, 'Beranda'),
      (Icons.confirmation_number_outlined, ticketBadge > 0 ? 'Tiket Saya ($ticketBadge)' : 'Tiket Saya'),
      (Icons.card_giftcard_rounded, 'Promo'),
      (Icons.person_rounded, 'Akun'),
    ];
    return Container(
      decoration: const BoxDecoration(color: AppColors.white, border: Border(top: BorderSide(color: AppColors.border))),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 60,
          child: Row(children: [
            for (var i = 0; i < items.length; i++)
              Expanded(
                child: InkWell(
                  onTap: () => onTap(i),
                  child: Stack(alignment: Alignment.center, children: [
                    Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                      Icon(items[i].$1, color: i == currentIndex ? AppColors.teal : AppColors.faint),
                      const SizedBox(height: 2),
                      Text(items[i].$2,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: i == currentIndex ? FontWeight.w800 : FontWeight.w600,
                            color: i == currentIndex ? AppColors.teal : AppColors.faint,
                          )),
                    ]),
                    if (i == currentIndex)
                      Positioned(
                        bottom: 0,
                        child: Container(
                          width: 44,
                          height: 3,
                          decoration: BoxDecoration(color: AppColors.teal, borderRadius: BorderRadius.circular(2)),
                        ),
                      ),
                  ]),
                ),
              ),
          ]),
        ),
      ),
    );
  }
}
