import 'dart:async';

import 'package:flutter/foundation.dart';

import 'package:nodara/data/models/donation_point.dart';
import 'package:nodara/data/models/opportunity.dart';
import 'package:nodara/data/repositories/donation_repository.dart';

/// Puntos de donación activos + filtro por causa (F2).
class DonationsProvider extends ChangeNotifier {
  DonationsProvider(this._repository) {
    _subscribe();
  }

  final DonationRepository _repository;
  StreamSubscription<List<DonationPoint>>? _subscription;

  List<DonationPoint> _all = const [];
  bool _isLoading = true;
  String? _error;
  Causa? _selectedCausa;

  bool get isLoading => _isLoading;
  String? get error => _error;
  Causa? get selectedCausa => _selectedCausa;

  List<DonationPoint> get filtered => _selectedCausa == null
      ? _all
      : _all.where((d) => d.causa == _selectedCausa).toList();

  void setCausa(Causa? causa) {
    if (_selectedCausa == causa) return;
    _selectedCausa = causa;
    notifyListeners();
  }

  void retry() => _subscribe();

  void _subscribe() {
    _subscription?.cancel();
    _isLoading = true;
    _error = null;
    _subscription = _repository.watchActivos().listen(
      (items) {
        _all = items;
        _isLoading = false;
        notifyListeners();
      },
      onError: (Object _) {
        _isLoading = false;
        _error = 'No pudimos cargar los puntos de donación.';
        notifyListeners();
      },
    );
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}
