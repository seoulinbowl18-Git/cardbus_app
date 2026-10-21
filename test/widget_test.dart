import 'package:flutter_test/flutter_test.dart';

import 'package:cardbus/data/mock_data.dart';
import 'package:cardbus/utils/formatters.dart';

void main() {
  test('format Rupiah', () {
    expect(rupiah(300000), 'Rp 300.000');
  });

  test('jadwal Mahardhika Wonogiri → Jakarta punya varian Double Decker', () {
    final trips = MockData.generateTrips('Wonogiri', 'Jakarta', dayFromToday(0));
    final dd = trips.firstWhere((t) => t.busClass == 'Double Decker');
    expect(dd.tiers.map((t) => t.name), containsAll(['Sleeper privat', 'Bawah exe', 'Exe atas']));
  });

  test('promo Raya Solo → Bogor Rp 230.000 dengan harga coret', () {
    final trips = MockData.generateTrips('Solo', 'Bogor', dayFromToday(0));
    final junior = trips.firstWhere((t) => t.busClass == 'Junior');
    expect(junior.tiers.first.price, 230000);
    expect(junior.oldPrice, 260000);
  });
}
