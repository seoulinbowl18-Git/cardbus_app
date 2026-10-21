import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/auth_provider.dart';
import '../theme/app_colors.dart';
import '../widgets/cardbus_logo.dart';
import 'login_screen.dart';
import 'main_shell.dart';

/// Splash Flutter: latar hijau CardBus, logo besar di tengah dengan animasi
/// fade + zoom, lalu fade ke [MainShell] (sudah login) atau [LoginScreen].
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  static const green = AppColors.teal; // #087F78, warna utama tema

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late final AnimationController _controller =
      AnimationController(vsync: this, duration: const Duration(milliseconds: 900))..forward();
  late final Animation<double> _fade = CurvedAnimation(parent: _controller, curve: Curves.easeOut);
  late final Animation<double> _scale =
      Tween<double>(begin: 0.85, end: 1).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutBack));

  @override
  void initState() {
    super.initState();
    _goNext();
  }

  /// Tampil minimal 2 detik sambil menunggu sesi dimuat, lalu:
  /// sudah login → [MainShell], belum → [LoginScreen].
  /// Jika memuat sesi gagal atau lebih dari 5 detik, langsung ke [LoginScreen].
  Future<void> _goNext() async {
    final auth = context.read<AuthProvider>();
    var loaded = true;
    try {
      await Future.wait([
        Future<void>.delayed(const Duration(seconds: 2)),
        auth.ensureLoaded().timeout(const Duration(seconds: 5)),
      ]);
    } catch (e) {
      debugPrint('Splash: gagal memuat sesi ($e), lanjut ke Login');
      loaded = false;
    }
    if (!mounted) return;
    final Widget next = loaded && auth.isLoggedIn ? const MainShell() : const LoginScreen();
    // pushReplacement → halaman tujuan jadi route pertama, jadi popUntil(isFirst) tetap benar.
    Navigator.of(context).pushReplacement(PageRouteBuilder(
      transitionDuration: const Duration(milliseconds: 500),
      pageBuilder: (_, __, ___) => next,
      transitionsBuilder: (_, anim, __, child) => FadeTransition(opacity: anim, child: child),
    ));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: SplashScreen.green,
      body: SizedBox.expand(
        child: Stack(alignment: Alignment.center, children: [
          FadeTransition(
            opacity: _fade,
            child: ScaleTransition(
              scale: _scale,
              child: const Column(mainAxisSize: MainAxisSize.min, children: [
                CardBusIcon(size: 132),
                SizedBox(height: 24),
                CardBusWordmark(fontSize: 46),
                SizedBox(height: 6),
                Text('Tiket Bus, Lebih Mudah',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Color(0xFFCFE9E6), fontSize: 17, fontWeight: FontWeight.w600)),
              ]),
            ),
          ),
          // Indikator di bawah agar logo tetap simetris tepat di tengah layar.
          const Positioned(
            bottom: 64,
            child: SizedBox(
              width: 26,
              height: 26,
              child: CircularProgressIndicator(strokeWidth: 2.6, color: Colors.white70),
            ),
          ),
        ]),
      ),
    );
  }
}
