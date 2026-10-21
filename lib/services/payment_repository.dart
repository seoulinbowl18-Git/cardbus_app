import '../models/payment_order.dart';
import 'api_service.dart';

/// Pembayaran Komerce lewat backend CardBus. Aplikasi hanya menampilkan QR / VA dan
/// memantau status; status LUNAS hanya bisa diubah server (webhook / cek ke Komerce).
class PaymentRepository {
  PaymentRepository(this.api);

  final ApiService api;

  /// Kunci kursi + buat tagihan. Melempar [ApiException] (mis. 409 kursi diambil orang lain).
  Future<PaymentOrder> create(Map<String, dynamic> body) async {
    final data = await api.post('/api/payments/create', body);
    return PaymentOrder.fromJson(Map<String, dynamic>.from(data as Map));
  }

  /// Status terkini pesanan (dipanggil berkala selama menunggu pembayaran).
  Future<PaymentOrder> get(String id) async {
    final data = await api.get('/api/orders/$id');
    return PaymentOrder.fromJson(Map<String, dynamic>.from(data as Map));
  }
}
