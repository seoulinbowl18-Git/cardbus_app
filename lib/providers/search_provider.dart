import 'package:flutter/foundation.dart';

import '../models/ticket_search_model.dart';
import '../models/trip.dart';
import '../services/trip_repository.dart';

enum TripSort { cheapest, earliest, mostSeats }

class SearchProvider extends ChangeNotifier {
  SearchProvider(this._repo);

  final TripRepository _repo;

  TicketSearchModel _query = const TicketSearchModel();
  TicketSearchModel get query => _query;

  List<Trip> _results = [];
  List<Trip> get results => _sorted(_results);

  bool loading = false;
  String? error;
  TripSort sort = TripSort.cheapest;

  void setFrom(String city, {String? point}) {
    _query = _query.copyWith(fromCity: city, fromPoint: point, clearFromPoint: point == null);
    notifyListeners();
  }

  void setTo(String city, {String? point}) {
    _query = _query.copyWith(toCity: city, toPoint: point, clearToPoint: point == null);
    notifyListeners();
  }

  void swap() {
    _query = _query.swapped();
    notifyListeners();
  }

  void setDay(int dayIndex) {
    _query = _query.copyWith(dayIndex: dayIndex);
    notifyListeners();
  }

  void incPax() {
    if (_query.pax < TicketSearchModel.maxPax) {
      _query = _query.copyWith(pax: _query.pax + 1);
      notifyListeners();
    }
  }

  void decPax() {
    if (_query.pax > 1) {
      _query = _query.copyWith(pax: _query.pax - 1);
      notifyListeners();
    }
  }

  /// Dipakai banner promo: langsung set rute lalu cari.
  Future<void> searchRoute(String from, String to) async {
    _query = _query.copyWith(fromCity: from, toCity: to, clearFromPoint: true, clearToPoint: true);
    await search();
  }

  Future<void> search() async {
    if (_query.isSameCity) return;
    loading = true;
    error = null;
    notifyListeners();
    try {
      _results = await _repo.searchTrips(_query);
    } catch (e) {
      error = 'Gagal memuat jadwal. Coba lagi.';
      _results = [];
    } finally {
      loading = false;
      notifyListeners();
    }
  }

  void setSort(TripSort value) {
    sort = value;
    notifyListeners();
  }

  List<Trip> _sorted(List<Trip> list) {
    final copy = [...list];
    switch (sort) {
      case TripSort.cheapest:
        copy.sort((a, b) => a.minPrice.compareTo(b.minPrice));
      case TripSort.earliest:
        copy.sort((a, b) => a.depart.compareTo(b.depart));
      case TripSort.mostSeats:
        copy.sort((a, b) => b.seatsLeft.compareTo(a.seatsLeft));
    }
    return copy;
  }
}
