import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/auth_provider.dart';
import '../providers/orders_provider.dart';
import '../widgets/cardbus_bottom_nav.dart';
import 'home_screen.dart';
import 'orders_screen.dart';
import 'profile_screen.dart';
import 'promo_screen.dart';

/// Kerangka 4 tab: Beranda · Tiket Saya · Promo · Lainnya.
class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _index = 0;

  /// Pindah tab. Tiket Saya & Profil selalu ditarik ulang dari server saat dibuka.
  void _go(int i) {
    if (i == 1) context.read<OrdersProvider>().refresh();
    if (i == 3) context.read<AuthProvider>().refreshProfile();
    setState(() => _index = i);
  }

  @override
  Widget build(BuildContext context) {
    final active = context.watch<OrdersProvider>().activeCount;
    return Scaffold(
      body: IndexedStack(index: _index, children: [
        HomeScreen(onOpenPromo: () => _go(2), onOpenProfile: () => _go(3)),
        const OrdersScreen(),
        const PromoScreen(),
        const ProfileScreen(),
      ]),
      bottomNavigationBar: CardBusBottomNav(currentIndex: _index, onTap: _go, ticketBadge: active),
    );
  }
}
