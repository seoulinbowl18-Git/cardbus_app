import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'providers/auth_provider.dart';
import 'providers/checkout_provider.dart';
import 'providers/orders_provider.dart';
import 'providers/search_provider.dart';
import 'screens/login_screen.dart';
import 'screens/main_shell.dart';
import 'screens/passenger_screen.dart';
import 'screens/payment_screen.dart';
import 'screens/point_picker_screen.dart';
import 'screens/results_screen.dart';
import 'screens/splash_screen.dart';
import 'screens/ticket_screen.dart';
import 'services/payment_repository.dart';
import 'services/trip_repository.dart';
import 'theme/app_theme.dart';

class CardBusApp extends StatelessWidget {
  const CardBusApp({super.key, required this.repository});

  final TripRepository repository;

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<TripRepository>.value(value: repository),
        Provider<PaymentRepository>(create: (_) => PaymentRepository(repository.api)),
        ChangeNotifierProvider(create: (_) => AuthProvider(repository.api)..ensureLoaded()),
        ChangeNotifierProvider(create: (_) => SearchProvider(repository)),
        ChangeNotifierProvider(create: (ctx) => CheckoutProvider(ctx.read<AuthProvider>())),
        ChangeNotifierProvider(create: (ctx) => OrdersProvider(ctx.read<AuthProvider>(), repository)),
      ],
      child: MaterialApp(
        title: 'CardBus',
        debugShowCheckedModeBanner: false,
        theme: buildAppTheme(),
        home: const SplashScreen(),
        routes: {
          '/home': (_) => const MainShell(),
          '/results': (_) => const ResultsScreen(),
          '/point-picker': (_) => const PointPickerScreen(),
          '/passenger': (_) => const PassengerScreen(),
          '/payment': (_) => const PaymentScreen(),
          '/ticket': (_) => const TicketScreen(),
          '/login': (_) => const LoginScreen(),
        },
      ),
    );
  }
}
