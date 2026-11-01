import 'dart:async';

import 'package:flutter/foundation.dart';

import 'package:nodara/data/models/opportunity.dart';
import 'package:nodara/data/repositories/opportunity_repository.dart';

/// Franjas de horas acreditables para la hoja de filtros de Explorar.
enum FranjaHoras {
  hasta10('Hasta 10 hrs'),
  entre11y20('11 a 20 hrs'),
  masDe20('Más de 20 hrs');

  const FranjaHoras(this.label);

  final String label;

  bool cumple(int horas) => switch (this) {
    FranjaHoras.hasta10 => horas <= 10,
    FranjaHoras.entre11y20 => horas >= 11 && horas <= 20,
    FranjaHoras.masDe20 => horas > 20,
  };
}

/// Departamentos que usa el seeder. "Todos" se representa con `null`.
const kDepartamentos = [
  'San Salvador',
  'La Libertad',
  'Santa Ana',
  'San Miguel',
  'Sonsonate',
];

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
  Set<Formato> _selectedFormatos = const {};
  String? _selectedDepartamento;
  FranjaHoras? _selectedHoras;

  bool get isLoading => _isLoading;
  String? get error => _error;
  String get searchQuery => _searchQuery;

  /// `null` = "Todos".
  Causa? get selectedCausa => _selectedCausa;

  Set<Formato> get selectedFormatos => _selectedFormatos;

  /// `null` = "Todos los departamentos".
  String? get selectedDepartamento => _selectedDepartamento;

  /// `null` = "Todas las franjas de horas".
  FranjaHoras? get selectedHoras => _selectedHoras;

  bool get hasFilters =>
      _searchQuery.isNotEmpty ||
      _selectedCausa != null ||
      _selectedFormatos.isNotEmpty ||
      _selectedDepartamento != null ||
      _selectedHoras != null;

  /// Oportunidades vigentes después de aplicar búsqueda, causa, formato,
  /// departamento y franja de horas.
  List<Opportunity> get filtered {
    final query = _searchQuery.trim().toLowerCase();
    return _all.where((o) {
      final matchesCausa = _selectedCausa == null || o.causa == _selectedCausa;
      final matchesQuery =
          query.isEmpty ||
          o.titulo.toLowerCase().contains(query) ||
          o.tituloTarjeta.toLowerCase().contains(query) ||
          o.orgNombre.toLowerCase().contains(query);
      final matchesFormato =
          _selectedFormatos.isEmpty || _selectedFormatos.contains(o.formato);
      final matchesDepartamento =
          _selectedDepartamento == null ||
          o.departamento == _selectedDepartamento;
      final matchesHoras =
          _selectedHoras == null || _selectedHoras!.cumple(o.horasEstimadas);
      return matchesCausa &&
          matchesQuery &&
          matchesFormato &&
          matchesDepartamento &&
          matchesHoras;
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

  void toggleFormato(Formato formato) {
    final next = Set<Formato>.of(_selectedFormatos);
    if (next.contains(formato)) {
      next.remove(formato);
    } else {
      next.add(formato);
    }
    _selectedFormatos = next;
    notifyListeners();
  }

  void setDepartamento(String? departamento) {
    if (_selectedDepartamento == departamento) return;
    _selectedDepartamento = departamento;
    notifyListeners();
  }

  void setHoras(FranjaHoras? horas) {
    if (_selectedHoras == horas) return;
    _selectedHoras = horas;
    notifyListeners();
  }

  void clearFilters() {
    _searchQuery = '';
    _selectedCausa = null;
    _selectedFormatos = const {};
    _selectedDepartamento = null;
    _selectedHoras = null;
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
