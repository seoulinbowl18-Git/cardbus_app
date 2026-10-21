/// Siklus hidup e-tiket (sama dengan `ticketStatus` dari backend).
enum TicketStatus {
  active, // lunas, belum di-scan, jadwal belum lewat
  used, // sudah check-in saat naik bus
  expired, // tidak dipakai sampai batas berlaku (hangus)
  cancelled; // dibatalkan

  String get label => switch (this) {
        TicketStatus.active => 'Aktif',
        TicketStatus.used => 'Selesai',
        TicketStatus.expired => 'Hangus',
        TicketStatus.cancelled => 'Dibatalkan',
      };

  static TicketStatus? fromApi(String? value) => switch (value) {
        'active' => TicketStatus.active,
        'used' => TicketStatus.used,
        'expired' => TicketStatus.expired,
        'cancelled' => TicketStatus.cancelled,
        _ => null,
      };
}

/// Pesanan yang sudah dibayar (e-tiket).
class BookingOrder {
  const BookingOrder({
    required this.code,
    required this.poName,
    required this.busClass,
    required this.from,
    required this.to,
    required this.date,
    required this.depart,
    required this.arrive,
    required this.boardPoint,
    required this.dropPoint,
    required this.seats,
    required this.passengerNames,
    required this.total,
    required this.paymentMethod,
    TicketStatus status = TicketStatus.active,
    this.validUntil,
  }) : _status = status;

  /// Tiket masih bisa dipakai sampai sekian lama setelah jam berangkat (sama dengan
  /// TICKET_GRACE_HOURS default di backend). Hanya dipakai jika server tidak mengirim `validUntil`.
  static const graceAfterDepart = Duration(hours: 2);

  final String code;
  final String poName;
  final String busClass;
  final String from;
  final String to;
  final DateTime date;
  final String depart;
  final String arrive;
  final String boardPoint;
  final String dropPoint;
  final List<String> seats;
  final List<String> passengerNames;
  final int total;
  final String paymentMethod;
  final TicketStatus _status; // status terakhir dari server / saat dibuat
  final DateTime? validUntil; // batas berlaku dari server

  /// Batas berlaku tiket: dari server, atau jam berangkat + [graceAfterDepart].
  DateTime get expiresAt {
    if (validUntil != null) return validUntil!;
    final hm = RegExp(r'^(\d{2}):(\d{2})').firstMatch(depart);
    if (hm == null) return DateTime(date.year, date.month, date.day, 23, 59, 59);
    return DateTime(date.year, date.month, date.day, int.parse(hm[1]!), int.parse(hm[2]!)).add(graceAfterDepart);
  }

  /// Status saat ini. Tiket "Aktif" otomatis jadi "Hangus" begitu batas berlaku lewat,
  /// walau aplikasi belum menarik ulang data dari server.
  TicketStatus get status =>
      _status == TicketStatus.active && DateTime.now().isAfter(expiresAt) ? TicketStatus.expired : _status;

  bool get isActive => status == TicketStatus.active;

  BookingOrder copyWith({TicketStatus? status}) => BookingOrder(
        code: code,
        poName: poName,
        busClass: busClass,
        from: from,
        to: to,
        date: date,
        depart: depart,
        arrive: arrive,
        boardPoint: boardPoint,
        dropPoint: dropPoint,
        seats: seats,
        passengerNames: passengerNames,
        total: total,
        paymentMethod: paymentMethod,
        status: status ?? _status,
        validUntil: validUntil,
      );
}
