/// Varian kursi dalam satu jadwal (mis. Sleeper privat / Bawah exe / Exe atas).
class SeatTier {
  const SeatTier({required this.key, required this.name, required this.price, required this.freeSeats});

  final String key;
  final String name;
  final int price;
  final List<String> freeSeats;

  int get left => freeSeats.length;
  bool get soldOut => freeSeats.isEmpty;
}

/// Satu keberangkatan bus pada tanggal tertentu.
class Trip {
  const Trip({
    required this.id,
    required this.poId,
    required this.poName,
    required this.busClass,
    required this.from,
    required this.to,
    required this.date,
    required this.depart,
    required this.arrive,
    required this.duration,
    required this.boardPoint,
    required this.dropPoint,
    required this.tiers,
    this.oldPrice,
    this.facilities = const [],
    this.image,
  });

  final String id;
  final String poId;
  final String poName;
  final String busClass;
  final String from;
  final String to;
  final DateTime date;
  final String depart;
  final String arrive;
  final String duration;
  final String boardPoint;
  final String dropPoint;
  final List<SeatTier> tiers;
  final int? oldPrice; // harga coret saat promo
  final List<String> facilities;
  final String? image;

  int get seatsLeft => tiers.fold(0, (sum, t) => sum + t.left);

  SeatTier? get cheapestAvailable {
    final available = tiers.where((t) => !t.soldOut).toList()..sort((a, b) => a.price.compareTo(b.price));
    return available.isEmpty ? null : available.first;
  }

  int get minPrice => (cheapestAvailable ?? tiers.first).price;
}
