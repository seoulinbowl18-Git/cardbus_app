/// Pesanan + tagihan Komerce dari backend (POST /api/payments/create, GET /api/orders/:id).
class PaymentOrder {
  const PaymentOrder({
    required this.id,
    required this.code,
    required this.status,
    required this.statusLabel,
    required this.total,
    required this.method,
    this.qrString,
    this.vaNumber,
    this.bankName,
    this.paymentUrl,
    this.payBefore,
    this.ticketIssuedAt,
  });

  final String id;
  final String code;
  final String status; // pending | paid | expired | cancelled
  final String statusLabel; // MENUNGGU PEMBAYARAN | LUNAS | KEDALUWARSA | DIBATALKAN
  final int total;
  final String method; // qris | va_bca | va_bri
  final String? qrString;
  final String? vaNumber;
  final String? bankName;
  final String? paymentUrl;
  final DateTime? payBefore; // batas bayar (yang lebih dulu: tagihan Komerce / tahan kursi)
  final DateTime? ticketIssuedAt;

  bool get isPending => status == 'pending';
  bool get isPaid => status == 'paid';

  factory PaymentOrder.fromJson(Map<String, dynamic> j) {
    final p = Map<String, dynamic>.from(j['payment'] as Map? ?? const {});
    DateTime? date(Object? v) => v == null ? null : DateTime.tryParse(v as String)?.toLocal();
    final payExpiry = date(p['expiredAt']);
    final holdExpiry = date(j['expiresAt']);
    final deadlines = [payExpiry, holdExpiry].whereType<DateTime>().toList()..sort();
    return PaymentOrder(
      id: j['id'] as String,
      code: j['code'] as String,
      status: j['status'] as String,
      statusLabel: j['statusLabel'] as String? ?? '',
      total: (j['total'] as num).toInt(),
      method: p['method'] as String? ?? '',
      qrString: p['qrString'] as String?,
      vaNumber: p['vaNumber'] as String?,
      bankName: p['bankName'] as String?,
      paymentUrl: p['paymentUrl'] as String?,
      payBefore: deadlines.isEmpty ? null : deadlines.first,
      ticketIssuedAt: date(j['ticketIssuedAt']),
    );
  }
}
