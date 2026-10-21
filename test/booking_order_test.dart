import 'package:cardbus/models/booking_order.dart';
import 'package:flutter_test/flutter_test.dart';

BookingOrder _order({required DateTime date, String depart = '19:45', TicketStatus status = TicketStatus.active, DateTime? validUntil}) =>
    BookingOrder(
      code: 'AB12CD',
      poName: 'Haryanto',
      busClass: 'Sleeper',
      from: 'Solo',
      to: 'Jakarta',
      date: date,
      depart: depart,
      arrive: '05:00 (+1)',
      boardPoint: 'Tirtonadi',
      dropPoint: 'Pulo Gebang',
      seats: const ['1A'],
      passengerNames: const ['Agus'],
      total: 300000,
      paymentMethod: 'QRIS',
      status: status,
      validUntil: validUntil,
    );

void main() {
  final today = DateTime.now();
  final tomorrow = today.add(const Duration(days: 1));
  final lastWeek = today.subtract(const Duration(days: 7));

  test('tiket aktif dengan jadwal mendatang tetap aktif', () {
    expect(_order(date: tomorrow).status, TicketStatus.active);
  });

  test('tiket aktif yang jadwalnya sudah lewat jadi hangus', () {
    expect(_order(date: lastWeek).status, TicketStatus.expired);
    expect(_order(date: tomorrow, validUntil: today.subtract(const Duration(minutes: 1))).status, TicketStatus.expired);
  });

  test('status selesai / dibatalkan tidak berubah karena waktu', () {
    expect(_order(date: lastWeek, status: TicketStatus.used).status, TicketStatus.used);
    expect(_order(date: lastWeek, status: TicketStatus.cancelled).status, TicketStatus.cancelled);
  });

  test('jam berangkat tidak terbaca → berlaku sampai akhir hari', () {
    expect(_order(date: tomorrow, depart: '-').status, TicketStatus.active);
    expect(_order(date: lastWeek, depart: '-').status, TicketStatus.expired);
  });

  test('status dari API', () {
    expect(TicketStatus.fromApi('used'), TicketStatus.used);
    expect(TicketStatus.fromApi(null), isNull);
  });
}
