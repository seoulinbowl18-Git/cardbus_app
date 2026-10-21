import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/auth_provider.dart';
import '../providers/checkout_provider.dart';
import '../theme/app_colors.dart';
import '../utils/formatters.dart';

/// Data penumpang: cukup nama lengkap (tanpa NIK) + kontak pemesan.
class PassengerScreen extends StatefulWidget {
  const PassengerScreen({super.key});

  @override
  State<PassengerScreen> createState() => _PassengerScreenState();
}

class _PassengerScreenState extends State<PassengerScreen> {
  final _form = GlobalKey<FormState>();
  bool _agree = false;
  bool _showAgreeError = false;

  // Kontak pemesan selalu dari profil server akun yang sedang login (bukan cache).
  late final AuthProvider _auth = context.read<AuthProvider>();
  late final CheckoutProvider _co = context.read<CheckoutProvider>();
  late final _phone = TextEditingController(text: _co.phone.isNotEmpty ? _co.phone : _auth.phone);
  late final _email = TextEditingController(text: _co.email.isNotEmpty ? _co.email : (_auth.email ?? ''));
  bool _contactEdited = false;

  @override
  void initState() {
    super.initState();
    _auth.addListener(_fillContactFromProfile);
    _auth.refreshProfile();
  }

  @override
  void dispose() {
    _auth.removeListener(_fillContactFromProfile);
    _phone.dispose();
    _email.dispose();
    super.dispose();
  }

  /// Profil terbaru tiba dari server → isi kontak, kecuali user sudah mengetik sendiri.
  void _fillContactFromProfile() {
    if (_contactEdited) return;
    _phone.text = _auth.phone;
    _email.text = _auth.email ?? '';
  }

  @override
  Widget build(BuildContext context) {
    final co = context.watch<CheckoutProvider>();
    if (!co.ready) return const Scaffold(body: Center(child: Text('Pilih jadwal dulu.')));
    final t = co.trip!;

    return Scaffold(
      appBar: AppBar(title: const Text('Data penumpang')),
      body: Form(
        key: _form,
        child: ListView(padding: const EdgeInsets.all(16), children: [
          _card(Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('PO ${t.poName} · ${t.busClass}', style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15)),
            const SizedBox(height: 2),
            Text('${t.from} → ${t.to} · ${dateLabel(t.date)}, ${t.depart}', style: const TextStyle(color: AppColors.muted, fontSize: 12)),
            Text('Kursi ${co.seats.join(', ')} · ${co.tier!.name}', style: const TextStyle(color: AppColors.muted, fontSize: 12)),
          ])),
          const SizedBox(height: 12),
          const Text('Cukup nama lengkap tiap penumpang', style: TextStyle(fontSize: 12, color: AppColors.muted)),
          const SizedBox(height: 8),
          for (var i = 0; i < co.pax; i++)
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: TextFormField(
                initialValue: co.names[i],
                textCapitalization: TextCapitalization.words,
                decoration: InputDecoration(labelText: 'Penumpang ${i + 1} · kursi ${co.seats[i]}', hintText: 'Nama lengkap penumpang'),
                onChanged: (v) => co.setName(i, v),
                validator: (v) => (v == null || v.trim().length < 3) ? 'Isi nama minimal 3 huruf' : null,
              ),
            ),
          const SizedBox(height: 4),
          const Text('Kontak pemesan', style: TextStyle(fontWeight: FontWeight.w800)),
          const SizedBox(height: 8),
          TextFormField(
            controller: _phone,
            keyboardType: TextInputType.phone,
            decoration: const InputDecoration(labelText: 'Nomor WhatsApp', hintText: '08xxxxxxxxxx'),
            onChanged: (_) => _contactEdited = true,
            validator: (v) => RegExp(r'^08\d{8,11}$').hasMatch(v ?? '') ? null : 'Nomor harus 10–13 angka, diawali 08',
          ),
          const SizedBox(height: 10),
          TextFormField(
            controller: _email,
            keyboardType: TextInputType.emailAddress,
            decoration: const InputDecoration(labelText: 'Email (untuk e-tiket)'),
            onChanged: (_) => _contactEdited = true,
            validator: (v) => RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(v ?? '') ? null : 'Email tidak valid',
          ),
          CheckboxListTile(
            contentPadding: EdgeInsets.zero,
            controlAffinity: ListTileControlAffinity.leading,
            value: _agree,
            onChanged: (v) => setState(() => _agree = v ?? false),
            title: const Text('Saya setuju dengan syarat & ketentuan serta kebijakan pembatalan PO.', style: TextStyle(fontSize: 13)),
            subtitle: _showAgreeError ? const Text('Centang dulu untuk lanjut', style: TextStyle(color: AppColors.error)) : null,
          ),
        ]),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
          child: SizedBox(
            width: double.infinity,
            child: ElevatedButton(
            onPressed: () {
              final ok = _form.currentState!.validate();
              setState(() => _showAgreeError = !_agree);
              if (!ok || !_agree) return;
              co.phone = _phone.text.trim();
              co.email = _email.text.trim();
              Navigator.pushNamed(context, '/payment');
            },
            child: Text('Lanjut bayar · ${rupiah(co.total)}'),
          ),
          ),
        ),
      ),
    );
  }

  Widget _card(Widget child) => Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(color: AppColors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: AppColors.border)),
        child: child,
      );
}
