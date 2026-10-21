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
    this.status = 'Aktif',
  });

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
  final String status;

  BookingOrder copyWith({String? status}) => BookingOrder(
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
        status: status ?? this.status,
      );
}
