import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:nodara/data/datasources/fake/fake_application_data_source.dart';
import 'package:nodara/data/datasources/fake/fake_auth_data_source.dart';
import 'package:nodara/data/datasources/fake/fake_certificate_data_source.dart';
import 'package:nodara/data/datasources/fake/fake_notification_data_source.dart';
import 'package:nodara/data/datasources/fake/fake_opportunity_data_source.dart';
import 'package:nodara/data/datasources/fake/fake_seed.dart';
import 'package:nodara/data/models/application.dart';
import 'package:nodara/data/models/certificate.dart';
import 'package:nodara/data/models/opportunity.dart';
import 'package:nodara/data/repositories/application_repository.dart';
import 'package:nodara/data/repositories/auth_repository.dart';
import 'package:nodara/data/repositories/certificate_repository.dart';
import 'package:nodara/data/repositories/notification_repository.dart';
import 'package:nodara/data/repositories/opportunity_repository.dart';
import 'package:nodara/features/applicants/applicants_provider.dart';
import 'package:nodara/features/accreditation/accreditation_provider.dart';
import 'package:nodara/features/applications/applications_provider.dart';
import 'package:nodara/features/profile/profile_provider.dart';

Future<void> _flush() => Future<void>.delayed(Duration.zero);

class _Certificates extends FakeCertificateDataSource {
  bool fail = false;
  int writes = 0;
  Completer<void>? gate;
  @override
  Future<void> create(Certificate certificate) async {
    writes++;
    await gate?.future;
    if (fail) throw StateError('Sin conexión');
    await super.create(certificate);
  }
}

class _Applications extends FakeApplicationDataSource {
  _Applications(super.seed);
  bool fail = false;
  StreamController<List<Application>>? changes;
  final states = <EstadoPostulacion>[];
  @override
  Stream<List<Application>> watchByOrg(String orgId) =>
      changes?.stream ?? super.watchByOrg(orgId);
  @override
  Future<void> updateEstado({
    required String applicationId,
    required EstadoPostulacion estado,
    int? horasAcreditadas,
    String? motivo,
  }) async {
    if (fail) throw StateError('Sin conexión');
    states.add(estado);
    await super.updateEstado(
      applicationId: applicationId,
      estado: estado,
      horasAcreditadas: horasAcreditadas,
      motivo: motivo,
    );
  }
}

void main() {
  test(
    'Un error del stream bloquea la acreditación de datos anteriores',
    () async {
      final item = FakeSeed.applications().first.copyWith(
        estado: EstadoPostulacion.enCurso,
      );
      final changes = StreamController<List<Application>>.broadcast();
      final source = _Applications([item])..changes = changes;
      final provider = AccreditationProvider(
        applicationId: item.id,
        applications: ApplicationRepository(source),
        auth: AuthRepository(
          FakeAuthDataSource(initialUser: FakeSeed.orgFuturo),
        ),
      );
      await _flush();
      changes.add([item]);
      await _flush();
      expect(provider.canAccredit, isTrue);
      changes.addError(StateError('Sin conexión'));
      await _flush();
      expect(provider.canAccredit, isFalse);
      expect(await provider.acreditar(5), isFalse);
      expect(source.states, isEmpty);
      provider.dispose();
      await changes.close();
    },
  );

  test('Humo Fake R4/R5: aceptar, acreditar, perfil y validar PDF', () async {
    final item = FakeSeed.applications().first.copyWith(
      estado: EstadoPostulacion.pendiente,
    );
    final applications = ApplicationRepository(
      FakeApplicationDataSource([item]),
    );
    final auth = AuthRepository(
      FakeAuthDataSource(initialUser: FakeSeed.orgFuturo),
    );
    final opportunities = OpportunityRepository(FakeOpportunityDataSource());
    final notifications = NotificationRepository(FakeNotificationDataSource());
    final applicants = ApplicantsProvider(
      opportunityId: item.opportunityId,
      applications: applications,
      opportunities: opportunities,
      notifications: notifications,
      auth: auth,
    );
    final accreditation = AccreditationProvider(
      applicationId: item.id,
      applications: applications,
      auth: auth,
    );
    final impact = ApplicationsProvider(applications, auth);
    final certificates = CertificateRepository(FakeCertificateDataSource());
    final profile = ProfileProvider(auth: auth, certificates: certificates);
    addTearDown(applicants.dispose);
    addTearDown(accreditation.dispose);
    addTearDown(impact.dispose);
    addTearDown(profile.dispose);
    await _flush();
    expect(await applicants.responder(item, aceptar: true), isTrue);
    await _flush();
    expect(
      (await notifications.watchMine(item.userId).first).any(
        (n) => n.applicationId == item.id,
      ),
      isTrue,
    );
    expect(await accreditation.acreditar(9), isTrue);
    await auth.signIn(email: 'sofia@nodara.app', password: '123456');
    await _flush();
    expect(impact.horasCompletadas, 9);
    final report = await profile.generarReporte(impact.completadas);
    expect(report, isNotNull);
    if (report == null) return;
    expect(
      (await certificates.validar(report.certificate.codigo))?.totalHoras,
      9,
    );
    expect(String.fromCharCodes(report.bytes.take(5)), '%PDF-');
  });

  test('El código usa NOD-XXXX-XXXX y evita caracteres ambiguos', () {
    final repository = CertificateRepository(FakeCertificateDataSource());
    final codes = List.generate(100, (_) => repository.generarCodigo());
    expect(
      codes.every(
        RegExp(r'^NOD-[A-HJ-NP-Z2-9]{4}-[A-HJ-NP-Z2-9]{4}$').hasMatch,
      ),
      isTrue,
    );
    expect(codes.toSet().length, 100);
  });

  test(
    'Acreditar desde aceptado respeta las transiciones y suma horas al perfil',
    () async {
      final accepted = FakeSeed.applications().first.copyWith(
        estado: EstadoPostulacion.aceptado,
      );
      final source = _Applications([accepted]);
      final applications = ApplicationRepository(source);
      final organizationAuth = AuthRepository(
        FakeAuthDataSource(initialUser: FakeSeed.orgFuturo),
      );
      final volunteerAuth = AuthRepository(FakeAuthDataSource());
      final impact = ApplicationsProvider(applications, volunteerAuth);
      final provider = AccreditationProvider(
        applicationId: accepted.id,
        applications: applications,
        auth: organizationAuth,
      );
      addTearDown(impact.dispose);
      addTearDown(provider.dispose);
      await _flush();
      expect(impact.horasCompletadas, 0);
      expect(await provider.acreditar(7), isTrue);
      await _flush();
      expect(source.states, [
        EstadoPostulacion.enCurso,
        EstadoPostulacion.completado,
      ]);
      expect(impact.horasCompletadas, 7);
      expect(impact.completadas.single.horasAcreditadas, 7);
      expect(await provider.acreditar(7), isFalse);
      expect(impact.horasCompletadas, 7);
    },
  );

  test(
    'No acredita cero, pendientes, completadas ni como voluntario',
    () async {
      for (final state in [
        EstadoPostulacion.pendiente,
        EstadoPostulacion.completado,
        EstadoPostulacion.rechazado,
      ]) {
        final item = FakeSeed.applications().first.copyWith(estado: state);
        final source = _Applications([item]);
        final provider = AccreditationProvider(
          applicationId: item.id,
          applications: ApplicationRepository(source),
          auth: AuthRepository(
            FakeAuthDataSource(initialUser: FakeSeed.orgFuturo),
          ),
        );
        await _flush();
        expect(await provider.acreditar(5), isFalse);
        expect(source.states, isEmpty);
        provider.dispose();
      }
      final item = FakeSeed.applications().first.copyWith(
        estado: EstadoPostulacion.enCurso,
      );
      final source = _Applications([item]);
      final auth = AuthRepository(
        FakeAuthDataSource(initialUser: FakeSeed.orgFuturo),
      );
      final provider = AccreditationProvider(
        applicationId: item.id,
        applications: ApplicationRepository(source),
        auth: auth,
      );
      addTearDown(provider.dispose);
      await _flush();
      expect(await provider.acreditar(0), isFalse);
      expect(await provider.acreditar(-3), isFalse);
      await auth.signIn(email: 'sofia@nodara.app', password: '123456');
      await _flush();
      expect(await provider.acreditar(5), isFalse);
      expect(source.states, isEmpty);
    },
  );

  test('Si falla la acreditación no suma horas y permite reintentar', () async {
    final item = FakeSeed.applications().first.copyWith(
      estado: EstadoPostulacion.enCurso,
    );
    final source = _Applications([item])..fail = true;
    final provider = AccreditationProvider(
      applicationId: item.id,
      applications: ApplicationRepository(source),
      auth: AuthRepository(FakeAuthDataSource(initialUser: FakeSeed.orgFuturo)),
    );
    addTearDown(provider.dispose);
    await _flush();
    expect(await provider.acreditar(4), isFalse);
    expect(provider.error, isNotNull);
    expect(provider.application?.horasQueCuentan, 0);
    source.fail = false;
    expect(await provider.acreditar(4), isTrue);
  });

  group('Perfil y PDF', () {
    late ProfileProvider provider;
    late AuthRepository auth;
    late CertificateRepository certificates;
    late _Certificates source;
    setUp(() async {
      source = _Certificates();
      auth = AuthRepository(FakeAuthDataSource());
      certificates = CertificateRepository(source);
      provider = ProfileProvider(auth: auth, certificates: certificates);
      await _flush();
    });
    tearDown(() => provider.dispose());

    test(
      'Guardar meta e intereses conserva identidad y otros campos',
      () async {
        final before = provider.user;
        expect(
          await provider.guardarPerfil(
            horasRequeridas: 100,
            intereses: [Causa.animales],
          ),
          isTrue,
        );
        await _flush();
        expect(provider.user?.horasRequeridas, 100);
        expect(provider.user?.intereses, [Causa.animales]);
        expect(provider.user?.uid, before?.uid);
        expect(provider.user?.rol, before?.rol);
        expect(provider.user?.favoritos, before?.favoritos);
        expect(
          await provider.guardarPerfil(horasRequeridas: -1, intereses: []),
          isFalse,
        );
      },
    );

    test(
      'PDF real guarda solo horas completadas y su código se puede validar',
      () async {
        final report = await provider.generarReporte(FakeSeed.applications());
        expect(report, isNotNull);
        if (report == null) return;
        expect(String.fromCharCodes(report.bytes.take(5)), '%PDF-');
        expect(report.certificate.totalHoras, 45);
        expect(report.certificate.applicationIds.length, 2);
        final saved = await certificates.validar(
          ' ${report.certificate.codigo.toLowerCase()} ',
        );
        expect(saved?.totalHoras, 45);
        expect(saved?.nombre, 'Sofía');
        expect(report.elapsed.inSeconds, lessThan(3));
      },
    );

    test(
      'Reintentar la descarga reutiliza el PDF y no emite otro certificado',
      () async {
        final items = FakeSeed.applications();
        final first = await provider.generarReporte(items);
        final second = await provider.generarReporte(items);
        expect(identical(first, second), isTrue);
        expect(source.writes, 1);
      },
    );

    test(
      'Sin completadas no emite; un fallo al guardar no entrega PDF',
      () async {
        expect(await provider.generarReporte([]), isNull);
        expect(source.writes, 0);
        source.fail = true;
        expect(await provider.generarReporte(FakeSeed.applications()), isNull);
        expect(provider.lastReport, isNull);
        expect(provider.isGenerating, isFalse);
        expect(provider.error, contains('No pudimos emitir'));
        source.fail = false;
        expect(
          await provider.generarReporte(FakeSeed.applications()),
          isNotNull,
        );
      },
    );

    test(
      'Cambiar de sesión durante la emisión descarta el resultado privado',
      () async {
        source.gate = Completer<void>();
        final pending = provider.generarReporte(FakeSeed.applications());
        while (source.writes == 0) {
          await _flush();
        }
        expect(await provider.generarReporte(FakeSeed.applications()), isNull);
        await auth.signOut();
        await _flush();
        source.gate?.complete();
        expect(await pending, isNull);
        expect(provider.lastReport, isNull);
        expect(provider.user, isNull);
      },
    );
  });
}
