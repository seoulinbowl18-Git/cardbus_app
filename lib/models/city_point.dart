/// Titik naik / turun (terminal, pool, agen) di sebuah kota.
class CityPoint {
  const CityPoint({required this.name, required this.city, this.area = '', this.favorite = true});

  final String name;
  final String city;
  final String area;
  final bool favorite;
}
