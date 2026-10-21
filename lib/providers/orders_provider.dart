import 'package:flutter/foundation.dart';

import '../models/booking_order.dart';
import '../services/trip_repository.dart';
import 'auth_provider.dart';

/// Daftar "Tiket Saya" milik akun yang sedang login.
/// Setiap kali akun berganti (login, logout, sesi kedaluwarsa) daftar dikosongkan,
/// lalu — jika ada token aktif — diisi ulang dari server (GET /api/orders), sehingga
/// yang tampil hanya tiket milik akun tersebut.
class OrdersProvider extends ChangeNotifier {
  OrdersProvider(this._auth, this._trips) : _owner = _auth.token {
    _auth.addListener(_onAuthChanged);
    if (_owner != null) refresh();
  }

  final AuthProvider _auth;
  final TripRepository _trips;
  String? _owner; // token pemilik daftar ini
  int _generation = 0; // naik tiap ganti akun; hasil fetch akun lama dibuang

  final List<BookingOrder> _orders = [];
  List<BookingOrder> get orders => List.unmodifiable(_orders);
  /// Hanya tiket berstatus aktif: belum di-scan dan jadwal belum lewat.
  int get activeCount => _orders.where((o) => o.isActive).length;

  /// Total nilai tiket yang dibayar (tiket dibatalkan tidak dihitung).
  int get totalSpent =>
      _orders.where((o) => o.status != TicketStatus.cancelled).fold(0, (sum, o) => sum + o.total);

  bool loading = false;
  String? error; // pesan gagal fetch terakhir (null jika berhasil)

  void _onAuthChanged() {
    if (_auth.token == _owner) return;
    _owner = _auth.token;
    _generation++;
    _orders.clear();
    loading = false;
    error = null;
    notifyListeners();
    if (_owner != null) refresh();
  }

  /// Tarik tiket akun yang sedang login dari server dan ganti isi daftar.
  /// Tiket lokal yang belum ada di server (mis. mode demo) tetap dipertahankan.
  Future<void> refresh() async {
    if (_owner == null || !_trips.useBackend) return;
    final gen = _generation;
    loading = true;
    error = null;
    notifyListeners();
    try {
      final data = await _trips.api.get('/api/orders') as List;
      final fetched = await _toOrders(
          [for (final e in data) Map<String, dynamic>.from(e as Map)]);
      if (gen != _generation)
        return; // akun sudah berganti selama request berjalan
      final codes = fetched.map((o) => o.code).toSet();
      final localOnly = _orders.where((o) => !codes.contains(o.code)).toList();
      _orders
        ..clear()
        ..addAll(localOnly)
        ..addAll(fetched);
    } catch (e) {
      if (gen != _generation) return;
      debugPrint('[Orders] gagal memuat tiket: ${e.runtimeType}: $e');
      error = '$e';
    }
    loading = false;
    notifyListeners();
  }

  /// JSON pesanan dari backend → [BookingOrder]. Status tiket, nama PO, kelas & jam berangkat
  /// datang dari respons pesanan; nama varian kursi & jam tiba dilengkapi dari GET /api/trips
  /// (satu kali per rute + tanggal). Backend lama tanpa field tersebut tetap didukung.
  Future<List<BookingOrder>> _toOrders(List<Map<String, dynamic>> list) async {
    final tripInfo = <String, Map<String, dynamic>>{};
    final searches = {
      for (final j in list) '${j['from']}|${j['to']}|${j['date']}': j
    };
    await Future.wait(searches.values.map((j) async {
      try {
        final trips = await _trips.api.get('/api/trips', {
          'from': '${j['from']}',
          'to': '${j['to']}',
          'date': '${j['date']}'
        }) as List;
        for (final t in trips) {
          final m = Map<String, dynamic>.from(t as Map);
          tripInfo['${m['id']}|${j['from']}|${j['to']}|${j['date']}'] = m;
        }
      } catch (e) {
        debugPrint(
            '[Orders] detail jadwal ${j['from']}→${j['to']} ${j['date']} gagal: $e');
      }
    }));

    return [
      for (final j in list)
        () {
          final t =
              tripInfo['${j['trip']}|${j['from']}|${j['to']}|${j['date']}'];
          final tiers = (t?['tiers'] as List? ?? const []).cast<Map>();
          final tier = tiers.where((x) => x['key'] == j['tierKey']).firstOrNull;
          final busClass = j['busClass'] as String? ?? t?['busClass'] as String? ?? '';
          final tierName =
              tier?['name'] as String? ?? (j['tierKey'] as String? ?? '');
          final payment =
              Map<String, dynamic>.from(j['payment'] as Map? ?? const {});
          return BookingOrder(
            code: j['code'] as String,
            poName: j['poName'] as String? ?? t?['poName'] as String? ?? '-',
            busClass:
                [busClass, tierName].where((s) => s.isNotEmpty).join(' · '),
            from: j['from'] as String? ?? '',
            to: j['to'] as String? ?? '',
            date:
                DateTime.tryParse(j['date'] as String? ?? '') ?? DateTime.now(),
            depart: j['depart'] as String? ?? t?['depart'] as String? ?? '-',
            arrive: t?['arrive'] as String? ?? '-',
            boardPoint: j['boardPoint'] as String? ?? '',
            dropPoint: j['dropPoint'] as String? ?? '',
            seats: (j['seats'] as List? ?? const []).cast<String>(),
            passengerNames:
                (j['passengers'] as List? ?? const []).cast<String>(),
            total: (j['total'] as num? ?? 0).toInt(),
            paymentMethod: _methodLabel(payment['method'] as String?),
            status: TicketStatus.fromApi(j['ticketStatus'] as String?) ??
                (j['status'] == 'paid' ? TicketStatus.active : TicketStatus.cancelled),
            validUntil: DateTime.tryParse(j['validUntil'] as String? ?? '')?.toLocal(),
          );
        }(),
    ];
  }

  static String _methodLabel(String? method) => switch (method) {
        'qris' => 'QRIS',
        'va_bca' => 'Virtual Account BCA',
        'va_bri' => 'Virtual Account BRI',
        _ => method ?? '-',
      };

  void add(BookingOrder order) {
    _orders.removeWhere((o) => o.code == order.code);
    _orders.insert(0, order);
    notifyListeners();
  }

  void cancel(String code) {
    final i = _orders.indexWhere((o) => o.code == code);
    if (i < 0) return;
    _orders[i] = _orders[i].copyWith(status: TicketStatus.cancelled);
    notifyListeners();
  }

  void clear() {
    if (_orders.isEmpty) return;
    _orders.clear();
    notifyListeners();
  }

  @override
  void dispose() {
    _auth.removeListener(_onAuthChanged);
    super.dispose();
  }
}
