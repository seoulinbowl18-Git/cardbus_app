import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../providers/auth_provider.dart';
import '../services/api_service.dart';
import '../theme/app_colors.dart';
import '../widgets/cardbus_logo.dart';
import 'main_shell.dart';
import 'otp_verification_screen.dart';

/// Masuk / daftar dengan nomor WhatsApp + OTP, atau dengan akun Google.
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _form = GlobalKey<FormState>();
  final _phone = TextEditingController();
  bool _busy = false;
  bool _googleBusy = false;

  bool get _anyBusy => _busy || _googleBusy;

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

  Future<void> _signInWithGoogle() async {
    FocusScope.of(context).unfocus();
    setState(() => _googleBusy = true);
    try {
      final signedIn = await context.read<AuthProvider>().signInWithGoogle();
      if (!mounted) return;
      if (!signedIn) {
        setState(() => _googleBusy = false); // pemilih akun ditutup
        return;
      }
      // Token sudah tersimpan → bersihkan seluruh riwayat dan mulai dari Beranda.
      _goHome();
    } on ApiException catch (e) {
      _fail(e.message);
    } catch (e, st) {
      debugPrint('[Login] masuk Google gagal: ${e.runtimeType}: $e\n$st');
      _fail('Gagal masuk dengan Google: $e');
    }
  }

  void _fail(String message) {
    if (!mounted) return;
    setState(() => _busy = _googleBusy = false);
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  /// Masuk ke Beranda (sebagai tamu atau setelah login), dengan riwayat halaman dibersihkan.
  void _goHome() {
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
        if (!didPop) _goHome();
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
                              onPressed: _goHome,
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
                            enabled: !_anyBusy,
                            keyboardType: TextInputType.phone,
                            textInputAction: TextInputAction.done,
                            inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9+\s\-]')), LengthLimitingTextInputFormatter(17)],
                            decoration: const InputDecoration(
                              labelText: 'Nomor WhatsApp',
                              hintText: '08xxxxxxxxxx',
                              prefixIcon: Icon(Icons.phone_android_rounded),
                            ),
                            validator: (_) => _phonePattern.hasMatch(_cleanPhone) ? null : 'Nomor WhatsApp tidak valid (contoh: 081234567890)',
                            onFieldSubmitted: (_) => _anyBusy ? null : _sendOtp(),
                          ),
                          const SizedBox(height: 14),
                          ElevatedButton(
                            onPressed: _anyBusy ? null : _sendOtp,
                            child: _busy
                                ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2.4, color: AppColors.white))
                                : const Text('Kirim kode OTP'),
                          ),
                          const SizedBox(height: 18),
                          const Row(children: [
                            Expanded(child: Divider(color: AppColors.border)),
                            Padding(
                              padding: EdgeInsets.symmetric(horizontal: 12),
                              child: Text('atau', style: TextStyle(color: AppColors.faint, fontWeight: FontWeight.w600)),
                            ),
                            Expanded(child: Divider(color: AppColors.border)),
                          ]),
                          const SizedBox(height: 18),
                          OutlinedButton(
                            onPressed: _anyBusy ? null : _signInWithGoogle,
                            style: OutlinedButton.styleFrom(
                              foregroundColor: AppColors.ink,
                              minimumSize: const Size(64, 50),
                              side: const BorderSide(color: AppColors.border, width: 1.4),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                              textStyle: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15),
                            ),
                            child: _googleBusy
                                ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2.4, color: AppColors.teal))
                                : const Row(mainAxisSize: MainAxisSize.min, children: [
                                    Text('G', style: TextStyle(color: Color(0xFF4285F4), fontSize: 20, fontWeight: FontWeight.w900)),
                                    SizedBox(width: 10),
                                    Text('Masuk dengan Google'),
                                  ]),
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
