import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:nodara/data/models/app_user.dart';
import 'package:nodara/data/models/application.dart';
import 'package:nodara/data/repositories/application_repository.dart';
import 'package:nodara/data/repositories/auth_repository.dart';

/// Relee la postulación antes de acreditar; no confía en la tarjeta abierta.
class AccreditationProvider extends ChangeNotifier {
  AccreditationProvider({
    required this.applicationId,
    required this._applications,
    required AuthRepository auth,
  }) {
    _authSubscription = auth.authStateChanges().listen(
      _onUser,
      onError: (Object _) => _fail('No pudimos verificar la sesión.'),
    );
  }

  final String applicationId;
  final ApplicationRepository _applications;
  StreamSubscription<AppUser?>? _authSubscription;
  StreamSubscription<List<Application>>? _subscription;
  AppUser? _user;
  Application? _application;
  bool _loading = true;
  bool _busy = false;
  bool _completed = false;
  bool _disposed = false;
  int _generation = 0;
  String? _error;

  Application? get application => _application;
  bool get isLoading => _loading;
  bool get isBusy => _busy;
  String? get error => _error;
  bool get canAccredit =>
      _loading == false &&
      _completed == false &&
      _user?.esOrganizacion == true &&
      _application?.orgId == _user?.uid &&
      const {
        EstadoPostulacion.aceptado,
        EstadoPostulacion.confirmado,
        EstadoPostulacion.enCurso,
      }.contains(_application?.estado);

  void _emit() {
    if (_disposed == false) notifyListeners();
  }

  void _fail(String message) {
    _loading = false;
    _application = null;
    _error = message;
    _emit();
  }

  void _onUser(AppUser? user) {
    final generation = ++_generation;
    _subscription?.cancel();
    _user = user;
    _application = null;
    _completed = false;
    _error = null;
    _loading = user?.esOrganizacion == true;
    if (user == null || user.esOrganizacion == false) {
      _fail('Solo la organización responsable puede acreditar horas.');
      return;
    }
    _emit();
    _subscription = _applications
        .watchForOrg(user.uid)
        .listen(
          (items) {
            if (generation != _generation) return;
            _application = items
                .where((item) => item.id == applicationId)
                .firstOrNull;
            _loading = false;
            _error = null;
            _emit();
          },
          onError: (Object _) {
            if (generation == _generation) {
              _fail('No pudimos consultar la postulación. Reintenta.');
            }
          },
        );
  }

  void retry() => _onUser(_user);

  Future<bool> acreditar(int horas) async {
    if (_busy || canAccredit == false || horas <= 0) return false;
    final current = _application;
    if (current == null) return false;
    final generation = _generation;
    _busy = true;
    _error = null;
    _emit();
    try {
      // El contrato exige pasar por enCurso antes de completado.
      if (current.estado != EstadoPostulacion.enCurso) {
        await _applications.cambiarEstado(
          applicationId: current.id,
          estado: EstadoPostulacion.enCurso,
        );
        if (_disposed || generation != _generation) return false;
      }
      await _applications.cambiarEstado(
        applicationId: current.id,
        estado: EstadoPostulacion.completado,
        horasAcreditadas: horas,
      );
      if (_disposed || generation != _generation) return false;
      _completed = true;
      return true;
    } catch (_) {
      if (generation == _generation) {
        _error = 'No se acreditaron las horas. Revisa la conexión y reintenta.';
      }
      return false;
    } finally {
      _busy = false;
      _emit();
    }
  }

  @override
  void dispose() {
    _disposed = true;
    _generation++;
    _authSubscription?.cancel();
    _subscription?.cancel();
    super.dispose();
  }
}
