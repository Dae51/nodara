import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:nodara/data/models/app_user.dart';
import 'package:nodara/data/models/application.dart';
import 'package:nodara/data/models/certificate.dart';
import 'package:nodara/data/models/opportunity.dart';
import 'package:nodara/data/repositories/auth_repository.dart';
import 'package:nodara/data/repositories/certificate_repository.dart';
import 'package:nodara/features/profile/hours_report_pdf.dart';

class HoursReport {
  const HoursReport({
    required this.certificate,
    required this.bytes,
    required this.elapsed,
  });
  final Certificate certificate;
  final Uint8List bytes;
  final Duration elapsed;
}

class ProfileProvider extends ChangeNotifier {
  ProfileProvider({
    required this._auth,
    required this._certificates,
    HoursReportPdf? pdf,
  }) : _pdf = pdf ?? HoursReportPdf() {
    _subscription = _auth.authStateChanges().listen(
      (user) {
        if (_user?.uid != user?.uid) {
          _generation++;
          _lastReport = null;
          _lastSignature = null;
          _error = null;
        }
        _user = user;
        _initialized = true;
        _emit();
      },
      onError: (Object _) {
        _initialized = true;
        _error = 'No pudimos cargar tu perfil.';
        _emit();
      },
    );
  }

  final AuthRepository _auth;
  final CertificateRepository _certificates;
  final HoursReportPdf _pdf;
  StreamSubscription<AppUser?>? _subscription;
  AppUser? _user;
  bool _initialized = false;
  bool _saving = false;
  bool _generating = false;
  bool _disposed = false;
  int _generation = 0;
  String? _error;
  HoursReport? _lastReport;
  String? _lastSignature;

  AppUser? get user => _user;
  bool get initialized => _initialized;
  bool get isSaving => _saving;
  bool get isGenerating => _generating;
  String? get error => _error;
  HoursReport? get lastReport => _lastReport;

  void _emit() {
    if (_disposed == false) notifyListeners();
  }

  Future<bool> guardarPerfil({
    required int horasRequeridas,
    required List<Causa> intereses,
  }) async {
    final user = _user;
    if (_saving || user == null || horasRequeridas < 0) return false;
    final generation = _generation;
    _saving = true;
    _error = null;
    _emit();
    try {
      await _auth.updateUser(
        user.copyWith(
          horasRequeridas: horasRequeridas,
          intereses: intereses.toSet().toList(),
        ),
      );
      return _disposed == false && generation == _generation;
    } catch (_) {
      if (generation == _generation) {
        _error =
            'No pudimos guardar los cambios. Revisa la conexión y reintenta.';
      }
      return false;
    } finally {
      _saving = false;
      _emit();
    }
  }

  Future<HoursReport?> generarReporte(List<Application> applications) async {
    final user = _user;
    if (_generating || user == null || user.esOrganizacion) return null;
    final completed =
        applications
            .where(
              (item) =>
                  item.userId == user.uid &&
                  item.estado.cuentaHoras &&
                  item.horasQueCuentan > 0,
            )
            .toList()
          ..sort((a, b) => a.id.compareTo(b.id));
    if (completed.isEmpty) {
      _error = 'Todavía no tienes horas acreditadas para generar un reporte.';
      _emit();
      return null;
    }
    final signature =
        '${user.uid}|${user.nombre}|${completed.map((a) => '${a.id}:${a.horasQueCuentan}:${a.actualizadaEn.toIso8601String()}').join('|')}';
    if (_lastSignature == signature) return _lastReport;
    final generation = _generation;
    _generating = true;
    _error = null;
    _emit();
    final stopwatch = Stopwatch()..start();
    try {
      String? codigo;
      for (var attempt = 0; attempt < 3; attempt++) {
        final candidate = _certificates.generarCodigo();
        final existing = await _certificates.validar(candidate);
        if (_disposed || generation != _generation) return null;
        if (existing == null) {
          codigo = candidate;
          break;
        }
      }
      if (codigo == null) throw StateError('No hay un código disponible.');
      final certificate = Certificate(
        codigo: codigo,
        userId: user.uid,
        nombre: user.nombre,
        applicationIds: completed
            .map((item) => item.id)
            .toList(growable: false),
        totalHoras: completed.fold(
          0,
          (sum, item) => sum + item.horasQueCuentan,
        ),
        emitidoEn: DateTime.now(),
      );
      final bytes = await _pdf.generate(certificate, completed);
      if (_disposed || generation != _generation) return null;
      // Solo entregamos el PDF después de confirmar que su código está guardado.
      await _certificates.guardar(certificate);
      if (_disposed || generation != _generation) return null;
      stopwatch.stop();
      _lastReport = HoursReport(
        certificate: certificate,
        bytes: bytes,
        elapsed: stopwatch.elapsed,
      );
      _lastSignature = signature;
      return _lastReport;
    } catch (_) {
      if (generation == _generation) {
        _error =
            'No pudimos emitir el reporte. Revisa la conexión y reintenta.';
      }
      return null;
    } finally {
      _generating = false;
      _emit();
    }
  }

  @override
  void dispose() {
    _disposed = true;
    _generation++;
    _subscription?.cancel();
    super.dispose();
  }
}
