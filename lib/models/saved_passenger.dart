/// Penumpang yang disimpan di profil untuk dipakai ulang saat pesan tiket.
class SavedPassenger {
  const SavedPassenger({required this.name, this.phone});

  final String name;
  final String? phone; // opsional, format 08xx

  factory SavedPassenger.fromJson(Map<String, dynamic> json) {
    final phone = json['phone'] as String?;
    return SavedPassenger(name: json['name'] as String, phone: (phone == null || phone.isEmpty) ? null : phone);
  }

  Map<String, dynamic> toJson() => {'name': name, if (phone != null) 'phone': phone};

  bool sameNameAs(String other) => name.toLowerCase() == other.trim().toLowerCase();
}
