import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../data/mock_data.dart';
import '../providers/auth_provider.dart';
import '../theme/app_colors.dart';
import '../widgets/feature_strip.dart';
import '../widgets/featured_section.dart';
import '../widgets/home_header.dart';
import '../widgets/promo_banner_widget.dart';
import '../widgets/promo_carousel.dart';
import '../widgets/search_card_widget.dart';
import '../widgets/section_title.dart';

/// Beranda: header + kartu cari, Promo & Info, Produk unggulan,
/// Promo spesial, keunggulan CardBus.
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key, required this.onOpenPromo, required this.onOpenProfile});

  final VoidCallback onOpenPromo;
  final VoidCallback onOpenProfile;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _showNewUserPromo());
  }

  /// Pop-up diskon 20% untuk pengguna baru.
  /// TODO: untuk testing selalu tampil; sebelum rilis, kembalikan cek
  /// SharedPreferences ('promo_new_user_shown') agar hanya muncul sekali.
  void _showNewUserPromo() {
    if (!mounted) return;
    showDialog<void>(context: context, builder: (_) => const _NewUserPromoDialog());
  }

  @override
  Widget build(BuildContext context) {
    final onOpenPromo = widget.onOpenPromo;
    final onOpenProfile = widget.onOpenProfile;
    final name = context.select<AuthProvider, String?>((a) => a.name);
    final firstName = (name == null || name.isEmpty) ? 'Kak' : name.split(' ').first;
    final top = MediaQuery.paddingOf(context).top;

    return SingleChildScrollView(
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        Stack(children: [
          HomeHeaderBackground(height: top + 190),
          Column(children: [
            HomeHeader(userName: firstName, onAvatarTap: onOpenProfile),
            const SizedBox(height: 18),
            const SearchCardWidget(),
          ]),
        ]),
        const SizedBox(height: 24),
        SectionTitle(
          title: 'Promo & Info',
          trailing: TextButton(
            onPressed: onOpenPromo,
            child: const Text('Lihat semua ›', style: TextStyle(color: AppColors.teal, fontWeight: FontWeight.w800, fontSize: 12)),
          ),
        ),
        const SizedBox(height: 6),
        PromoCarousel(promos: MockData.topPromos),
        const SizedBox(height: 18),
        FeaturedSection(products: MockData.featured),
        const SizedBox(height: 20),
        PromoSpecialSection(promos: MockData.midPromos),
        const SizedBox(height: 20),
        const FeatureStrip(),
        const SizedBox(height: 24),
      ]),
    );
  }
}

class _NewUserPromoDialog extends StatelessWidget {
  const _NewUserPromoDialog();

  static const _code = 'CARDBUSNEW';

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 28),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      clipBehavior: Clip.antiAlias,
      child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        Container(
          color: AppColors.teal,
          padding: const EdgeInsets.fromLTRB(20, 12, 8, 22),
          child: Column(children: [
            Align(
              alignment: Alignment.topRight,
              child: IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.close_rounded, color: AppColors.white),
              ),
            ),
            const Icon(Icons.local_offer_rounded, size: 48, color: AppColors.gold),
            const SizedBox(height: 10),
            const Text('Diskon 20%',
                style: TextStyle(color: AppColors.white, fontSize: 30, fontWeight: FontWeight.w800)),
            const SizedBox(height: 4),
            const Text('Khusus pengguna baru CardBus',
                style: TextStyle(color: Color(0xDDFFFFFF), fontSize: 14, fontWeight: FontWeight.w600)),
          ]),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
          child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            const Text('Pakai kode promo ini saat pembayaran tiket pertamamu:',
                textAlign: TextAlign.center, style: TextStyle(color: AppColors.muted, fontSize: 13)),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                color: AppColors.tealSoft,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.teal, width: 1.4),
              ),
              child: Row(children: [
                const Expanded(
                  child: Text(_code,
                      style: TextStyle(color: AppColors.teal, fontSize: 18, fontWeight: FontWeight.w800, letterSpacing: 2)),
                ),
                TextButton.icon(
                  onPressed: () {
                    Clipboard.setData(const ClipboardData(text: _code));
                    ScaffoldMessenger.of(context)
                        .showSnackBar(const SnackBar(content: Text('Kode promo CARDBUSNEW disalin')));
                  },
                  icon: const Icon(Icons.copy_rounded, size: 18, color: AppColors.teal),
                  label: const Text('Salin', style: TextStyle(color: AppColors.teal, fontWeight: FontWeight.w800)),
                ),
              ]),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.teal),
              onPressed: () => Navigator.pop(context),
              child: const Text('Pesan Tiket Sekarang'),
            ),
          ]),
        ),
      ]),
    );
  }
}
