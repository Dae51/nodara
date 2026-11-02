import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:nodara/data/models/app_notification.dart';
import 'package:nodara/data/models/app_user.dart';
import 'package:nodara/data/models/application.dart';
import 'package:nodara/data/models/opportunity.dart';
import 'package:nodara/data/repositories/application_repository.dart';
import 'package:nodara/data/repositories/auth_repository.dart';
import 'package:nodara/data/repositories/notification_repository.dart';
import 'package:nodara/data/repositories/opportunity_repository.dart';

/// Responde únicamente a postulaciones de la organización autenticada.
class ApplicantsProvider extends ChangeNotifier {
  ApplicantsProvider({
    required this.opportunityId,
    required this._applications,
    required this._opportunities,
    required this._notifications,
    required AuthRepository auth,
  }) {
    _authSubscription = auth.authStateChanges().listen(_onUser);
  }

  final String opportunityId;
  final ApplicationRepository _applications;
  final OpportunityRepository _opportunities;
  final NotificationRepository _notifications;
  StreamSubscription<AppUser?>? _authSubscription;
  StreamSubscription<List<Application>>? _applicationSubscription;
  StreamSubscription<List<Opportunity>>? _opportunitySubscription;
  AppUser? _user;
  Opportunity? _opportunity;
  List<Application> _items = const [];
  final Map<String, AppNotification> _pendingNotices = {};
  bool _loadingApplications = true;
  bool _loadingOpportunity = true;
  bool _busy = false;
  bool _disposed = false;
  int _generation = 0;
  String? _error;

  List<Application> get items => List.unmodifiable(_items);
  Opportunity? get opportunity => _opportunity;
  bool get isLoading => _loadingApplications || _loadingOpportunity;
  bool get isBusy => _busy;
  String? get error => _error;
  bool hasPendingNotice(String id) => _pendingNotices.containsKey(id);
  bool canRespond(Application application) => const {
    EstadoPostulacion.pendiente,
    EstadoPostulacion.enRevision,
    EstadoPostulacion.entrevista,
    EstadoPostulacion.listaEspera,
  }.contains(application.estado);

  void _emit() {
    if (!_disposed) notifyListeners();
  }

  void _onUser(AppUser? user) {
    final previousUserId = _user?.uid;
    final generation = ++_generation;
    _applicationSubscription?.cancel();
    _opportunitySubscription?.cancel();
    _user = user;
    _items = const [];
    _opportunity = null;
    if (previousUserId != user?.uid) _pendingNotices.clear();
    _error = null;
    _loadingApplications = user?.esOrganizacion ?? false;
    _loadingOpportunity = _loadingApplications;
    if (user == null || user.esOrganizacion == false) {
      _error = 'Inicia sesión como organización para ver postulantes.';
      _emit();
      return;
    }
    _emit();
    _applicationSubscription = _applications
        .watchForOrg(user.uid)
        .listen(
          (items) {
            if (generation != _generation) return;
            _items = items
                .where((item) => item.opportunityId == opportunityId)
                .toList();
            _loadingApplications = false;
            _emit();
          },
          onError: (Object _) {
            if (generation == _generation) {
              _loadingApplications = false;
              _error = 'No pudimos cargar los postulantes. Reintenta.';
              _emit();
            }
          },
        );
    _opportunitySubscription = _opportunities
        .watchByOrg(user.uid)
        .listen(
          (items) {
            if (generation != _generation) return;
            _opportunity = items
                .where((item) => item.id == opportunityId)
                .firstOrNull;
            _loadingOpportunity = false;
            _emit();
          },
          onError: (Object _) {
            if (generation == _generation) {
              _loadingOpportunity = false;
              _error = 'No pudimos consultar los cupos. Reintenta.';
              _emit();
            }
          },
        );
  }

  void retry() => _onUser(_user);

  Future<bool> responder(
    Application application, {
    required bool aceptar,
    String? motivo,
  }) async {
    if (_busy || isLoading) return false;
    final current = _items
        .where((item) => item.id == application.id)
        .firstOrNull;
    final opportunity = _opportunity;
    if (current == null ||
        current.orgId != _user?.uid ||
        opportunity == null ||
        canRespond(current) == false) {
      return false;
    }
    final reason = motivo?.trim();
    if (aceptar == false && (reason == null || reason.isEmpty)) {
      _error = 'Escribe el motivo del rechazo.';
      _emit();
      return false;
    }
    if (aceptar && opportunity.hayCupos == false) {
      _error = 'Esta convocatoria ya no tiene cupos disponibles.';
      _emit();
      return false;
    }
    _busy = true;
    _error = null;
    _emit();
    final generation = _generation;
    var reserved = false;
    var changed = false;
    try {
      if (aceptar) {
        await _opportunities.ocuparCupo(opportunityId);
        reserved = true;
        // El contrato exige pasar por revisión antes de aceptar.
        if (current.estado == EstadoPostulacion.pendiente) {
          await _applications.cambiarEstado(
            applicationId: current.id,
            estado: EstadoPostulacion.enRevision,
          );
        }
      }
      final state = aceptar
          ? EstadoPostulacion.aceptado
          : EstadoPostulacion.rechazado;
      await _applications.cambiarEstado(
        applicationId: current.id,
        estado: state,
        motivo: reason,
      );
      changed = true;
      if (generation != _generation) return false;
      _items = _items
          .map(
            (item) => item.id == current.id
                ? item.copyWith(estado: state, motivo: reason)
                : item,
          )
          .toList();
      final notice = AppNotification(
        id: '${current.id}_${state.name}',
        titulo: aceptar
            ? '¡Postulación aceptada!'
            : 'Respuesta a tu postulación',
        cuerpo: aceptar
            ? '${current.orgNombre} aceptó tu postulación a ${current.oportunidadTitulo}.'
            : '${current.orgNombre} no aceptó tu postulación a ${current.oportunidadTitulo}. Motivo: $reason',
        applicationId: current.id,
        creadaEn: DateTime.now(),
      );
      _pendingNotices[current.id] = notice;
      await _notifications.enviar(current.userId, notice);
      if (generation == _generation) _pendingNotices.remove(current.id);
      return true;
    } catch (_) {
      if (reserved && changed == false) {
        try {
          await _opportunities.liberarCupo(opportunityId);
        } catch (_) {
          if (generation == _generation) _error = 'No se pudo devolver el cupo. Pide a la organización revisar los cupos antes de reintentar.';
        }
      }
      if (generation == _generation) {
        _error ??= changed
            ? 'La respuesta se guardó, pero falta enviar el aviso. Usa Reenviar aviso.'
            : 'No pudimos guardar la respuesta. Revisa los datos y reintenta.';
      }
      return false;
    } finally {
      _busy = false;
      _emit();
    }
  }

  Future<void> retryNotice(Application application) async {
    final notice = _pendingNotices[application.id];
    if (_busy || notice == null || application.orgId != _user?.uid) return;
    final generation = _generation;
    _busy = true;
    _error = null;
    _emit();
    try {
      await _notifications.enviar(application.userId, notice);
      if (generation == _generation) _pendingNotices.remove(application.id);
    } catch (_) {
      if (generation == _generation) {
        _error = 'No se pudo enviar el aviso. Puedes reintentar.';
      }
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
    _applicationSubscription?.cancel();
    _opportunitySubscription?.cancel();
    super.dispose();
  }
}
