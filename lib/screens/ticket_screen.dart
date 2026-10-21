import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../models/booking_order.dart';
import '../theme/app_colors.dart';
import '../utils/formatters.dart';

/// E-tiket. Argumen route: BookingOrder.
class TicketScreen extends StatelessWidget {
  const TicketScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final o = ModalRoute.of(context)!.settings.arguments as BookingOrder;
    return Scaffold(
      appBar: AppBar(title: const Text('E-tiket')),
      body: ListView(padding: const EdgeInsets.all(16), children: [
        Container(
          decoration: BoxDecoration(color: AppColors.white, borderRadius: BorderRadius.circular(20), border: Border.all(color: AppColors.border)),
          child: Column(children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(
                gradient: AppColors.headerGradient,
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              ),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('PO ${o.poName}', style: const TextStyle(color: AppColors.white, fontWeight: FontWeight.w800, fontSize: 18)),
                Text(o.busClass, style: const TextStyle(color: Color(0xFFCFE9E6))),
                const SizedBox(height: 6),
                Text(o.isActive ? 'LUNAS · AKTIF' : o.status.label.toUpperCase(),
                    style: const TextStyle(color: AppColors.gold, fontWeight: FontWeight.w800, fontSize: 12)),
              ]),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(children: [
                QrImageView(data: o.code, size: 170),
                Text('Kode booking: ${o.code}', style: const TextStyle(fontWeight: FontWeight.w800, letterSpacing: 1)),
                const Divider(height: 28),
                _row('Rute', '${o.from} → ${o.to}'),
                _row('Tanggal', dateLabel(o.date)),
                _row('Berangkat', '${o.depart} · ${o.boardPoint}'),
                _row('Tiba', '${o.arrive} · ${o.dropPoint}'),
                _row('Kursi', o.seats.join(', ')),
                _row('Penumpang', o.passengerNames.join(', ')),
                _row('Dibayar', '${rupiah(o.total)} · ${o.paymentMethod}'),
              ]),
            ),
          ]),
        ),
        const SizedBox(height: 12),
        const Text('Tunjukkan QR ini ke kru / agen saat naik bus.', textAlign: TextAlign.center, style: TextStyle(color: AppColors.muted)),
        const SizedBox(height: 16),
        OutlinedButton(
          onPressed: () => Navigator.popUntil(context, (r) => r.isFirst),
          child: const Text('Kembali ke beranda'),
        ),
      ]),
    );
  }

  Widget _row(String k, String v) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          SizedBox(width: 92, child: Text(k, style: const TextStyle(color: AppColors.muted, fontSize: 13))),
          Expanded(child: Text(v, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13))),
        ]),
      );
}
