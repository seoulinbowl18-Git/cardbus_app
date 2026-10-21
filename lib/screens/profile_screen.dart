import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../models/saved_passenger.dart';
import '../providers/auth_provider.dart';
import '../services/api_service.dart';
import '../theme/app_colors.dart';
import '../widgets/avatar_widget.dart';
import 'login_screen.dart';
import 'refund_history_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _notifEnabled = true;
  bool _busy = false;
  final TextEditingController _nameController = TextEditingController();
  late final AuthProvider _auth = context.read<AuthProvider>();
  String? _syncedName;

  @override
  void initState() {
    super.initState();
    _syncName();
    _auth.addListener(_syncName);
  }

  @override
  void dispose() {
    _auth.removeListener(_syncName);
    _nameController.dispose();
    super.dispose();
  }

  /// Isi field nama dari data akun (mis. setelah login / profil dimuat dari server).
  void _syncName() {
    if (_auth.name == _syncedName) return;
    _syncedName = _auth.name;
    _nameController.text = _auth.name ?? '';
  }

  void _toast(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  /// Jalankan aksi simpan ke backend; tampilkan pesan sukses / error.
  Future<void> _run(Future<String?> Function() action) async {
    if (_busy) return;
    setState(() => _busy = true);
    try {
      final message = await action();
      if (mounted && message != null) _toast(message);
    } on ApiException catch (e) {
      if (mounted) _toast(e.message);
    } catch (e) {
      if (mounted) _toast('Gagal: ${e.runtimeType}: $e');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _saveProfile(AuthProvider auth) async {
    final name = _nameController.text.trim().replaceAll(RegExp(r'\s+'), ' ');
    if (name.length < 3) return _toast('Isi nama minimal 3 huruf');
    FocusScope.of(context).unfocus();
    await _run(() async {
      await auth.updateProfile(name: name);
      return 'Profil disimpan';
    });
  }

  Future<void> _addPassenger(AuthProvider auth) async {
    if (!auth.isLoggedIn) return _toast('Masuk dulu untuk menyimpan penumpang');
    final passenger = await showDialog<SavedPassenger>(context: context, builder: (_) => const _AddPassengerDialog());
    if (passenger == null || !mounted) return;
    await _run(() async {
      final added = await auth.addPassenger(passenger);
      return added ? 'Penumpang disimpan' : '${passenger.name} sudah ada di daftar';
    });
  }

  Future<void> _pickAvatar(AuthProvider auth) async {
    if (!auth.isLoggedIn) return _toast('Masuk dulu untuk mengganti foto');
    await _run(() async {
      try {
        // Setelah tersimpan, AuthProvider memperbarui photoUrl → AvatarWidget ikut berganti.
        return await auth.pickAvatar() ? 'Foto profil disimpan' : null;
      } on PlatformException catch (e) {
        // Galeri gagal dibuka (mis. izin ditolak) — bukan masalah koneksi.
        throw ApiException(0, 'Tidak dapat membuka galeri: ${e.message ?? e.code}');
      }
    });
  }

  /// Hapus token + cache akun, lalu kembali ke halaman Login (nomor WhatsApp → OTP).
  /// Navigator diambil sebelum `await` agar tetap valid walau halaman ini dibangun ulang.
  Future<void> _signOut(BuildContext dialogContext) async {
    final navigator = Navigator.of(context, rootNavigator: true);
    Navigator.pop(dialogContext);
    try {
      await _auth.signOut();
    } catch (e) {
      debugPrint('Gagal menghapus sesi: $e');
    }
    // Stack dibersihkan → LoginScreen jadi route satu-satunya.
    navigator.pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final displayName = (auth.name?.trim().isNotEmpty ?? false) ? auth.name!.trim() : 'Pengguna CardBus';
    final displayPhone = (auth.isLoggedIn && auth.phone.isNotEmpty) ? auth.phone : 'Belum ditautkan';

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Header Hijau Profil
            Container(
              padding: const EdgeInsets.fromLTRB(20, 50, 20, 25),
              decoration: const BoxDecoration(
                color: AppColors.teal,
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(24),
                  bottomRight: Radius.circular(24),
                ),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      // Foto kustom jika ada; selain itu inisial nama / ikon orang.
                      // Ketuk untuk pilih foto dari galeri.
                      AvatarWidget(size: 70, editable: true, onTap: _busy ? null : () => _pickAvatar(auth)),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              displayName,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              displayPhone,
                              style: const TextStyle(
                                fontSize: 13,
                                color: Colors.white70,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 3,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                auth.isLoggedIn ? 'WHATSAPP TERVERIFIKASI' : 'BELUM MASUK',
                                style: const TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                            if (auth.photoUrl != null) ...[
                              const SizedBox(height: 4),
                              GestureDetector(
                                onTap: _busy
                                    ? null
                                    : () => _run(() async {
                                          await auth.removeAvatar();
                                          return 'Foto profil dihapus';
                                        }),
                                child: const Text(
                                  'Hapus foto',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Color(0xFFFFC107),
                                    decoration: TextDecoration.underline,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Kotak Statistik Pesanan
                  Container(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildStatItem('0', 'Pesanan'),
                        Container(height: 25, width: 1, color: Colors.grey.shade300),
                        _buildStatItem('0', 'Tiket aktif'),
                        Container(height: 25, width: 1, color: Colors.grey.shade300),
                        _buildStatItem('Rp 0', 'Total transaksi'),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Konten Form dan Menu Bawah
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  // Card Data Pemesan
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.03),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Data pemesan',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Dipakai untuk isi otomatis saat pesan tiket',
                          style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                        ),
                        const SizedBox(height: 16),
                        const Text('Nama lengkap', style: TextStyle(fontSize: 12, color: Colors.grey)),
                        const SizedBox(height: 6),
                        TextField(
                          controller: _nameController,
                          textCapitalization: TextCapitalization.words,
                          decoration: InputDecoration(
                            hintText: 'Nama lengkap sesuai KTP',
                            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                        ),
                        const SizedBox(height: 12),
                        const Text('Nomor WhatsApp', style: TextStyle(fontSize: 12, color: Colors.grey)),
                        const SizedBox(height: 6),
                        // Nomor = identitas login (sudah diverifikasi OTP), jadi hanya ditampilkan.
                        TextFormField(
                          key: ValueKey(auth.phone),
                          initialValue: auth.phone,
                          readOnly: true,
                          decoration: InputDecoration(
                            hintText: 'Belum ditautkan',
                            suffixIcon: auth.isLoggedIn ? const Icon(Icons.verified_rounded, color: AppColors.teal, size: 20) : null,
                            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                        ),
                        const SizedBox(height: 16),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: _busy ? null : () => _saveProfile(auth),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.teal,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                            ),
                            child: _busy
                                ? const SizedBox(
                                    width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2.4, color: Colors.white))
                                : const Text('Simpan perubahan', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Card Penumpang Tersimpan
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.03),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Penumpang tersimpan',
                                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    auth.savedPassengers.isEmpty
                                        ? 'Belum ada penumpang tersimpan.'
                                        : '${auth.savedPassengers.length} penumpang tersimpan',
                                    style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                                  ),
                                ],
                              ),
                            ),
                            OutlinedButton(
                              onPressed: _busy ? null : () => _addPassenger(auth),
                              style: OutlinedButton.styleFrom(
                                side: const BorderSide(color: AppColors.teal),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                              ),
                              child: const Text('+ Tambah', style: TextStyle(color: AppColors.teal)),
                            ),
                          ],
                        ),
                        for (final p in auth.savedPassengers) ...[
                          const Divider(height: 20),
                          Row(
                            children: [
                              const CircleAvatar(
                                radius: 16,
                                backgroundColor: AppColors.tealSoft,
                                child: Icon(Icons.person_rounded, size: 18, color: AppColors.teal),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(p.name, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                                    if (p.phone != null)
                                      Text(p.phone!, style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
                                  ],
                                ),
                              ),
                              IconButton(
                                tooltip: 'Hapus penumpang',
                                visualDensity: VisualDensity.compact,
                                onPressed: _busy
                                    ? null
                                    : () => _run(() async {
                                          await auth.removePassenger(p);
                                          return '${p.name} dihapus dari daftar';
                                        }),
                                icon: Icon(Icons.delete_outline_rounded, size: 20, color: Colors.grey.shade600),
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Card Pengaturan & Riwayat
                  Material(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    elevation: 0,
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey.shade200),
                      ),
                      child: Column(
                        children: [
                          SwitchListTile(
                            title: const Text('Notifikasi perjalanan', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                            subtitle: const Text('Pengingat keberangkatan & status refund', style: TextStyle(fontSize: 11)),
                            value: _notifEnabled,
                            activeColor: AppColors.teal,
                            onChanged: (val) {
                              setState(() {
                                _notifEnabled = val;
                              });
                            },
                          ),
                          const Divider(height: 1),
                          ListTile(
                            title: const Text('Riwayat pesanan & refund', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                            trailing: const Icon(Icons.chevron_right, size: 20),
                            onTap: () => Navigator.of(context).push(
                              MaterialPageRoute(builder: (_) => const RefundHistoryScreen()),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Sudah login → tombol Keluar (dengan konfirmasi); tamu → tombol Masuk / Daftar.
                  if (auth.isLoggedIn)
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton(
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (BuildContext dialogContext) {
                              return AlertDialog(
                                title: const Text('Keluar Akun'),
                                content: const Text('Apakah Anda yakin ingin keluar dari akun ini?'),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.pop(dialogContext),
                                    child: const Text('Batal', style: TextStyle(color: Colors.grey)),
                                  ),
                                  TextButton(
                                    onPressed: () => _signOut(dialogContext),
                                    child: const Text('Keluar', style: TextStyle(color: Colors.red)),
                                  ),
                                ],
                              );
                            },
                          );
                        },
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: Colors.red),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                        child: const Text(
                          'Keluar dari akun',
                          style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
                        ),
                      ),
                    )
                  else
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () => Navigator.of(context).push(
                          MaterialPageRoute(builder: (_) => const LoginScreen()),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.teal,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                        child: const Text(
                          'Masuk / Daftar',
                          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  const SizedBox(height: 30),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String value, String label) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.bold,
            color: AppColors.teal,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            color: Colors.grey.shade600,
          ),
        ),
      ],
    );
  }
}

/// Form "Nama Penumpang" + nomor HP opsional. Mengembalikan [SavedPassenger], atau null jika batal.
class _AddPassengerDialog extends StatefulWidget {
  const _AddPassengerDialog();

  @override
  State<_AddPassengerDialog> createState() => _AddPassengerDialogState();
}

class _AddPassengerDialogState extends State<_AddPassengerDialog> {
  final _form = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _phone = TextEditingController();

  static final _phonePattern = RegExp(r'^(\+?62|0)8\d{7,11}$');

  @override
  void dispose() {
    _name.dispose();
    _phone.dispose();
    super.dispose();
  }

  String get _cleanPhone => _phone.text.replaceAll(RegExp(r'[\s\-().]'), '');

  void _save() {
    if (!_form.currentState!.validate()) return;
    Navigator.pop(
      context,
      SavedPassenger(
        name: _name.text.trim().replaceAll(RegExp(r'\s+'), ' '),
        phone: _cleanPhone.isEmpty ? null : _cleanPhone,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Tambah Penumpang'),
      content: Form(
        key: _form,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: _name,
              autofocus: true,
              textCapitalization: TextCapitalization.words,
              textInputAction: TextInputAction.next,
              decoration: const InputDecoration(labelText: 'Nama Penumpang', hintText: 'Nama lengkap sesuai KTP'),
              validator: (v) => (v == null || v.trim().length < 3) ? 'Isi nama minimal 3 huruf' : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _phone,
              keyboardType: TextInputType.phone,
              textInputAction: TextInputAction.done,
              decoration: const InputDecoration(labelText: 'Nomor HP (opsional)', hintText: '08xxxxxxxxxx'),
              validator: (_) =>
                  (_cleanPhone.isEmpty || _phonePattern.hasMatch(_cleanPhone)) ? null : 'Nomor HP tidak valid (contoh: 081234567890)',
              onFieldSubmitted: (_) => _save(),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Batal', style: TextStyle(color: Colors.grey)),
        ),
        ElevatedButton(
          onPressed: _save,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.teal,
            minimumSize: const Size(0, 44),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
          child: const Text('Simpan Penumpang', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        ),
      ],
    );
  }
}
