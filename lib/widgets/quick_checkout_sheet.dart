import 'dart:math';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/trip.dart';
import '../providers/auth_provider.dart';
import '../providers/checkout_provider.dart';
import '../services/trip_repository.dart';
import '../theme/app_colors.dart';
import '../theme/app_theme.dart';
import '../utils/formatters.dart';
import 'date_chips.dart';
import 'option_chip.dart';
import 'pax_stepper.dart';

/// Panel checkout cepat ala "keranjang kuning":
/// pilih tanggal → jam → varian kursi → jumlah → Beli sekarang.
/// Dipakai dari kartu Produk unggulan, hasil pencarian, dan link iklan (deep link).
class QuickCheckoutSheet extends StatefulWidget {
  const QuickCheckoutSheet({
    super.key,
    required this.poId,
    required this.poName,
    required this.from,
    required this.to,
    required this.image,
    this.preferredClass,
    this.initialDay = 0,
    this.initialTripId,
  });

  final String poId;
  final String poName;
  final String from;
  final String to;
  final String image;
  final String? preferredClass;
  final int initialDay;
  final String? initialTripId;

  static Future<void> show(
    BuildContext context, {
    required String poId,
    required String poName,
    required String from,
    required String to,
    required String image,
    String? preferredClass,
    int initialDay = 0,
    String? initialTripId,
  }) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (_) => QuickCheckoutSheet(
        poId: poId,
        poName: poName,
        from: from,
        to: to,
        image: image,
        preferredClass: preferredClass,
        initialDay: initialDay,
        initialTripId: initialTripId,
      ),
    );
  }

  @override
  State<QuickCheckoutSheet> createState() => _QuickCheckoutSheetState();
}

class _QuickCheckoutSheetState extends State<QuickCheckoutSheet> {
  late int _day = widget.initialDay;
  List<Trip> _trips = [];
  bool _loading = true;
  bool _firstLoad = true;
  int _tripIndex = 0;
  String? _tierKey;
  int _pax = 1;
  List<String>? _manualSeats; // null = kursi otomatis

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final keepClass = _trips.isNotEmpty ? _trips[_tripIndex].busClass : widget.preferredClass;
    if (!_loading) setState(() => _loading = true); // saat initState _loading sudah true
    final list = await context.read<TripRepository>().tripsOfPo(widget.poId, widget.from, widget.to, _day);
    if (!mounted) return;

    var idx = -1;
    if (_firstLoad && widget.initialTripId != null) idx = list.indexWhere((t) => t.id == widget.initialTripId);
    if (idx < 0 && keepClass != null) {
      idx = list.indexWhere((t) => t.busClass == keepClass);
      if (idx < 0) idx = list.indexWhere((t) => keepClass.contains(t.busClass));
    }
    setState(() {
      _trips = list;
      _tripIndex = max(0, idx);
      _tierKey = null;
      _pax = 1;
      _manualSeats = null;
      _loading = false;
      _firstLoad = false;
    });
  }

  Trip? get _trip => _trips.isEmpty ? null : _trips[_tripIndex.clamp(0, _trips.length - 1)];

  SeatTier? get _tier {
    final t = _trip;
    if (t == null) return null;
    for (final x in t.tiers) {
      if (x.key == _tierKey && !x.soldOut) return x;
    }
    return t.cheapestAvailable ?? t.tiers.first;
  }

  int get _maxPax => max(1, min(4, _tier?.left ?? 1));
  int get _effPax => min(_pax, _maxPax);
  List<String> get _seats => _manualSeats ?? (_tier?.freeSeats.take(_effPax).toList() ?? []);
  bool get _canBuy => _trip != null && _tier != null && _effPax > 0 && _seats.length == _effPax;

  void _resetSelection() {
    _pax = 1;
    _manualSeats = null;
  }

  Future<void> _buy() async {
    final auth = context.read<AuthProvider>();
    final checkout = context.read<CheckoutProvider>();
    final nav = Navigator.of(context);
    if (!auth.isLoggedIn) {
      final ok = await nav.pushNamed('/login');
      if (ok != true || !mounted) return;
    }
    checkout.start(trip: _trip!, tier: _tier!, seats: _seats, firstName: auth.name);
    nav.pop();
    nav.pushNamed('/passenger');
  }

  @override
  Widget build(BuildContext context) {
    final t = _trip;
    final tier = _tier;
    final isPromo = t != null && tier != null && t.oldPrice != null && tier.key == t.tiers.first.key;

    return Container(
      constraints: BoxConstraints(maxHeight: MediaQuery.sizeOf(context).height * 0.9),
      decoration: const BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        _header(t, tier, isPromo),
        const Divider(height: 1, color: Color(0xFFEDF2F2)),
        Flexible(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 8),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              _label('Tanggal berangkat'),
              DateChips(
                selected: _day,
                compact: true,
                onSelect: (i) {
                  _day = i;
                  _load();
                },
              ),
              const SizedBox(height: 16),
              if (_loading)
                const Center(child: Padding(padding: EdgeInsets.all(24), child: CircularProgressIndicator()))
              else if (t == null)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(color: AppColors.bg, borderRadius: BorderRadius.circular(12)),
                  child: Text('Belum ada jadwal PO ${widget.poName} di tanggal ini. Coba tanggal lain.',
                      textAlign: TextAlign.center, style: const TextStyle(fontSize: 13, color: AppColors.muted)),
                )
              else ...[
                _label('Jam berangkat'),
                Wrap(spacing: 8, runSpacing: 8, children: [
                  for (var i = 0; i < _trips.length; i++)
                    OptionChip(
                      title: _trips[i].depart,
                      subtitle: '${_trips[i].busClass} · sisa ${_trips[i].seatsLeft}',
                      selected: i == _tripIndex,
                      onTap: () => setState(() {
                        _tripIndex = i;
                        _tierKey = null;
                        _resetSelection();
                      }),
                    ),
                ]),
                const SizedBox(height: 16),
                _label('Varian kursi'),
                Wrap(spacing: 8, runSpacing: 8, children: [
                  for (final x in t.tiers)
                    OptionChip(
                      title: x.name,
                      subtitle: '${rupiah(x.price)} · ${x.soldOut ? 'habis' : 'sisa ${x.left}'}',
                      selected: x.key == tier!.key,
                      disabled: x.soldOut,
                      onTap: () => setState(() {
                        _tierKey = x.key;
                        _resetSelection();
                      }),
                    ),
                ]),
                const SizedBox(height: 16),
                Row(children: [
                  Expanded(
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      const Text('Jumlah penumpang', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800)),
                      Text('Maks. $_maxPax untuk varian ini', style: const TextStyle(fontSize: 11, color: AppColors.muted)),
                    ]),
                  ),
                  StepButton(
                    symbol: '−',
                    semanticLabel: 'Kurangi penumpang',
                    onTap: () => setState(() {
                      if (_effPax > 1) _pax = _effPax - 1;
                      _manualSeats = null;
                    }),
                  ),
                  SizedBox(width: 36, child: Center(child: Text('$_effPax', style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w800)))),
                  StepButton(
                    symbol: '+',
                    filled: true,
                    semanticLabel: 'Tambah penumpang',
                    onTap: () => setState(() {
                      if (_effPax < _maxPax) _pax = _effPax + 1;
                      _manualSeats = null;
                    }),
                  ),
                ]),
                const SizedBox(height: 12),
                _summary(t),
              ],
            ]),
          ),
        ),
        _bottomBar(tier),
      ]),
    );
  }

  Widget _header(Trip? t, SeatTier? tier, bool isPromo) {
    final price = tier?.price ?? 0;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 8, 12),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(14),
          child: Image.asset(widget.image, width: 92, height: 92, fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(width: 92, height: 92, color: const Color(0xFFDCE4E4))),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: SizedBox(
            height: 92,
            child: Column(mainAxisAlignment: MainAxisAlignment.end, crossAxisAlignment: CrossAxisAlignment.start, children: [
              if (isPromo)
                Text(rupiah(t!.oldPrice!),
                    style: const TextStyle(fontSize: 12, color: AppColors.faint, decoration: TextDecoration.lineThrough)),
              Text(t == null ? '—' : rupiah(price),
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: isPromo ? AppColors.promoRed : AppColors.teal)),
              if (tier != null) Text('Sisa ${tier.left} kursi · ${tier.name}', style: const TextStyle(fontSize: 12, color: AppColors.muted)),
              Text('PO ${widget.poName} · ${widget.from} → ${widget.to}',
                  maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
            ]),
          ),
        ),
        IconButton(
          tooltip: 'Tutup',
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.close_rounded, color: AppColors.muted),
        ),
      ]),
    );
  }

  Widget _summary(Trip t) {
    final tier = _tier!;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: AppColors.bg, borderRadius: BorderRadius.circular(12)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text.rich(TextSpan(style: const TextStyle(fontSize: 12, color: Color(0xFF3F5154)), children: [
          const TextSpan(text: 'Naik '),
          TextSpan(text: t.boardPoint, style: const TextStyle(fontWeight: FontWeight.w700)),
          const TextSpan(text: ' · turun '),
          TextSpan(text: t.dropPoint, style: const TextStyle(fontWeight: FontWeight.w700)),
        ])),
        const SizedBox(height: 4),
        Text('${t.depart} → ${t.arrive} · ${t.duration}', style: const TextStyle(fontSize: 12, color: Color(0xFF3F5154))),
        const SizedBox(height: 4),
        Row(children: [
          Text(_manualSeats == null ? 'Kursi otomatis: ' : 'Kursi pilihan: ', style: const TextStyle(fontSize: 12)),
          Expanded(
            child: Text(_seats.isEmpty ? '—' : _seats.join(', '),
                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: AppColors.teal)),
          ),
          TextButton(
            onPressed: () => setState(() => _manualSeats = _manualSeats == null ? <String>[] : null),
            child: Text(_manualSeats == null ? 'Pilih sendiri' : 'Otomatis'),
          ),
        ]),
        if (_manualSeats != null) ...[
          Text('Pilih $_effPax kursi (${_manualSeats!.length}/$_effPax):', style: const TextStyle(fontSize: 11, color: AppColors.muted)),
          const SizedBox(height: 6),
          Wrap(spacing: 6, runSpacing: 6, children: [
            for (final code in tier.freeSeats)
              ChoiceChip(
                label: Text(code),
                selected: _manualSeats!.contains(code),
                selectedColor: AppColors.tealSoft,
                onSelected: (on) => setState(() {
                  final list = [..._manualSeats!];
                  if (on && list.length < _effPax) list.add(code);
                  if (!on) list.remove(code);
                  _manualSeats = list;
                }),
              ),
          ]),
        ],
      ]),
    );
  }

  Widget _bottomBar(SeatTier? tier) {
    final total = (tier?.price ?? 0) * _effPax;
    return Container(
      padding: EdgeInsets.fromLTRB(16, 10, 16, 16 + MediaQuery.paddingOf(context).bottom),
      decoration: const BoxDecoration(border: Border(top: BorderSide(color: Color(0xFFEDF2F2)))),
      child: Row(children: [
        Expanded(
          child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('Total ($_effPax kursi)', style: const TextStyle(fontSize: 11, color: AppColors.muted)),
            Text(_trip == null ? '—' : rupiah(total), style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
          ]),
        ),
        ElevatedButton.icon(
          style: goldButtonStyle(height: 48, expand: false),
          onPressed: _canBuy ? _buy : null,
          icon: const Icon(Icons.shopping_cart_outlined, size: 20),
          label: const Text('Beli sekarang'),
        ),
      ]),
    );
  }

  Widget _label(String text) => Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Text(text, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800)),
      );
}
