import 'package:intl/intl.dart';

final _rupiah = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);

String rupiah(num value) => _rupiah.format(value);

const _dow = ['Min', 'Sen', 'Sel', 'Rab', 'Kam', 'Jum', 'Sab'];
const _mon = ['Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun', 'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des'];

/// DateTime.weekday: Senin = 1 ... Minggu = 7.
String dowShort(DateTime d) => _dow[d.weekday % 7];
String monShort(DateTime d) => _mon[d.month - 1];
String dateLabel(DateTime d) => '${dowShort(d)}, ${d.day} ${monShort(d)} ${d.year}';

DateTime dayFromToday(int offset) {
  final now = DateTime.now();
  return DateTime(now.year, now.month, now.day).add(Duration(days: offset));
}

/// "19:45" + 11 jam 5 menit -> "06:50 (+1)"
String addMinutes(String hhmm, int minutes) {
  final parts = hhmm.split(':');
  var total = int.parse(parts[0]) * 60 + int.parse(parts[1]) + minutes;
  final plusDay = total ~/ 1440;
  total = total % 1440;
  final s = '${(total ~/ 60).toString().padLeft(2, '0')}:${(total % 60).toString().padLeft(2, '0')}';
  return plusDay > 0 ? '$s (+$plusDay)' : s;
}

String durationLabel(int minutes) => '${minutes ~/ 60}j ${minutes % 60}m';
