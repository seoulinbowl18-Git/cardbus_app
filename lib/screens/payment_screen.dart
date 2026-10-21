import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

import '../models/payment_order.dart';
import '../providers/auth_provider.dart';
import '../providers/checkout_provider.dart';
import '../providers/orders_provider.dart';
import '../services/api_service.dart';
import '../services/payment_repository.dart';
import '../services/trip_repository.dart';
import '../theme/app_colors.dart';
import '../utils/formatters.dart';

enum _Stage { choose, creating, waiting, expired }

/// Pembayaran Komerce (QRIS / VA).
/// Backend membuat tagihan Komerce → aplikasi menampilkan QR / No. VA asli, lalu memantau
/// GET /api/orders/:id tiap beberapa detik. Status LUNAS hanya datang dari server
/// (webhook Komerce / cek status ke Komerce), bukan dari aplikasi.
class PaymentScreen extends StatefulWidget {
  const PaymentScreen({super.key});

  static const pollInterval = Duration(seconds: 5);

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  _Stage _stage = _Stage.choose;
  PaymentOrder? _order;
  Timer? _poll;
  Timer? _clock;
  bool _checking = false;
  String? _error;

  @override
  void dispose() {
    _poll?.cancel();
    _clock?.cancel();
    super.dispose();
  }

  bool get _demoMode => !context.read<TripRepository>().useBackend;

  Future<void> _pay() async {
    if (_demoMode) return _simulatePaid();
    if (!context.read<AuthProvider>().isLoggedIn) {
      setState(() => _error = 'Masuk dulu untuk membayar.');
      return;
    }
    setState(() {
      _stage = _Stage.creating;
      _error = null;
    });
    try {
      final order = await context.read<PaymentRepository>().create(context.read<CheckoutProvider>().toPaymentRequest());
      if (!mounted) return;
      setState(() {
        _order = order;
        _stage = _Stage.waiting;
      });
      _poll = Timer.periodic(PaymentScreen.pollInterval, (_) => _check());
      _clock = Timer.periodic(const Duration(seconds: 1), (_) => _tick());
    } on ApiException catch (e) {
      _fail(e.message);
    } catch (e) {
      _fail('Gagal membuat tagihan: ${e.runtimeType}: $e');
    }
  }

  void _fail(String message) {
    if (!mounted) return;
    setState(() {
      _stage = _Stage.choose;
      _error = message;
    });
  }

  /// Polling status. Juga dipanggil tombol "Cek status pembayaran".
  Future<void> _check({bool manual = false}) async {
    final current = _order;
    if (current == null || _checking) return;
    setState(() => _checking = true);
    try {
      final order = await context.read<PaymentRepository>().get(current.id);
      if (!mounted) return;
      _order = order;
      if (order.isPaid) return _finish(order);
      if (!order.isPending) return _expire();
      if (manual) _toast('Pembayaran belum diterima. Status: ${order.statusLabel}');
    } catch (_) {
      // Jaringan putus sesaat: coba lagi di putaran berikutnya
      if (manual && mounted) _toast('Gagal memeriksa status. Coba lagi.');
    } finally {
      if (mounted) setState(() => _checking = false);
    }
  }

  void _tick() {
    final deadline = _order?.payBefore;
    if (!mounted) return;
    // Lewat batas bayar: minta server memastikan (server yang melepas kursi)
    if (deadline != null && DateTime.now().isAfter(deadline)) _check();
    setState(() {});
  }

  void _expire() {
    _poll?.cancel();
    _clock?.cancel();
    setState(() => _stage = _Stage.expired);
  }

  void _finish(PaymentOrder paid) {
    _poll?.cancel();
    _clock?.cancel();
    final order = context.read<CheckoutProvider>().buildPaidOrder(code: paid.code, paidTotal: paid.total);
    context.read<OrdersProvider>().add(order);
    Navigator.pushNamedAndRemoveUntil(context, '/ticket', (r) => r.isFirst, arguments: order);
  }

  /// Mode demo (jadwal contoh, tanpa backend): tidak ada tagihan sungguhan.
  Future<void> _simulatePaid() async {
    setState(() => _stage = _Stage.creating);
    await Future<void>.delayed(const Duration(milliseconds: 1500));
    if (!mounted) return;
    final order = context.read<CheckoutProvider>().buildPaidOrder();
    context.read<OrdersProvider>().add(order);
    Navigator.pushNamedAndRemoveUntil(context, '/ticket', (r) => r.isFirst, arguments: order);
  }

  void _toast(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _openPaymentPage() async {
    final url = _order?.paymentUrl;
    if (url == null) return;
    final opened = await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication).catchError((_) => false);
    if (!opened && mounted) _toast('Tidak dapat membuka halaman pembayaran.');
  }

  @override
  Widget build(BuildContext context) {
    final co = context.watch<CheckoutProvider>();
    if (!co.ready) return const Scaffold(body: Center(child: Text('Tidak ada pesanan.')));
    final total = _order?.total ?? co.total;

    return PopScope(
      canPop: _stage != _Stage.waiting,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _confirmLeave();
      },
      child: Scaffold(
        appBar: AppBar(title: const Text('Pembayaran')),
        body: ListView(padding: const EdgeInsets.all(16), children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(color: AppColors.tealSoft, borderRadius: BorderRadius.circular(16)),
            child: Row(children: [
              const Expanded(child: Text('Total bayar', style: TextStyle(fontWeight: FontWeight.w700))),
              Text(rupiah(total), style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: AppColors.darkTeal)),
            ]),
          ),
          const SizedBox(height: 16),
          ...switch (_stage) {
            _Stage.choose || _Stage.creating => _chooseMethod(co),
            _Stage.waiting => _waiting(_order!),
            _Stage.expired => _expired(),
          },
        ]),
        bottomNavigationBar: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
            child: SizedBox(width: double.infinity, child: _bottomButton()),
          ),
        ),
      ),
    );
  }

  Widget _bottomButton() => switch (_stage) {
        _Stage.choose => ElevatedButton(onPressed: _pay, child: Text(_demoMode ? 'Bayar (simulasi demo)' : 'Bayar sekarang')),
        _Stage.creating => const ElevatedButton(onPressed: null, child: Text('Membuat tagihan…')),
        _Stage.waiting => ElevatedButton(
            onPressed: _checking ? null : () => _check(manual: true),
            child: Text(_checking ? 'Memeriksa pembayaran…' : 'Cek status pembayaran'),
          ),
        _Stage.expired => ElevatedButton(onPressed: () => Navigator.pop(context), child: const Text('Pilih kursi lagi')),
      };

  List<Widget> _chooseMethod(CheckoutProvider co) => [
        const Text('Metode pembayaran', style: TextStyle(fontWeight: FontWeight.w800)),
        const SizedBox(height: 8),
        for (final m in PayMethod.values)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: InkWell(
              borderRadius: BorderRadius.circular(14),
              onTap: _stage == _Stage.creating ? null : () => co.setMethod(m),
              child: Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: co.method == m ? AppColors.teal : AppColors.border, width: co.method == m ? 2 : 1),
                ),
                child: Row(children: [
                  Expanded(
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text(m.label, style: const TextStyle(fontWeight: FontWeight.w800)),
                      Text(m.subtitle, style: const TextStyle(fontSize: 12, color: AppColors.muted)),
                    ]),
                  ),
                  Icon(co.method == m ? Icons.radio_button_checked : Icons.radio_button_off,
                      color: co.method == m ? AppColors.teal : AppColors.faint),
                ]),
              ),
            ),
          ),
        if (_error != null) ...[
          const SizedBox(height: 4),
          Text(_error!, style: const TextStyle(color: AppColors.error, fontWeight: FontWeight.w600)),
        ],
      ];

  List<Widget> _waiting(PaymentOrder o) {
    final left = o.payBefore?.difference(DateTime.now());
    final isQris = o.qrString != null;
    return [
      Center(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(color: const Color(0xFFFFF4D6), borderRadius: BorderRadius.circular(20)),
          child: Text(o.statusLabel,
              style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: Color(0xFF8A5A00), letterSpacing: 0.5)),
        ),
      ),
      const SizedBox(height: 14),
      if (isQris)
        Center(
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: AppColors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: AppColors.border)),
            child: QrImageView(data: o.qrString!, size: 220),
          ),
        )
      else if (o.vaNumber != null)
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(color: AppColors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: AppColors.border)),
          child: Column(children: [
            Text(o.bankName ?? 'Virtual Account', style: const TextStyle(fontWeight: FontWeight.w700)),
            const SizedBox(height: 6),
            SelectableText(_groupDigits(o.vaNumber!),
                textAlign: TextAlign.center, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800, letterSpacing: 1)),
            TextButton.icon(
              onPressed: () {
                Clipboard.setData(ClipboardData(text: o.vaNumber!));
                _toast('Nomor VA disalin');
              },
              icon: const Icon(Icons.copy_rounded, size: 18, color: AppColors.teal),
              label: const Text('Salin nomor VA', style: TextStyle(color: AppColors.teal, fontWeight: FontWeight.w800)),
            ),
          ]),
        ),
      const SizedBox(height: 12),
      Text(
        isQris ? 'Scan QR di atas pakai e-wallet / m-banking.' : 'Transfer tepat sesuai total ke nomor VA di atas.',
        textAlign: TextAlign.center,
        style: const TextStyle(color: AppColors.muted),
      ),
      const SizedBox(height: 6),
      if (left != null)
        Text(
          left.isNegative ? 'Batas bayar habis, memeriksa status…' : 'Bayar dalam ${_countdown(left)}',
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 13, color: AppColors.error, fontWeight: FontWeight.w700),
        ),
      const SizedBox(height: 4),
      Text('Kode pesanan ${o.code} · status diperbarui otomatis',
          textAlign: TextAlign.center, style: const TextStyle(fontSize: 12, color: AppColors.faint)),
      if (o.paymentUrl != null)
        Center(
          child: TextButton(
            onPressed: _openPaymentPage,
            child: const Text('Buka halaman pembayaran Komerce', style: TextStyle(color: AppColors.teal, fontWeight: FontWeight.w700)),
          ),
        ),
    ];
  }

  List<Widget> _expired() => const [
        Icon(Icons.timer_off_rounded, size: 56, color: AppColors.error),
        SizedBox(height: 10),
        Text('Waktu pembayaran habis', textAlign: TextAlign.center, style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
        SizedBox(height: 6),
        Text('Kursi sudah dilepas. Silakan pilih kursi dan buat pesanan baru.',
            textAlign: TextAlign.center, style: TextStyle(color: AppColors.muted)),
      ];

  Future<void> _confirmLeave() async {
    final leave = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Tinggalkan pembayaran?'),
        content: const Text('Tagihan tetap berlaku sampai batas waktu. Jika sudah membayar, e-tiket terbit otomatis setelah pembayaran diterima.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Tetap di sini')),
          TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Tinggalkan', style: TextStyle(color: AppColors.error))),
        ],
      ),
    );
    if (leave == true && mounted) {
      _poll?.cancel();
      _clock?.cancel();
      Navigator.pop(context);
    }
  }

  static String _countdown(Duration d) {
    final m = d.inMinutes;
    final s = d.inSeconds % 60;
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  static String _groupDigits(String s) => s.replaceAllMapped(RegExp(r'.{4}(?=.)'), (m) => '${m[0]} ');
}
