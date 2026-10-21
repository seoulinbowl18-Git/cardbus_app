import 'dart:math';

import 'package:flutter/foundation.dart';

import '../models/booking_order.dart';
import '../models/trip.dart';
import 'auth_provider.dart';

enum PayMethod { qris, vaBca, vaBri }

extension PayMethodLabel on PayMethod {
  String get label => switch (this) {
        PayMethod.qris => 'QRIS',
        PayMethod.vaBca => 'Virtual Account BCA',
        PayMethod.vaBri => 'Virtual Account BRI',
      };
  String get subtitle => switch (this) {
        PayMethod.qris => 'Semua e-wallet & mobile banking',
        _ => 'Verifikasi otomatis',
      };

  /// Kode metode di API backend (POST /api/payments/create).
  String get apiValue => switch (this) {
        PayMethod.qris => 'qris',
        PayMethod.vaBca => 'va_bca',
        PayMethod.vaBri => 'va_bri',
      };
}

/// Menyimpan pilihan dari panel checkout cepat sampai e-tiket terbit (hanya di memori).
/// Dikosongkan total setiap kali akun berganti / logout, agar kontak & penumpang
/// pemesan sebelumnya tidak terbawa ke akun lain.
class CheckoutProvider extends ChangeNotifier {
  CheckoutProvider(this._auth) : _owner = _auth.token {
    _auth.addListener(_onAuthChanged);
  }

  final AuthProvider _auth;
  String? _owner; // token pemilik checkout ini

  void _onAuthChanged() {
    if (_auth.token == _owner) return;
    _owner = _auth.token;
    clear();
  }

  @override
  void dispose() {
    _auth.removeListener(_onAuthChanged);
    super.dispose();
  }

  Trip? trip;
  SeatTier? tier;
  List<String> seats = [];
  List<String> names = [];
  String phone = '';
  String email = '';
  PayMethod method = PayMethod.qris;

  int get pax => seats.length;
  int get total => (tier?.price ?? 0) * pax;
  bool get ready => trip != null && tier != null && seats.isNotEmpty;

  void start({required Trip trip, required SeatTier tier, required List<String> seats, String? firstName}) {
    this.trip = trip;
    this.tier = tier;
    this.seats = [...seats];
    names = List<String>.filled(seats.length, '');
    if (firstName != null && firstName.isNotEmpty) names[0] = firstName;
    // Kontak diisi ulang dari profil server di halaman Data penumpang.
    phone = '';
    email = '';
    notifyListeners();
  }

  void setName(int index, String value) {
    names[index] = value;
  }

  void setMethod(PayMethod value) {
    method = value;
    notifyListeners();
  }

  /// Isi POST /api/payments/create. Harga tidak dikirim: server menghitungnya sendiri.
  Map<String, dynamic> toPaymentRequest() => {
        'tripId': trip!.id,
        'date': trip!.date.toIso8601String().substring(0, 10),
        'from': trip!.from,
        'to': trip!.to,
        'tierKey': tier!.key,
        'seats': seats,
        'passengers': [for (final n in names) {'name': n.trim()}],
        'contact': {'phone': phone, 'email': email},
        'method': method.apiValue,
      };

  /// E-tiket setelah LUNAS. [code] & [paidTotal] dari server; tanpa itu (mode demo) kode diacak.
  BookingOrder buildPaidOrder({String? code, int? paidTotal}) {
    final t = trip!;
    code ??= List.generate(6, (_) => 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789'[Random().nextInt(32)]).join();
    return BookingOrder(
      code: code,
      poName: t.poName,
      busClass: '${t.busClass} · ${tier!.name}',
      from: t.from,
      to: t.to,
      date: t.date,
      depart: t.depart,
      arrive: t.arrive,
      boardPoint: t.boardPoint,
      dropPoint: t.dropPoint,
      seats: seats,
      passengerNames: names.map((n) => n.trim()).toList(),
      total: paidTotal ?? total,
      paymentMethod: method.label,
    );
  }

  void clear() {
    trip = null;
    tier = null;
    seats = [];
    names = [];
    phone = '';
    email = '';
    method = PayMethod.qris;
    notifyListeners();
  }
}
