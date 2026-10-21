/// Banner promo (carousel atas & "Promo spesial").
class Promo {
  const Promo({
    required this.image,
    required this.tag,
    required this.title,
    required this.subtitle,
    this.ctaLabel = 'Cek jadwal',
    this.from,
    this.to,
    this.soonMessage,
  });

  final String image;
  final String tag;
  final String title;
  final String subtitle;
  final String ctaLabel;
  final String? from;
  final String? to;
  final String? soonMessage; // jika diisi, CTA hanya menampilkan info

  bool get hasRoute => from != null && to != null;
}
