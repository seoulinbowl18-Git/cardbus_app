import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../theme/app_colors.dart';

/// Riwayat pesanan & refund: syarat pembatalan + kontak CS via WhatsApp.
class RefundHistoryScreen extends StatelessWidget {
  const RefundHistoryScreen({super.key});

  // TODO: ganti dengan nomor WhatsApp Admin CS yang asli.
  static final _csWhatsApp = Uri.parse(
    'https://wa.me/6281234567890?text=Halo%20CS%20CardBus,%20saya%20butuh%20bantuan%20terkait%20pesanan/refund',
  );

  // TODO: isi syarat & ketentuan pembatalan / refund yang resmi.
  static const _terms = <String>[
    'Ketentuan pembatalan akan diumumkan di sini.',
    'Ketentuan pengembalian dana (refund) akan diumumkan di sini.',
    'Ketentuan batas waktu pengajuan akan diumumkan di sini.',
  ];

  Future<void> _contactCs(BuildContext context) async {
    final messenger = ScaffoldMessenger.of(context);
    var opened = false;
    try {
      opened = await launchUrl(_csWhatsApp, mode: LaunchMode.externalApplication);
    } catch (_) {}
    if (!opened) {
      messenger.showSnackBar(const SnackBar(content: Text('Tidak dapat membuka WhatsApp. Coba lagi nanti.')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(title: const Text('Riwayat Pesanan & Refund')),
      body: ListView(padding: const EdgeInsets.all(16), children: [
        _card(Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Row(children: [
            Icon(Icons.policy_outlined, color: AppColors.teal),
            SizedBox(width: 8),
            Expanded(
              child: Text('Syarat & Ketentuan Pembatalan / Refund',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800)),
            ),
          ]),
          const SizedBox(height: 12),
          for (var i = 0; i < _terms.length; i++)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('${i + 1}. ', style: const TextStyle(color: AppColors.muted, height: 1.5)),
                Expanded(child: Text(_terms[i], style: const TextStyle(color: AppColors.muted, height: 1.5))),
              ]),
            ),
        ])),
        const SizedBox(height: 16),
        Material(
          color: AppColors.teal,
          borderRadius: BorderRadius.circular(14),
          child: InkWell(
            borderRadius: BorderRadius.circular(14),
            onTap: () => _contactCs(context),
            child: const Padding(
              padding: EdgeInsets.all(16),
              child: Row(children: [
                CircleAvatar(
                  radius: 22,
                  backgroundColor: Color(0x33FFFFFF),
                  child: Icon(Icons.support_agent_rounded, color: AppColors.white),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text('Kontak Kami / Hubungi CS',
                        style: TextStyle(color: AppColors.white, fontSize: 15, fontWeight: FontWeight.w800)),
                    SizedBox(height: 2),
                    Text('Chat Admin CardBus lewat WhatsApp',
                        style: TextStyle(color: Color(0xDDFFFFFF), fontSize: 12)),
                  ]),
                ),
                Icon(Icons.chevron_right_rounded, color: AppColors.white),
              ]),
            ),
          ),
        ),
      ]),
    );
  }

  Widget _card(Widget child) => Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.border),
        ),
        child: child,
      );
}
