import 'dart:async';

import 'package:flutter/foundation.dart';

import 'package:nodara/data/models/app_user.dart';
import 'package:nodara/data/models/application.dart';
import 'package:nodara/data/models/opportunity.dart';
import 'package:nodara/data/repositories/application_repository.dart';
import 'package:nodara/data/repositories/auth_repository.dart';

/// Postulaciones del voluntario y todo lo que se deriva de ellas
/// (horas, progreso, nivel). Nada de esto se guarda: son getters.
class ApplicationsProvider extends ChangeNotifier {
  ApplicationsProvider(this._repository, AuthRepository authRepository) {
    _authSubscription =
        authRepository.authStateChanges().listen(_onUserChanged);
  }

  final ApplicationRepository _repository;
  StreamSubscription<AppUser?>? _authSubscription;
  StreamSubscription<List<Application>>? _subscription;

  AppUser? _user;
  List<Application> _applications = const [];
  bool _isLoading = true;
  String? _error;

  bool get isLoading => _isLoading;
  String? get error => _error;
  List<Application> get applications => _applications;

  List<Application> get activas =>
      _applications.where((a) => a.estado.esActiva).toList();

  List<Application> get completadas => _applications
      .where((a) => a.estado == EstadoPostulacion.completado)
      .toList();

  /// Rechazadas o retiradas.
  List<Application> get cerradas =>
      _applications.where((a) => a.estado.esCerrada).toList();

  // ---- Valores derivados ----

  int get horasCompletadas =>
      _applications.fold(0, (total, a) => total + a.horasQueCuentan);

  int get horasRequeridas => _user?.horasRequeridas ?? 0;

  int get horasFaltantes {
    final faltan = horasRequeridas - horasCompletadas;
    return faltan < 0 ? 0 : faltan;
  }

  double get progreso => horasRequeridas == 0
      ? 0
      : (horasCompletadas / horasRequeridas).clamp(0.0, 1.0);

  int get progresoPorcentaje => (progreso * 100).round();

  /// Nivel de impacto: sube uno cada 15 horas acreditadas.
  int get nivel => 1 + horasCompletadas ~/ 15;

  /// Hay una postulación vigente (no retirada) a esa oportunidad.
  bool hasApplied(String opportunityId) => _applications.any(
        (a) =>
            a.opportunityId == opportunityId &&
            a.estado != EstadoPostulacion.retirado,
      );

  // ---- Acciones ----

  Future<bool> postular(Opportunity opportunity) async {
    final user = _user;
    if (user == null || hasApplied(opportunity.id)) return false;
    try {
      await _repository.postular(opportunity: opportunity, user: user);
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<bool> retirar(Application application) async {
    try {
      await _repository.retirar(application);
      return true;
    } catch (_) {
      return false;
    }
  }

  void retry() => _subscribeFor(_user);

  void _onUserChanged(AppUser? user) {
    final sameUser = user?.uid == _user?.uid;
    _user = user;
    if (sameUser && _subscription != null) {
      notifyListeners(); // solo cambió el perfil (ej. horasRequeridas)
      return;
    }
    _subscribeFor(user);
  }

  void _subscribeFor(AppUser? user) {
    _subscription?.cancel();
    _subscription = null;
    _applications = const [];
    _error = null;
    if (user == null) {
      _isLoading = false;
      notifyListeners();
      return;
    }
    _isLoading = true;
    notifyListeners();
    _subscription = _repository.watchMine(user.uid).listen(
      (items) {
        _applications = items;
        _isLoading = false;
        _error = null;
        notifyListeners();
      },
      onError: (Object _) {
        _isLoading = false;
        _error = 'No pudimos cargar tus postulaciones.';
        notifyListeners();
      },
    );
  }

  @override
  void dispose() {
    _authSubscription?.cancel();
    _subscription?.cancel();
    super.dispose();
  }
}
