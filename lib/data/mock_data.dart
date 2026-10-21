import 'dart:math';

import 'package:flutter/material.dart';

import '../models/city_point.dart';
import '../models/featured_product.dart';
import '../models/promo.dart';
import '../models/trip.dart';
import '../utils/formatters.dart';

/// DATA CONTOH untuk prototipe. Di produksi semua data ini datang dari backend
/// (GET /trips, GET /featured, GET /promos). Harga yang tidak dari brosur PO
/// ditandai "contoh" — ganti dengan tarif resmi.
class MockData {
  MockData._();

  static const img = 'assets/images/';

  // ---------------- Kota & titik naik ----------------
  static const cities = [
    'Solo', 'Wonogiri', 'Jakarta', 'Tangerang', 'Bogor', 'Bekasi', 'Depok',
    'Semarang', 'Malang', 'Yogyakarta', 'Surabaya', 'Pekanbaru', 'Bengkulu',
  ];

  static const points = <CityPoint>[
    CityPoint(name: 'Terminal Tirtonadi', city: 'Solo', area: 'Banjarsari'),
    CityPoint(name: 'Tugu Kartosuro', city: 'Solo', area: 'Kartasura'),
    CityPoint(name: 'Pasar Wonogiri', city: 'Wonogiri', area: 'Kota Wonogiri'),
    CityPoint(name: 'Terminal Wonogiri', city: 'Wonogiri', area: 'Giritirto'),
    CityPoint(name: 'Ngadirojo', city: 'Wonogiri', area: 'Ngadirojo'),
    CityPoint(name: 'Jatisrono', city: 'Wonogiri', area: 'Jatisrono'),
    CityPoint(name: 'Purwantoro', city: 'Wonogiri', area: 'Purwantoro'),
    CityPoint(name: 'Batu', city: 'Wonogiri', area: 'Batuwarno'),
    CityPoint(name: 'Terminal Pulo Gebang', city: 'Jakarta', area: 'Jakarta Timur'),
    CityPoint(name: 'Terminal Lebak Bulus', city: 'Jakarta', area: 'Jakarta Selatan'),
    CityPoint(name: 'Pasar Rebo', city: 'Jakarta', area: 'Jakarta Timur', favorite: false),
    CityPoint(name: 'Terminal Poris Plawad', city: 'Tangerang', area: 'Cipondoh'),
    CityPoint(name: 'BSD', city: 'Tangerang', area: 'Serpong', favorite: false),
    CityPoint(name: 'Terminal Baranangsiang', city: 'Bogor', area: 'Bogor Timur'),
    CityPoint(name: 'Bekasi Timur', city: 'Bekasi', area: 'Bekasi Timur'),
    CityPoint(name: 'Jatiwarna', city: 'Bekasi', area: 'Pondok Melati', favorite: false),
    CityPoint(name: 'Terminal Arjosari', city: 'Malang', area: 'Blimbing'),
    CityPoint(name: 'Terminal Mangkang', city: 'Semarang', area: 'Tugu', favorite: false),
  ];

  static List<CityPoint> pointsOf(String city) => points.where((p) => p.city == city).toList();

  // ---------------- Produk unggulan (kartu e-commerce) ----------------
  static const featured = <FeaturedProduct>[
    FeaturedProduct(
      id: 'san-pku', poName: 'SAN', poShort: 'SAN', poColor: Color(0xFF1E3A8A),
      image: '${img}san_jetbus5.jpg', busClass: 'Jetbus 5 SHD · Madar Class',
      from: 'Solo', to: 'Pekanbaru', boardPoint: 'Solo', tag: 'BARU', comingSoon: true,
    ),
    FeaturedProduct(
      id: 'san-bkl', poName: 'SAN', poShort: 'SAN', poColor: Color(0xFF1E3A8A),
      image: '${img}san_silver.jpg', busClass: 'Bus Malam',
      from: 'Solo', to: 'Bengkulu', boardPoint: 'Solo', tag: 'BARU', comingSoon: true,
    ),
    FeaturedProduct(
      id: 'mh-dd', poId: 'mh', poName: 'Mahardhika', poShort: 'MH', poColor: Color(0xFFC8102E),
      logo: '${img}logo_mahardhika.png', image: '${img}mahardhika_dd.jpg', busClass: 'Double Decker',
      from: 'Wonogiri', to: 'Jakarta', boardPoint: 'Pasar Wonogiri', price: 300000, tag: 'TERLARIS',
    ),
    FeaturedProduct(
      id: 'ry-junior', poId: 'ry', poName: 'Raya', poShort: 'RY', poColor: Color(0xFFC2410C),
      logo: '${img}logo_raya.png', image: '${img}raya_promo.jpg', busClass: 'Junior',
      from: 'Solo', to: 'Bogor', boardPoint: 'Terminal Tirtonadi', price: 230000, oldPrice: 260000, tag: 'PROMO',
    ),
    FeaturedProduct(
      id: 'gr-dd', poId: 'gr', poName: 'Garuda Mas', poShort: 'GR', poColor: Color(0xFF0E7490),
      image: '${img}garudamas_dd.jpg', busClass: 'Double Decker Sleeper',
      from: 'Tangerang', to: 'Malang', boardPoint: 'Terminal Poris Plawad', price: 400000, tag: 'SLEEPER',
    ),
    FeaturedProduct(
      id: 'am-exe', poId: 'am', poName: 'Agra Mas', poShort: 'AM', poColor: Color(0xFFC8102E),
      logo: '${img}logo_agramas.png', image: '${img}agramas_red.jpg', busClass: 'Executive',
      from: 'Tangerang', to: 'Solo', boardPoint: 'Terminal Poris Plawad', price: 255000, tag: 'FAVORIT',
    ),
  ];

  // ---------------- Banner ----------------
  static const topPromos = <Promo>[
    Promo(image: '${img}garudamas_dd2.jpg', tag: 'RUTE BARU · GARUDA MAS', title: 'Poris ↔ Malang Double Decker Sleeper',
        subtitle: 'Poris 14.00 WIB', from: 'Tangerang', to: 'Malang', ctaLabel: 'Cek Sekarang'),
    Promo(image: '${img}raya_promo.jpg', tag: 'PROMO PO RAYA', title: 'Solo → Bogor makin hoki',
        subtitle: 'Rp 230.000 (normal Rp 260.000) · S&K berlaku', from: 'Solo', to: 'Bogor', ctaLabel: 'Cek Sekarang'),
    Promo(image: '${img}agramas_dd.jpg', tag: 'MITRA PO', title: 'Agra Mas kini bisa dipesan di sini',
        subtitle: 'Pilih kursi langsung, tanpa ke agen', from: 'Tangerang', to: 'Solo', ctaLabel: 'Cek Sekarang'),
  ];

  static const midPromos = <Promo>[
    Promo(image: '${img}san_jetbus5.jpg', tag: 'SEGERA HADIR', title: 'Solo → Sumatera bareng PO SAN',
        subtitle: 'Pekanbaru · Bengkulu · Jetbus 5 SHD', ctaLabel: 'Info',
        soonMessage: 'PO SAN Solo → Sumatera: jadwal segera hadir di CardBus'),
    Promo(image: '${img}raya_supertop.jpg', tag: 'PROMO', title: 'Hemat [X%] kelas Super Top',
        subtitle: 'Kode [KODEPROMO] · S&K berlaku', from: 'Solo', to: 'Jakarta'),
    Promo(image: '${img}mahardhika_suite.jpg', tag: 'KELAS BARU', title: 'Suite Combi Mahardhika',
        subtitle: 'Exe Plus + Sleeper · Wonogiri → Tangerang', from: 'Wonogiri', to: 'Tangerang'),
  ];

  // ---------------- Jadwal (template) ----------------
  static List<String> seatGrid(int fromRow, int toRow, List<String> letters) => [
        for (var r = fromRow; r <= toRow; r++)
          for (final l in letters) '$r$l',
      ];

  static final templates = <_TripTemplate>[
    // ---- Mahardhika ----
    _TripTemplate('mh', 'Mahardhika', 'Executive Class', '17:30', _mhRoutes, [
      _Tier('base', 'Executive', 275000, seatGrid(1, 8, ['A', 'B', 'C', 'D'])),
    ], ['ac', 'toilet', 'selimut', 'usb'], '${img}mahardhika_dd.jpg'),
    _TripTemplate('mh', 'Mahardhika', 'Tronton', '18:15', _mhRoutes, [
      _Tier('gc', 'Grand Captain', 475000, seatGrid(1, 4, ['A', 'C'])),
      _Tier('exe', 'Executive', 300000, seatGrid(5, 10, ['A', 'B', 'C', 'D'])),
    ], ['ac', 'toilet', 'legrest', 'makan'], '${img}mahardhika_dd.jpg'),
    _TripTemplate('mh', 'Mahardhika', 'Double Decker', '19:45', _mhRoutes, [
      _Tier('sleeper', 'Sleeper privat', 475000, ['K1', 'K2']),
      _Tier('bawah', 'Bawah exe', 360000, seatGrid(1, 2, ['A', 'B', 'C', 'D'])),
      _Tier('atas', 'Exe atas', 300000, seatGrid(3, 10, ['A', 'B', 'C', 'D'])),
    ], ['ac', 'toilet', 'tv', 'makan', 'selimut'], '${img}mahardhika_dd.jpg'),
    _TripTemplate('mh', 'Mahardhika', 'Suite Combi', '20:30', _mhRoutes, [
      _Tier('exeplus', 'Exe Plus', 300000, seatGrid(1, 4, ['A', 'B', 'C', 'D'])),
      _Tier('single', 'Sleeper single', 380000, seatGrid(5, 7, ['A'])),
      _Tier('double', 'Sleeper double', 350000, seatGrid(5, 7, ['C', 'D'])),
    ], ['ac', 'toilet', 'kompartemen', 'makan'], '${img}mahardhika_suite.jpg'),

    // ---- Raya (Super Top/Exe/Junior: harga contoh kecuali promo Solo→Bogor) ----
    _TripTemplate('ry', 'Raya', 'Super Top', '16:00', _ryRoutes, [
      _Tier('base', 'Super Top', 380000, seatGrid(1, 7, ['A', 'B', 'C'])),
    ], ['ac', 'toilet', 'legrest', 'makan', 'selimut'], '${img}raya_supertop.jpg'),
    _TripTemplate('ry', 'Raya', 'Executive 24', '16:30', _ryRoutes, [
      _Tier('base', 'Executive 24', 330000, seatGrid(1, 8, ['A', 'B', 'C'])),
    ], ['ac', 'toilet', 'makan'], '${img}raya_supertop.jpg'),
    _TripTemplate('ry', 'Raya', 'Junior', '17:30', _ryRoutes, [
      _Tier('base', 'Junior', 260000, seatGrid(1, 8, ['A', 'B', 'C', 'D'])),
    ], ['ac', 'toilet'], '${img}raya_promo.jpg', promo: const {'Solo>Bogor': 230000}),

    // ---- Garuda Mas (harga contoh) ----
    _TripTemplate('gr', 'Garuda Mas', 'Double Decker Sleeper', '14:00', const [
      _Route('Tangerang', 'Malang', 'Terminal Poris Plawad', 'Terminal Arjosari', 900),
      _Route('Jakarta', 'Malang', 'Terminal Pulo Gebang', 'Terminal Arjosari', 870),
    ], [
      _Tier('exe', 'Eksekutif', 400000, seatGrid(1, 6, ['A', 'B', 'C', 'D'])),
      _Tier('sleeper', 'Sleeper', 600000, seatGrid(1, 8, ['S'])),
    ], ['ac', 'toilet', 'selimut', 'makan'], '${img}garudamas_dd.jpg'),

    // ---- Agra Mas ----
    _TripTemplate('am', 'Agra Mas', 'Executive', '16:00', _amRoutes, [
      _Tier('base', 'Executive', 255000, seatGrid(1, 9, ['A', 'B', 'C', 'D'])),
    ], ['ac', 'toilet', 'selimut'], '${img}agramas_red.jpg'),
    _TripTemplate('am', 'Agra Mas', 'Double Decker', '17:00', _amRoutes, [
      _Tier('base', 'Double Decker', 280000, seatGrid(1, 11, ['A', 'B', 'C', 'D'])),
    ], ['ac', 'toilet', 'tv', 'selimut'], '${img}agramas_dd.jpg'),
  ];

  static const _mhRoutes = [
    _Route('Wonogiri', 'Jakarta', 'Pasar Wonogiri', 'Terminal Lebak Bulus', 665),
    _Route('Wonogiri', 'Bogor', 'Pasar Wonogiri', 'Terminal Baranangsiang', 690),
    _Route('Wonogiri', 'Tangerang', 'Pasar Wonogiri', 'Terminal Poris Plawad', 700),
  ];
  static const _ryRoutes = [
    _Route('Solo', 'Jakarta', 'Terminal Tirtonadi', 'Terminal Pulo Gebang', 600),
    _Route('Solo', 'Bogor', 'Terminal Tirtonadi', 'Terminal Baranangsiang', 640),
  ];
  static const _amRoutes = [
    _Route('Tangerang', 'Solo', 'Terminal Poris Plawad', 'Tugu Kartosuro', 620),
    _Route('Jakarta', 'Solo', 'Terminal Pulo Gebang', 'Tugu Kartosuro', 600),
    _Route('Bogor', 'Wonogiri', 'Terminal Baranangsiang', 'Pasar Wonogiri', 690),
  ];

  /// Membuat daftar jadwal untuk rute & tanggal tertentu.
  /// Kursi terisi diacak tetap (seeded) supaya tampilannya konsisten.
  static List<Trip> generateTrips(String from, String to, DateTime date, {String? boardPoint, String? dropPoint}) {
    final out = <Trip>[];
    final dateKey = date.toIso8601String().substring(0, 10);
    for (final t in templates) {
      _Route? route;
      var reversed = false;
      for (final r in t.routes) {
        if (r.a == from && r.b == to) route = r;
        if (r.b == from && r.a == to) {
          route = r;
          reversed = true;
        }
      }
      if (route == null) continue;

      final id = '${t.poId}-${t.busClass}-$from-$to-$dateKey';
      final rnd = Random(_stableHash(id));
      final promoPrice = t.promo['$from>$to'];
      int? oldPrice;
      final tiers = <SeatTier>[];
      for (var i = 0; i < t.tiers.length; i++) {
        final tier = t.tiers[i];
        var price = tier.price;
        if (promoPrice != null && i == 0) {
          oldPrice = tier.price;
          price = promoPrice;
        }
        tiers.add(SeatTier(
          key: tier.key,
          name: tier.name,
          price: price,
          freeSeats: tier.seats.where((_) => rnd.nextDouble() > 0.38).toList(),
        ));
      }
      out.add(Trip(
        id: id,
        poId: t.poId,
        poName: t.poName,
        busClass: t.busClass,
        from: from,
        to: to,
        date: date,
        depart: t.depart,
        arrive: addMinutes(t.depart, route.minutes),
        duration: durationLabel(route.minutes),
        boardPoint: boardPoint ?? (reversed ? route.boardB : route.boardA),
        dropPoint: dropPoint ?? (reversed ? route.boardA : route.boardB),
        tiers: tiers,
        oldPrice: oldPrice,
        facilities: t.facilities,
        image: t.image,
      ));
    }
    out.sort((a, b) => a.depart.compareTo(b.depart));
    return out;
  }

  /// Foto & fasilitas bus (belum ada di backend) untuk jadwal dari API, dicocokkan per PO + kelas.
  static ({List<String> facilities, String? image}) lookOf(String poId, String busClass) {
    for (final t in templates) {
      if (t.poId == poId && t.busClass == busClass) return (facilities: t.facilities, image: t.image);
    }
    return (facilities: const <String>[], image: null);
  }

  static int _stableHash(String s) {
    var h = 0x811c9dc5;
    for (final c in s.codeUnits) {
      h ^= c;
      h = (h * 0x01000193) & 0x7fffffff;
    }
    return h;
  }
}

class _Tier {
  const _Tier(this.key, this.name, this.price, this.seats);
  final String key;
  final String name;
  final int price;
  final List<String> seats;
}

class _Route {
  const _Route(this.a, this.b, this.boardA, this.boardB, this.minutes);
  final String a;
  final String b;
  final String boardA;
  final String boardB;
  final int minutes;
}

class _TripTemplate {
  const _TripTemplate(this.poId, this.poName, this.busClass, this.depart, this.routes, this.tiers, this.facilities, this.image,
      {this.promo = const {}});
  final String poId;
  final String poName;
  final String busClass;
  final String depart;
  final List<_Route> routes;
  final List<_Tier> tiers;
  final List<String> facilities;
  final String image;
  final Map<String, int> promo; // 'Asal>Tujuan' : harga promo
}
