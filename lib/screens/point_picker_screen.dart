import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../data/mock_data.dart';
import '../models/city_point.dart';
import '../providers/search_provider.dart';
import '../theme/app_colors.dart';

/// Pilih titik naik / turun. Argumen route: true = asal, false = tujuan.
/// Titik favorit di atas, "Kota populer" di bawah.
class PointPickerScreen extends StatefulWidget {
  const PointPickerScreen({super.key});

  @override
  State<PointPickerScreen> createState() => _PointPickerScreenState();
}

class _PointPickerScreenState extends State<PointPickerScreen> {
  String _q = '';

  @override
  Widget build(BuildContext context) {
    final isFrom = (ModalRoute.of(context)?.settings.arguments as bool?) ?? true;
    final sp = context.read<SearchProvider>();
    final q = _q.toLowerCase();

    final pts = MockData.points
        .where((p) => q.isEmpty ? p.favorite : (p.name.toLowerCase().contains(q) || p.city.toLowerCase().contains(q)))
        .toList();
    final cities = MockData.cities.where((c) => q.isEmpty || c.toLowerCase().contains(q)).toList();

    void pickPoint(CityPoint p) {
      if (isFrom) {
        sp.setFrom(p.city, point: p.name);
      } else {
        sp.setTo(p.city, point: p.name);
      }
      Navigator.pop(context);
    }

    void pickCity(String c) {
      if (isFrom) {
        sp.setFrom(c);
      } else {
        sp.setTo(c);
      }
      Navigator.pop(context);
    }

    return Scaffold(
      appBar: AppBar(title: Text(isFrom ? 'Pilih titik naik' : 'Pilih titik turun')),
      body: Column(children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: TextField(
            autofocus: true,
            onChanged: (v) => setState(() => _q = v),
            decoration: const InputDecoration(prefixIcon: Icon(Icons.search_rounded), hintText: 'Cari terminal, agen, atau kota'),
          ),
        ),
        Expanded(
          child: ListView(children: [
            _header(q.isEmpty ? 'TITIK FAVORIT' : 'TITIK NAIK / TURUN'),
            for (final p in pts)
              ListTile(
                leading: const Icon(Icons.location_on_rounded, color: AppColors.teal),
                title: Text(p.name, style: const TextStyle(fontWeight: FontWeight.w700)),
                subtitle: Text('${p.city}${p.area.isEmpty ? '' : ' · ${p.area}'}'),
                onTap: () => pickPoint(p),
              ),
            _header('KOTA POPULER'),
            for (final c in cities)
              ListTile(
                leading: const Icon(Icons.location_city_rounded, color: AppColors.muted),
                title: Text(c, style: const TextStyle(fontWeight: FontWeight.w700)),
                subtitle: Text(isFrom ? 'Semua titik naik di $c' : 'Semua titik turun di $c'),
                onTap: () => pickCity(c),
              ),
          ]),
        ),
      ]),
    );
  }

  Widget _header(String text) => Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
        child: Text(text, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: AppColors.muted, letterSpacing: 0.5)),
      );
}
