import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'app.dart';
import 'services/api_service.dart';
import 'services/trip_repository.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('id_ID');

  // Default: backend Railway. Lokal (emulator): --dart-define=API_URL=http://10.0.2.2:4000
  const apiUrl = String.fromEnvironment('API_URL', defaultValue: ApiService.defaultBaseUrl);
  // Demo tanpa backend: --dart-define=USE_MOCK_TRIPS=true (jadwal contoh, tidak bisa dibayar)
  const useMockTrips = bool.fromEnvironment('USE_MOCK_TRIPS');
  final repository = TripRepository(ApiService(baseUrl: apiUrl), useBackend: !useMockTrips);

  runApp(CardBusApp(repository: repository));
}
