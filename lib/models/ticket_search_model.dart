import '../utils/formatters.dart';

/// Parameter pencarian tiket dari kartu "Cari tiket" di beranda.
class TicketSearchModel {
  const TicketSearchModel({
    this.fromCity = 'Solo',
    this.fromPoint = 'Terminal Tirtonadi',
    this.toCity = 'Jakarta',
    this.toPoint,
    this.dayIndex = 0,
    this.pax = 1,
  });

  final String fromCity;
  final String? fromPoint; // null = semua titik di kota asal
  final String toCity;
  final String? toPoint; // null = semua titik di kota tujuan
  final int dayIndex; // 0 = hari ini
  final int pax; // maks. 4

  static const maxPax = 4;

  DateTime get date => dayFromToday(dayIndex);
  bool get isSameCity => fromCity == toCity;

  TicketSearchModel copyWith({
    String? fromCity,
    String? fromPoint,
    bool clearFromPoint = false,
    String? toCity,
    String? toPoint,
    bool clearToPoint = false,
    int? dayIndex,
    int? pax,
  }) {
    return TicketSearchModel(
      fromCity: fromCity ?? this.fromCity,
      fromPoint: clearFromPoint ? null : (fromPoint ?? this.fromPoint),
      toCity: toCity ?? this.toCity,
      toPoint: clearToPoint ? null : (toPoint ?? this.toPoint),
      dayIndex: dayIndex ?? this.dayIndex,
      pax: pax ?? this.pax,
    );
  }

  TicketSearchModel swapped() => TicketSearchModel(
        fromCity: toCity,
        fromPoint: toPoint,
        toCity: fromCity,
        toPoint: fromPoint,
        dayIndex: dayIndex,
        pax: pax,
      );

  /// Dipakai saat memanggil GET /trips di backend.
  Map<String, String> toQuery() => {
        'from': fromCity,
        'to': toCity,
        'date': date.toIso8601String().substring(0, 10),
        'pax': '$pax',
        if (fromPoint != null) 'board': fromPoint!,
        if (toPoint != null) 'drop': toPoint!,
      };
}
