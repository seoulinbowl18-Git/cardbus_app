import 'package:flutter/material.dart';

import '../data/mock_data.dart';
import '../models/trip.dart';
import '../theme/app_colors.dart';
import '../utils/formatters.dart';
import 'po_badge.dart';

/// Kartu jadwal di halaman hasil pencarian.
class TripCardWidget extends StatelessWidget {
  const TripCardWidget({super.key, required this.trip, required this.onTap});

  final Trip trip;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final t = trip;
    final product = MockData.featured.where((f) => f.poId == t.poId).toList();
    final logo = product.isEmpty ? null : product.first.logo;
    final color = product.isEmpty ? AppColors.teal : product.first.poColor;
    final short = t.poName.substring(0, 2).toUpperCase();

    return Material(
      color: AppColors.white,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(border: Border.all(color: AppColors.border), borderRadius: BorderRadius.circular(16)),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              PoBadge(short: short, color: color, logo: logo, size: 40, radius: 10),
              const SizedBox(width: 10),
              Expanded(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text('PO ${t.poName}', style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15)),
                  Text(t.busClass, style: const TextStyle(fontSize: 12, color: AppColors.muted)),
                ]),
              ),
              Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                if (t.oldPrice != null)
                  Text(rupiah(t.oldPrice!), style: const TextStyle(fontSize: 11, color: AppColors.faint, decoration: TextDecoration.lineThrough)),
                Text(rupiah(t.minPrice),
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: t.oldPrice != null ? AppColors.promoRed : AppColors.teal)),
                const Text('/kursi', style: TextStyle(fontSize: 10, color: AppColors.faint)),
              ]),
            ]),
            const SizedBox(height: 12),
            Row(children: [
              _time(t.depart, t.boardPoint, CrossAxisAlignment.start),
              Expanded(
                child: Column(children: [
                  Text(t.duration, style: const TextStyle(fontSize: 11, color: AppColors.muted)),
                  const Divider(color: AppColors.border, indent: 8, endIndent: 8),
                ]),
              ),
              _time(t.arrive, t.dropPoint, CrossAxisAlignment.end),
            ]),
            const SizedBox(height: 8),
            Row(children: [
              Icon(Icons.event_seat_rounded, size: 16, color: t.seatsLeft < 6 ? AppColors.error : AppColors.teal),
              const SizedBox(width: 4),
              Text('Sisa ${t.seatsLeft} kursi',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: t.seatsLeft < 6 ? AppColors.error : AppColors.ink)),
              const Spacer(),
              const Text('Pilih →', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: AppColors.teal)),
            ]),
          ]),
        ),
      ),
    );
  }

  Widget _time(String time, String place, CrossAxisAlignment align) => SizedBox(
        width: 110,
        child: Column(crossAxisAlignment: align, children: [
          Text(time, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w800)),
          Text(place, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 11, color: AppColors.muted)),
        ]),
      );
}
