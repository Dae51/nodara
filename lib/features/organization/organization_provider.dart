import 'dart:async';

import 'package:flutter/foundation.dart';

import 'package:nodara/data/models/opportunity.dart';
import 'package:nodara/data/repositories/opportunity_repository.dart';

/// Maneja el estado reactivo del panel de organización y las acciones de
/// publicación/edición de convocatorias.
class OrganizationProvider extends ChangeNotifier {
  OrganizationProvider({
    required OpportunityRepository opportunities,
    required this.orgId,
  }) : _opportunitiesRepo = opportunities {
    _initStream();
  }

  final OpportunityRepository _opportunitiesRepo;
  final String orgId;

  StreamSubscription<List<Opportunity>>? _subscription;
  List<Opportunity> _opportunities = const [];
  bool _isLoading = true;
  String? _error;
  bool _isSaving = false;

  List<Opportunity> get opportunities => _opportunities;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isSaving => _isSaving;

  void _initStream() {
    _isLoading = true;
    _error = null;
    notifyListeners();

    _subscription = _opportunitiesRepo
        .watchByOrg(orgId)
        .listen(
          (data) {
            _opportunities = data;
            _isLoading = false;
            _error = null;
            notifyListeners();
          },
          onError: (Object _) {
            _isLoading = false;
            _error = 'No pudimos cargar tus convocatorias.';
            notifyListeners();
          },
        );
  }

  Future<bool> guardarConvocatoria(
    Opportunity opportunity, {
    required bool esEdicion,
  }) async {
    _isSaving = true;
    _error = null;
    notifyListeners();

    try {
      if (esEdicion) {
        await _opportunitiesRepo.actualizar(opportunity);
      } else {
        await _opportunitiesRepo.publicar(opportunity);
      }
      _isSaving = false;
      notifyListeners();
      return true;
    } catch (_) {
      _isSaving = false;
      _error = 'Ocurrió un error al guardar la convocatoria.';
      notifyListeners();
      return false;
    }
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}
