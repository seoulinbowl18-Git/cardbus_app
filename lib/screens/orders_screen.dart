import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/orders_provider.dart';
import '../theme/app_colors.dart';
import '../utils/formatters.dart';

class OrdersScreen extends StatelessWidget {
  const OrdersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<OrdersProvider>();
    final orders = provider.orders;
    return Scaffold(
      appBar: AppBar(title: const Text('Tiket Saya')),
      body: RefreshIndicator(
        onRefresh: provider.refresh,
        child: orders.isEmpty
            ? ListView(padding: const EdgeInsets.all(24), children: [
                const SizedBox(height: 120),
                if (provider.loading)
                  const Center(child: CircularProgressIndicator())
                else
                  Text(
                      provider.error != null
                          ? 'Gagal memuat tiket: ${provider.error}'
                          : 'Belum ada tiket. Yuk pesan dari beranda!',
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: AppColors.muted)),
              ])
            : ListView.separated(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16),
                itemCount: orders.length,
                separatorBuilder: (_, __) => const SizedBox(height: 10),
                itemBuilder: (context, i) {
                  final o = orders[i];
                  final active = o.status == 'Aktif';
                  return Material(
                    color: AppColors.white,
                    borderRadius: BorderRadius.circular(16),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(16),
                      onTap: () =>
                          Navigator.pushNamed(context, '/ticket', arguments: o),
                      child: Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: AppColors.border)),
                        child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(children: [
                                Expanded(
                                    child: Text('${o.from} → ${o.to}',
                                        style: const TextStyle(
                                            fontWeight: FontWeight.w800,
                                            fontSize: 15))),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 10, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: active
                                        ? AppColors.tealSoft
                                        : const Color(0xFFFBE9E9),
                                    borderRadius: BorderRadius.circular(999),
                                  ),
                                  child: Text(o.status,
                                      style: TextStyle(
                                          fontSize: 11,
                                          fontWeight: FontWeight.w800,
                                          color: active
                                              ? AppColors.teal
                                              : AppColors.error)),
                                ),
                              ]),
                              Text('PO ${o.poName} · ${o.busClass}',
                                  style: const TextStyle(
                                      fontSize: 12, color: AppColors.muted)),
                              Text(
                                  '${dateLabel(o.date)} · ${o.depart} · kursi ${o.seats.join(', ')}',
                                  style: const TextStyle(
                                      fontSize: 12, color: AppColors.muted)),
                              const SizedBox(height: 6),
                              Row(children: [
                                Text('Kode ${o.code}',
                                    style: const TextStyle(
                                        fontWeight: FontWeight.w800)),
                                const Spacer(),
                                if (active)
                                  TextButton(
                                    onPressed: () async {
                                      final ok = await showDialog<bool>(
                                        context: context,
                                        builder: (ctx) => AlertDialog(
                                          title: const Text('Batalkan tiket?'),
                                          content: const Text(
                                              'Dana kembali mengikuti ketentuan refund PO.'),
                                          actions: [
                                            TextButton(
                                                onPressed: () =>
                                                    Navigator.pop(ctx, false),
                                                child: const Text('Tidak')),
                                            TextButton(
                                                onPressed: () =>
                                                    Navigator.pop(ctx, true),
                                                child:
                                                    const Text('Ya, batalkan')),
                                          ],
                                        ),
                                      );
                                      if (ok == true && context.mounted)
                                        context
                                            .read<OrdersProvider>()
                                            .cancel(o.code);
                                    },
                                    child: const Text('Batalkan',
                                        style:
                                            TextStyle(color: AppColors.error)),
                                  ),
                              ]),
                            ]),
                      ),
                    ),
                  );
                },
              ),
      ),
    );
  }
}
