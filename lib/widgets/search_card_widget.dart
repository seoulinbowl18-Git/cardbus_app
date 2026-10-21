import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/search_provider.dart';
import '../theme/app_colors.dart';
import '../theme/app_theme.dart';
import '../utils/formatters.dart';
import 'date_chips.dart';
import 'location_field.dart';
import 'pax_stepper.dart';

/// Kartu putih "Dari / Ke / Tanggal / Penumpang / Cari tiket".
class SearchCardWidget extends StatelessWidget {
  const SearchCardWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final sp = context.watch<SearchProvider>();
    final q = sp.query;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: const [BoxShadow(color: Color(0x24064E52), blurRadius: 32, offset: Offset(0, 12))],
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        Stack(children: [
          Column(children: [
            LocationField(
              label: 'Dari',
              title: q.fromPoint ?? q.fromCity,
              subtitle: q.fromPoint == null ? 'Semua titik naik di ${q.fromCity}' : q.fromCity,
              pinColor: AppColors.teal,
              onTap: () => Navigator.pushNamed(context, '/point-picker', arguments: true),
            ),
            const SizedBox(height: 10),
            LocationField(
              label: 'Ke',
              title: q.toPoint ?? q.toCity,
              subtitle: q.toPoint == null ? 'Semua titik turun di ${q.toCity}' : q.toCity,
              pinColor: AppColors.gold,
              onTap: () => Navigator.pushNamed(context, '/point-picker', arguments: false),
            ),
          ]),
          Positioned(
            right: 12,
            top: 0,
            bottom: 0,
            child: Center(
              child: Material(
                color: const Color(0xFFD9F0EE),
                shape: const CircleBorder(side: BorderSide(color: AppColors.white, width: 3)),
                elevation: 2,
                child: IconButton(
                  tooltip: 'Tukar asal dan tujuan',
                  onPressed: sp.swap,
                  icon: const Icon(Icons.swap_vert_rounded, color: AppColors.teal),
                ),
              ),
            ),
          ),
        ]),
        if (q.isSameCity)
          const Padding(
            padding: EdgeInsets.only(top: 8),
            child: Text('Kota asal dan tujuan tidak boleh sama.',
                style: TextStyle(fontSize: 12, color: AppColors.error, fontWeight: FontWeight.w600)),
          ),
        const SizedBox(height: 12),
        Row(children: [
          const Icon(Icons.calendar_month_rounded, size: 16, color: AppColors.teal),
          const SizedBox(width: 6),
          const Text('Tanggal berangkat · ', style: TextStyle(fontSize: 12, color: AppColors.muted, fontWeight: FontWeight.w700)),
          Text(dateLabel(q.date), style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
        ]),
        const SizedBox(height: 6),
        DateChips(selected: q.dayIndex, onSelect: sp.setDay),
        const SizedBox(height: 12),
        PaxStepper(value: q.pax, onMinus: sp.decPax, onPlus: sp.incPax),
        const SizedBox(height: 12),
        ElevatedButton.icon(
          style: goldButtonStyle(),
          onPressed: q.isSameCity
              ? null
              : () {
                  sp.search();
                  Navigator.pushNamed(context, '/results');
                },
          icon: const Icon(Icons.search_rounded),
          label: const Text('Cari tiket'),
        ),
      ]),
    );
  }
}
