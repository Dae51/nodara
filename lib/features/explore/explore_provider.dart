import 'dart:async';

import 'package:flutter/foundation.dart';

import 'package:nodara/data/models/opportunity.dart';
import 'package:nodara/data/repositories/opportunity_repository.dart';

/// Feed de oportunidades + búsqueda y filtros.
class ExploreProvider extends ChangeNotifier {
  ExploreProvider(this._repository) {
    _subscribe();
  }

  final OpportunityRepository _repository;
  StreamSubscription<List<Opportunity>>? _subscription;

  List<Opportunity> _all = const [];
  bool _isLoading = true;
  String? _error;
  String _searchQuery = '';
  Causa? _selectedCausa;

  bool get isLoading => _isLoading;
  String? get error => _error;
  String get searchQuery => _searchQuery;

  /// `null` = "Todos".
  Causa? get selectedCausa => _selectedCausa;

  bool get hasFilters => _searchQuery.isNotEmpty || _selectedCausa != null;

  /// Oportunidades vigentes después de aplicar búsqueda y causa.
  List<Opportunity> get filtered {
    final query = _searchQuery.trim().toLowerCase();
    return _all.where((o) {
      final matchesCausa = _selectedCausa == null || o.causa == _selectedCausa;
      final matchesQuery = query.isEmpty ||
          o.titulo.toLowerCase().contains(query) ||
          o.tituloTarjeta.toLowerCase().contains(query) ||
          o.orgNombre.toLowerCase().contains(query);
      return matchesCausa && matchesQuery;
    }).toList();
  }

  Opportunity? byId(String id) {
    for (final opportunity in _all) {
      if (opportunity.id == id) return opportunity;
    }
    return null;
  }

  void setSearchQuery(String value) {
    if (_searchQuery == value) return;
    _searchQuery = value;
    notifyListeners();
  }

  void setCausa(Causa? causa) {
    if (_selectedCausa == causa) return;
    _selectedCausa = causa;
    notifyListeners();
  }

  void clearFilters() {
    _searchQuery = '';
    _selectedCausa = null;
    notifyListeners();
  }

  void retry() => _subscribe();

  void _subscribe() {
    _subscription?.cancel();
    _isLoading = true;
    _error = null;
    _subscription = _repository.watchVigentes().listen(
      (items) {
        _all = items;
        _isLoading = false;
        _error = null;
        notifyListeners();
      },
      onError: (Object _) {
        _isLoading = false;
        _error = 'No pudimos cargar las oportunidades. Revisa tu conexión.';
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
