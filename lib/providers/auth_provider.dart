import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/saved_passenger.dart';
import '../services/api_service.dart';

/// Login (nomor WhatsApp + OTP Fonnte) + profil (nama, foto, penumpang tersimpan).
///
/// Satu-satunya yang disimpan di perangkat adalah JWT, di [FlutterSecureStorage].
/// Data profil TIDAK pernah di-cache ke disk: hanya ada di memori dan selalu diambil
/// dari server (`GET /api/user/profile`) berdasarkan token yang sedang aktif, agar
/// tidak ada data akun lain yang tertinggal di HP.
///
/// Provider lain yang menyimpan data per akun (Checkout, Tiket Saya) memantau
/// [token] dan mengosongkan dirinya sendiri setiap kali akun berganti / logout.
class AuthProvider extends ChangeNotifier {
  AuthProvider(this._api, {FlutterSecureStorage? storage}) : _storage = storage ?? const FlutterSecureStorage();

  final ApiService _api;
  final FlutterSecureStorage _storage;

  String? token;
  String? email;
  String? name;
  String phone = '';
  String? photoUrl; // https://… atau data:image/…;base64,…
  Uint8List? avatarBytes; // hasil decode photoUrl jika berupa data URL
  List<SavedPassenger> savedPassengers = const [];

  bool get isLoggedIn => token != null;

  static const _kToken = 'auth.token';

  /// Kunci SharedPreferences versi lama (token + cache profil). Dihapus saat load/logout;
  /// token lama dipindah sekali ke SecureStorage agar user tidak terpaksa login ulang.
  static const _legacyPrefKeys = ['auth.token', 'auth.user', 'auth.name', 'auth.phone', 'auth.email', 'auth.avatar', 'auth.passengers'];

  static const _unset = Object();

  Future<void>? _loading;

  /// Muat sesi sekali saja; aman dipanggil berkali-kali (mis. dari Splash).
  Future<void> ensureLoaded() => _loading ??= load();

  Future<void> load() async {
    String? stored;
    try {
      stored = await _storage.read(key: _kToken);
    } catch (e) {
      debugPrint('[Auth] SecureStorage tidak terbaca ($e), sesi direset');
      await _storage.deleteAll().catchError((_) {});
    }
    stored ??= await _migrateLegacyPrefs();

    token = stored;
    _api.setToken(token);
    notifyListeners();

    if (token != null) {
      // Tunggu sebentar agar Splash bisa langsung menampilkan nama; jika lambat, profil
      // menyusul saat respons tiba (UI ikut diperbarui lewat notifyListeners).
      try {
        await refreshProfile().timeout(const Duration(seconds: 3));
      } catch (_) {}
    }
  }

  /// Pindahkan token dari SharedPreferences (versi lama) ke SecureStorage, lalu hapus
  /// seluruh cache profil lama dari disk.
  Future<String?> _migrateLegacyPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final old = prefs.getString(_kToken);
    for (final k in _legacyPrefKeys) {
      await prefs.remove(k);
    }
    if (old == null || old.isEmpty) return null;
    await _storage.write(key: _kToken, value: old);
    return old;
  }

  /// Ambil profil terbaru dari server untuk token yang sedang aktif.
  /// Dipanggil saat aplikasi dibuka, setelah login, dan setiap kali halaman
  /// Profil / Checkout dibuka. Token kedaluwarsa / akun hilang → logout.
  Future<void> refreshProfile() async {
    final requestedFor = token;
    if (requestedFor == null) return;
    try {
      final data = await _api.get('/api/user/profile') as Map<String, dynamic>;
      if (token != requestedFor) return; // akun berganti selama request berjalan
      _setUser(Map<String, dynamic>.from(data['user'] as Map));
    } on ApiException catch (e) {
      if (token != requestedFor) return;
      if (e.statusCode == 401 || e.statusCode == 404) {
        await signOut();
      } else {
        debugPrint('[Auth] gagal memuat profil: ${e.message}');
      }
    }
  }

  void _applyUser(Map<String, dynamic> user) {
    // Backend menyimpan 628xx; aplikasi memakai format lokal 08xx.
    final p = (user['phone'] as String?) ?? '';
    phone = p.startsWith('62') ? '0${p.substring(2)}' : p;
    name = user['name'] as String?;
    email = user['email'] as String?;
    photoUrl = user['photoUrl'] as String?;
    avatarBytes = _decodeDataUrl(photoUrl);
    savedPassengers = [
      for (final p in (user['savedPassengers'] as List? ?? const []))
        SavedPassenger.fromJson(Map<String, dynamic>.from(p as Map)),
    ];
  }

  /// Simpan data user di memori saja (tidak ke disk).
  void _setUser(Map<String, dynamic> user) {
    _applyUser(user);
    notifyListeners();
  }

  /// Kirim OTP ke WhatsApp. Mengembalikan jeda (detik) sebelum boleh kirim ulang.
  /// Melempar [ApiException] jika nomor tidak valid / gagal kirim.
  Future<int> sendOtp(String phone) async {
    final data = await _api.post('/api/auth/send-otp', {'phone': phone});
    return (data is Map && data['resendIn'] is num) ? (data['resendIn'] as num).toInt() : 60;
  }

  /// Verifikasi OTP; jika benar simpan JWT (SecureStorage) + data user (memori).
  /// Melempar [ApiException] jika kode salah / kedaluwarsa.
  Future<void> verifyOtp(String phone, String code) async {
    final data = await _api.post('/api/auth/verify-otp', {'phone': phone, 'code': code});
    // Validasi respons dulu; sesi baru disimpan jika token + user lengkap,
    // agar verifikasi yang gagal tidak meninggalkan status "sudah login".
    final newToken = data is Map ? data['token'] : null;
    final user = data is Map ? data['user'] : null;
    if (newToken is! String || newToken.isEmpty || user is! Map) {
      throw ApiException(500, 'Respons verify-otp tidak berisi token/user: ${ApiService.describe(data)}');
    }
    await _storage.write(key: _kToken, value: newToken);
    // Bersihkan sisa akun sebelumnya di memori sebelum memasang akun baru.
    _resetUser();
    token = newToken;
    _api.setToken(token);
    _setUser(Map<String, dynamic>.from(user));
  }

  /// Simpan perubahan profil ke backend. Hanya argumen yang diisi yang dikirim;
  /// `photoUrl: null` menghapus foto. Melempar [ApiException] jika gagal.
  Future<void> updateProfile({String? name, Object? photoUrl = _unset, List<SavedPassenger>? savedPassengers}) async {
    if (!isLoggedIn) throw ApiException(401, 'Masuk dulu untuk menyimpan profil');
    final body = <String, dynamic>{
      if (name != null) 'name': name,
      if (!identical(photoUrl, _unset)) 'photoUrl': photoUrl,
      if (savedPassengers != null) 'savedPassengers': [for (final p in savedPassengers) p.toJson()],
    };
    final data = await _api.put('/api/user/profile', body) as Map<String, dynamic>;
    _setUser(Map<String, dynamic>.from(data['user'] as Map));
  }

  /// Tambah penumpang tersimpan. `false` jika nama yang sama (abaikan huruf besar/kecil) sudah ada.
  Future<bool> addPassenger(SavedPassenger passenger) async {
    if (savedPassengers.any((p) => p.sameNameAs(passenger.name))) return false;
    await updateProfile(savedPassengers: [...savedPassengers, passenger]);
    return true;
  }

  Future<void> removePassenger(SavedPassenger passenger) =>
      updateProfile(savedPassengers: savedPassengers.where((p) => !identical(p, passenger)).toList());

  /// Buka galeri HP, lalu simpan foto ke profil. `false` jika batal memilih.
  Future<bool> pickAvatar() async {
    final file = await ImagePicker().pickImage(source: ImageSource.gallery, maxWidth: 256, maxHeight: 256, imageQuality: 80);
    if (file == null) return false;
    final url = _dataUrl(await file.readAsBytes());
    if (url == null) throw ApiException(400, 'Format foto tidak didukung (PNG/JPG/WebP)');
    await updateProfile(photoUrl: url);
    return true;
  }

  Future<void> removeAvatar() => updateProfile(photoUrl: null);

  void _resetUser() {
    email = null;
    name = null;
    phone = '';
    photoUrl = null;
    avatarBytes = null;
    savedPassengers = const [];
  }

  /// Logout total: kosongkan seluruh data akun di memori, hapus token dari SecureStorage
  /// dan sisa cache lama di SharedPreferences. Perubahan [token] ke null memicu
  /// CheckoutProvider & OrdersProvider mengosongkan dirinya.
  /// Data profil tetap aman di server dan kembali saat login ulang.
  Future<void> signOut() async {
    // Kosongkan state di memori dulu agar UI langsung "BELUM MASUK" walau storage gagal.
    token = null;
    _resetUser();
    _api.setToken(null);
    notifyListeners();

    try {
      await _storage.delete(key: _kToken);
    } catch (e) {
      debugPrint('[Auth] gagal menghapus token: $e');
      await _storage.deleteAll().catchError((_) {});
    }
    final prefs = await SharedPreferences.getInstance();
    for (final k in _legacyPrefKeys) {
      await prefs.remove(k);
    }
  }

  /// Bytes gambar → data URL; null jika bukan PNG/JPEG/WebP.
  static String? _dataUrl(Uint8List b) {
    String? mime;
    if (b.length > 8 && b[0] == 0x89 && b[1] == 0x50 && b[2] == 0x4E && b[3] == 0x47) {
      mime = 'image/png';
    } else if (b.length > 3 && b[0] == 0xFF && b[1] == 0xD8) {
      mime = 'image/jpeg';
    } else if (b.length > 12 && String.fromCharCodes(b.sublist(0, 4)) == 'RIFF' && String.fromCharCodes(b.sublist(8, 12)) == 'WEBP') {
      mime = 'image/webp';
    }
    return mime == null ? null : 'data:$mime;base64,${base64Encode(b)}';
  }

  static Uint8List? _decodeDataUrl(String? url) {
    if (url == null || !url.startsWith('data:')) return null;
    final comma = url.indexOf(',');
    if (comma < 0) return null;
    try {
      return base64Decode(url.substring(comma + 1));
    } catch (_) {
      return null;
    }
  }
}
