import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../providers/auth_provider.dart';
import '../services/api_service.dart';
import '../theme/app_colors.dart';
import 'main_shell.dart';

/// Verifikasi 6 digit OTP yang dikirim ke WhatsApp.
/// Jika berhasil, riwayat halaman dibersihkan dan pengguna masuk ke [MainShell].
class OtpVerificationScreen extends StatefulWidget {
  const OtpVerificationScreen({super.key, required this.phone, this.resendIn = 60});

  final String phone;
  final int resendIn;

  @override
  State<OtpVerificationScreen> createState() => _OtpVerificationScreenState();
}

class _OtpVerificationScreenState extends State<OtpVerificationScreen> {
  static const _length = 6;

  final _code = TextEditingController();
  Timer? _timer;
  late int _secondsLeft = widget.resendIn;
  bool _busy = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _startCountdown(widget.resendIn);
  }

  @override
  void dispose() {
    _timer?.cancel();
    _code.dispose();
    super.dispose();
  }

  void _startCountdown(int seconds) {
    _timer?.cancel();
    setState(() => _secondsLeft = seconds);
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (_secondsLeft <= 1) t.cancel();
      setState(() => _secondsLeft--);
    });
  }

  Future<void> _verify() async {
    if (_code.text.length != _length || _busy) return;
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      await context.read<AuthProvider>().verifyOtp(widget.phone, _code.text);
      if (!mounted) return;
      // Token sudah tersimpan → bersihkan seluruh riwayat dan mulai dari Beranda.
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const MainShell()),
        (route) => false,
      );
    } on ApiException catch (e) {
      _showError(e.message);
    } catch (e, st) {
      debugPrint('[OTP] verifikasi gagal: ${e.runtimeType}: $e\n$st');
      _showError('Verifikasi gagal: ${e.runtimeType}: $e');
    }
  }

  Future<void> _resend() async {
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      final wait = await context.read<AuthProvider>().sendOtp(widget.phone);
      if (!mounted) return;
      setState(() => _busy = false);
      _code.clear();
      _startCountdown(wait);
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Kode OTP baru sudah dikirim ke WhatsApp')));
    } on ApiException catch (e) {
      _showError(e.message);
    } catch (e) {
      _showError('Gagal kirim ulang OTP: ${e.runtimeType}: $e');
    }
  }

  void _showError(String message) {
    if (!mounted) return;
    setState(() {
      _busy = false;
      _error = message;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(title: const Text('Verifikasi OTP')),
      body: SafeArea(
        child: ListView(padding: const EdgeInsets.fromLTRB(24, 32, 24, 24), children: [
          const Icon(Icons.mark_chat_read_rounded, size: 64, color: AppColors.teal),
          const SizedBox(height: 18),
          const Text('Masukkan kode OTP',
              textAlign: TextAlign.center, style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800)),
          const SizedBox(height: 8),
          Text.rich(
            TextSpan(children: [
              const TextSpan(text: 'Kode 6 digit sudah dikirim lewat WhatsApp ke '),
              TextSpan(text: widget.phone, style: const TextStyle(fontWeight: FontWeight.w800, color: AppColors.ink)),
            ]),
            textAlign: TextAlign.center,
            style: const TextStyle(color: AppColors.muted, height: 1.5),
          ),
          const SizedBox(height: 28),
          TextField(
            controller: _code,
            autofocus: true,
            enabled: !_busy,
            keyboardType: TextInputType.number,
            textAlign: TextAlign.center,
            maxLength: _length,
            autofillHints: const [AutofillHints.oneTimeCode],
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w800, letterSpacing: 12),
            decoration: InputDecoration(counterText: '', hintText: '••••••', errorText: _error),
            onChanged: (v) {
              if (_error != null) setState(() => _error = null);
              if (v.length == _length) _verify();
            },
          ),
          const SizedBox(height: 18),
          ListenableBuilder(
            listenable: _code,
            builder: (_, __) => ElevatedButton(
              onPressed: (_busy || _code.text.length != _length) ? null : _verify,
              child: _busy
                  ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2.4, color: AppColors.white))
                  : const Text('Verifikasi'),
            ),
          ),
          const SizedBox(height: 12),
          Center(
            child: _secondsLeft > 0
                ? Text('Kirim ulang kode dalam $_secondsLeft detik', style: const TextStyle(color: AppColors.muted))
                : TextButton(
                    onPressed: _busy ? null : _resend,
                    child: const Text('Kirim ulang kode', style: TextStyle(color: AppColors.teal, fontWeight: FontWeight.w800)),
                  ),
          ),
          TextButton(
            onPressed: _busy ? null : () => Navigator.of(context).pop(false),
            child: const Text('Ganti nomor WhatsApp', style: TextStyle(color: AppColors.muted)),
          ),
        ]),
      ),
    );
  }
}
