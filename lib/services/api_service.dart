import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class ApiException implements Exception {
  ApiException(this.statusCode, this.message);
  final int statusCode;
  final String message;

  @override
  String toString() => 'ApiException($statusCode): $message';
}

/// Klien HTTP sederhana ke backend CardBus (lihat folder cardbus_backend).
/// Setiap request dicatat dengan tag [ApiService]; lihat di HP lewat:
///   adb logcat | findstr ApiService
class ApiService {
  // URL publik backend di Railway
  static const String defaultBaseUrl = 'https://cardbusbackend-production.up.railway.app';

  ApiService({String? baseUrl}) : baseUrl = baseUrl ?? defaultBaseUrl;

  final String baseUrl;
  String? _token; // JWT dari backend setelah verifikasi OTP WhatsApp

  void setToken(String? token) => _token = token;

  Map<String, String> get _headers => {
        'Content-Type': 'application/json',
        if (_token != null) 'Authorization': 'Bearer $_token',
      };

  Future<dynamic> get(String path, [Map<String, String>? query]) {
    final uri = Uri.parse('$baseUrl$path').replace(queryParameters: query);
    return _send('GET', uri, () => http.get(uri, headers: _headers));
  }

  Future<dynamic> post(String path, Map<String, dynamic> body) {
    final uri = Uri.parse('$baseUrl$path');
    return _send('POST', uri, () => http.post(uri, headers: _headers, body: jsonEncode(body)));
  }

  Future<dynamic> put(String path, Map<String, dynamic> body) {
    final uri = Uri.parse('$baseUrl$path');
    return _send('PUT', uri, () => http.put(uri, headers: _headers, body: jsonEncode(body)));
  }

  /// Jalankan request + catat hasilnya. Exception tetap dilempar ulang apa adanya.
  Future<dynamic> _send(String method, Uri uri, Future<http.Response> Function() request) async {
    final watch = Stopwatch()..start();
    debugPrint('[ApiService] → $method $uri');
    try {
      final res = await request().timeout(const Duration(seconds: 15));
      debugPrint('[ApiService] ← $method $uri ${res.statusCode} (${watch.elapsedMilliseconds} ms) ${_snippet(res.body)}');
      return _decode(res);
    } on ApiException {
      rethrow; // status 4xx/5xx sudah tercatat di atas
    } catch (e, st) {
      debugPrint('[ApiService] ✗ $method $uri gagal setelah ${watch.elapsedMilliseconds} ms: ${e.runtimeType}: $e');
      debugPrint('[ApiService] stack trace:\n$st');
      // Bungkus error jaringan/timeout/TLS dengan pesan aslinya (statusCode 0 = tidak ada respons),
      // agar UI menampilkan penyebab sebenarnya, bukan pesan generic.
      throw ApiException(0, '$method $uri gagal: ${e.runtimeType}: $e');
    }
  }

  /// Potong body panjang (mis. foto base64) agar log tetap terbaca.
  static String _snippet(String body) => body.length > 300 ? '${body.substring(0, 300)}… (${body.length} chars)' : body;

  /// Ringkasan data respons untuk pesan error (mis. respons 200 yang isinya tidak sesuai).
  static String describe(dynamic data) => _snippet(data is String ? data : jsonEncode(data));

  dynamic _decode(http.Response res) {
    dynamic body;
    if (res.body.isNotEmpty) {
      try {
        body = jsonDecode(res.body);
      } on FormatException {
        // Mis. halaman HTML 502/404 dari Railway: tampilkan status + isi aslinya.
        throw ApiException(res.statusCode, 'HTTP ${res.statusCode}, respons bukan JSON: ${_snippet(res.body)}');
      }
    }
    if (res.statusCode >= 400) {
      final detail = (body is Map && body['error'] != null)
          ? '${body['error']}'
          : (res.body.isNotEmpty ? _snippet(res.body) : (res.reasonPhrase ?? 'Terjadi kesalahan'));
      throw ApiException(res.statusCode, 'HTTP ${res.statusCode}: $detail');
    }
    return body;
  }
}
