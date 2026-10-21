import '../data/mock_data.dart';
import '../models/ticket_search_model.dart';
import '../models/trip.dart';
import '../utils/formatters.dart';
import 'api_service.dart';

/// Satu pintu untuk data jadwal. Default dari backend (GET /api/trips): harga & kursi kosong
/// dihitung server, sehingga jadwal yang tampil bisa langsung dibayar lewat Komerce.
/// [useBackend] = false memakai MockData (demo tanpa backend; tidak bisa dibayar).
class TripRepository {
  TripRepository(this.api, {this.useBackend = true});

  final ApiService api;
  final bool useBackend;

  Future<List<Trip>> searchTrips(TicketSearchModel q) async {
    if (useBackend) {
      final data = await api.get('/api/trips', q.toQuery()) as List;
      return data.map((e) => tripFromJson(Map<String, dynamic>.from(e as Map))).toList();
    }
    await Future<void>.delayed(const Duration(milliseconds: 250));
    return MockData.generateTrips(q.fromCity, q.toCity, q.date, boardPoint: q.fromPoint, dropPoint: q.toPoint);
  }

  /// Jadwal satu PO saja (dipakai panel checkout cepat).
  Future<List<Trip>> tripsOfPo(String poId, String from, String to, int dayIndex) async {
    final all = await searchTrips(TicketSearchModel(fromCity: from, fromPoint: null, toCity: to, dayIndex: dayIndex));
    return all.where((t) => t.poId == poId).toList();
  }

  /// JSON dari GET /api/trips → [Trip]. Foto & fasilitas belum ada di backend, jadi diambil dari MockData.
  static Trip tripFromJson(Map<String, dynamic> j) {
    final poId = j['poId'] as String;
    final busClass = j['busClass'] as String;
    final look = MockData.lookOf(poId, busClass);
    final tiers = [
      for (final t in (j['tiers'] as List).cast<Map>())
        SeatTier(
          key: t['key'] as String,
          name: t['name'] as String,
          price: (t['price'] as num).toInt(),
          freeSeats: (t['freeSeats'] as List).cast<String>(),
        ),
    ];
    final firstOld = (j['tiers'] as List).isEmpty ? null : ((j['tiers'] as List).first as Map)['oldPrice'] as num?;
    return Trip(
      id: j['id'] as String,
      poId: poId,
      poName: j['poName'] as String,
      busClass: busClass,
      from: j['from'] as String,
      to: j['to'] as String,
      date: DateTime.parse(j['date'] as String),
      depart: j['depart'] as String,
      arrive: j['arrive'] as String,
      duration: durationLabel((j['durationMinutes'] as num).toInt()),
      boardPoint: j['boardPoint'] as String,
      dropPoint: j['dropPoint'] as String,
      tiers: tiers,
      oldPrice: firstOld?.toInt(),
      facilities: look.facilities,
      image: look.image,
    );
  }
}
