import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/search_provider.dart';
import '../theme/app_colors.dart';
import '../utils/formatters.dart';
import '../widgets/quick_checkout_sheet.dart';
import '../widgets/trip_card_widget.dart';

class ResultsScreen extends StatelessWidget {
  const ResultsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final sp = context.watch<SearchProvider>();
    final q = sp.query;
    final trips = sp.results;

    return Scaffold(
      appBar: AppBar(
        title: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('${q.fromCity} → ${q.toCity}'),
          Text('${dateLabel(q.date)} · ${q.pax} penumpang',
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: Color(0xFFCFE9E6))),
        ]),
      ),
      body: Column(children: [
        SizedBox(
          height: 52,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 6),
            children: [
              for (final s in TripSort.values)
                Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                    label: Text(switch (s) {
                      TripSort.cheapest => 'Termurah',
                      TripSort.earliest => 'Paling awal',
                      TripSort.mostSeats => 'Kursi terbanyak',
                    }),
                    selected: sp.sort == s,
                    selectedColor: AppColors.tealSoft,
                    onSelected: (_) => sp.setSort(s),
                  ),
                ),
            ],
          ),
        ),
        Expanded(
          child: Builder(builder: (context) {
            if (sp.loading) return const Center(child: CircularProgressIndicator());
            if (sp.error != null) return Center(child: Text(sp.error!));
            if (trips.isEmpty) {
              return const Center(
                child: Padding(
                  padding: EdgeInsets.all(24),
                  child: Text('Belum ada jadwal untuk rute & tanggal ini.', textAlign: TextAlign.center),
                ),
              );
            }
            return ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: trips.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (context, i) {
                final t = trips[i];
                return TripCardWidget(
                  trip: t,
                  onTap: () => QuickCheckoutSheet.show(
                    context,
                    poId: t.poId,
                    poName: t.poName,
                    from: t.from,
                    to: t.to,
                    image: t.image ?? 'assets/images/cardbus_icon.png',
                    preferredClass: t.busClass,
                    initialDay: q.dayIndex,
                    initialTripId: t.id,
                  ),
                );
              },
            );
          }),
        ),
      ]),
    );
  }
}
