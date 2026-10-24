import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../providers/auth_provider.dart';
import '../services/api_service.dart';
import '../theme/app_colors.dart';
import '../widgets/cardbus_logo.dart';
import 'main_shell.dart';
import 'otp_verification_screen.dart';

/// Masuk / daftar dengan nomor WhatsApp + OTP.
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _form = GlobalKey<FormState>();
  final _phone = TextEditingController();
  bool _busy = false;

  static final _phonePattern = RegExp(r'^(\+?62|0)?8\d{7,11}$');

  @override
  void dispose() {
    _phone.dispose();
    super.dispose();
  }

  String get _cleanPhone => _phone.text.replaceAll(RegExp(r'[\s\-().]'), '');

  Future<void> _sendOtp() async {
    if (!_form.currentState!.validate()) return;
    FocusScope.of(context).unfocus();
    setState(() => _busy = true);
    final phone = _cleanPhone;
    try {
      final resendIn = await context.read<AuthProvider>().sendOtp(phone);
      if (!mounted) return;
      setState(() => _busy = false);
      // Setelah OTP sukses, OtpVerificationScreen sendiri yang pindah ke MainShell.
      await Navigator.of(context).push<bool>(
        MaterialPageRoute(builder: (_) => OtpVerificationScreen(phone: phone, resendIn: resendIn)),
      );
    } on ApiException catch (e) {
      _fail(e.message);
    } catch (e, st) {
      debugPrint('[Login] kirim OTP gagal: ${e.runtimeType}: $e\n$st');
      _fail('Gagal kirim OTP: ${e.runtimeType}: $e');
    }
  }

  void _fail(String message) {
    if (!mounted) return;
    setState(() => _busy = false);
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  /// Masuk ke Beranda sebagai tamu, dengan riwayat halaman dibersihkan.
  void _goHomeAsGuest() {
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const MainShell()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    // Tombol back sistem Android di LoginScreen root akan menutup aplikasi;
    // arahkan ke beranda sebagai tamu.
    return PopScope(
      canPop: Navigator.of(context).canPop(),
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _goHomeAsGuest();
      },
      child: _buildBody(context),
    );
  }

  Widget _buildBody(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.headerGradient),
        child: SafeArea(
          bottom: false,
          // Scroll agar tidak overflow saat keyboard muncul / layar pendek; minHeight +
          // IntrinsicHeight menjaga Expanded tetap mengisi layar saat konten muat.
          child: LayoutBuilder(
            builder: (context, constraints) => SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: IntrinsicHeight(
                  child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(28, 24, 28, 24),
                        child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                          Row(children: [
                            IconButton(
                              onPressed: _goHomeAsGuest,
                              icon: const Icon(Icons.arrow_back_rounded, color: AppColors.white),
                            ),
                            const CardBusIcon(size: 48),
                            const SizedBox(width: 12),
                            const Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                              CardBusWordmark(fontSize: 26),
                              Text('Tiket Bus, Lebih Mudah', style: TextStyle(color: Color(0xFFCFE9E6), fontWeight: FontWeight.w600)),
                            ]),
                          ]),
                          const Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                            Text('Pesan tiket bus, tanpa antre.',
                                style: TextStyle(color: AppColors.white, fontSize: 30, fontWeight: FontWeight.w800, height: 1.15)),
                            SizedBox(height: 10),
                            Text('Bandingkan jadwal PO mitra, pilih kursi, dan simpan e-tiket di satu aplikasi.',
                                style: TextStyle(color: Color(0xFFCFE9E6), height: 1.5)),
                          ]),
                        ]),
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.fromLTRB(20, 26, 20, 26 + MediaQuery.viewInsetsOf(context).bottom + MediaQuery.paddingOf(context).bottom),
                      decoration: const BoxDecoration(color: AppColors.white, borderRadius: BorderRadius.vertical(top: Radius.circular(28))),
                      child: Form(
                        key: _form,
                        child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
                          const Text('Masuk atau daftar', style: TextStyle(fontSize: 19, fontWeight: FontWeight.w800)),
                          const SizedBox(height: 6),
                          const Text('Masukkan nomor WhatsApp. Kami kirim kode OTP ke WhatsApp kamu — akun baru dibuat otomatis.',
                              style: TextStyle(color: AppColors.muted, height: 1.5)),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: _phone,
                            enabled: !_busy,
                            keyboardType: TextInputType.phone,
                            textInputAction: TextInputAction.done,
                            inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9+\s\-]')), LengthLimitingTextInputFormatter(17)],
                            decoration: const InputDecoration(
                              labelText: 'Nomor WhatsApp',
                              hintText: '08xxxxxxxxxx',
                              prefixIcon: Icon(Icons.phone_android_rounded),
                            ),
                            validator: (_) => _phonePattern.hasMatch(_cleanPhone) ? null : 'Nomor WhatsApp tidak valid (contoh: 081234567890)',
                            onFieldSubmitted: (_) => _busy ? null : _sendOtp(),
                          ),
                          const SizedBox(height: 14),
                          ElevatedButton(
                            onPressed: _busy ? null : _sendOtp,
                            child: _busy
                                ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2.4, color: AppColors.white))
                                : const Text('Kirim kode OTP'),
                          ),
                        ]),
                      ),
                    ),
                  ]),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
