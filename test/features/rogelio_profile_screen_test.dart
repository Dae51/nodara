import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:nodara/core/di/app_dependencies.dart';
import 'package:nodara/data/datasources/fake/fake_application_data_source.dart';
import 'package:nodara/data/datasources/fake/fake_seed.dart';
import 'package:nodara/data/models/application.dart';
import 'package:nodara/data/models/certificate.dart';
import 'package:nodara/data/repositories/application_repository.dart';
import 'package:nodara/features/accreditation/accreditation_dialog.dart';
import 'package:nodara/features/applications/applications_provider.dart';
import 'package:nodara/features/auth/auth_provider.dart';
import 'package:nodara/features/profile/profile_screen.dart';
import 'package:nodara/theme/app_theme.dart';

class _ControlledApplications extends FakeApplicationDataSource {
  _ControlledApplications(super.seed);
  bool fail = false;
  Completer<void>? gate;
  @override
  Stream<List<Application>> watchByUser(String userId) {
    if (fail) return Stream.error(StateError('Sin conexión'));
    return super.watchByUser(userId).asyncMap((items) async {
      await gate?.future;
      return items;
    });
  }
}

Future<void> _pumpProfile(
  WidgetTester tester,
  AppDependencies dependencies,
) async {
  await tester.pumpWidget(
    MultiProvider(
      providers: [
        Provider<AppDependencies>.value(value: dependencies),
        ChangeNotifierProvider(create: (_) => AuthProvider(dependencies.auth)),
        ChangeNotifierProvider(
          create: (_) => ApplicationsProvider(
            dependencies.applications,
            dependencies.auth,
          ),
        ),
      ],
      child: MaterialApp(
        theme: AppTheme.light,
        builder: (context, child) => MediaQuery(
          data: MediaQuery.of(context)
              .copyWith(textScaler: TextScaler.linear(1.3)),
          child: child ?? const SizedBox.shrink(),
        ),
        home: const ProfileScreen(),
      ),
    ),
  );
  await tester.pump();
  await tester.pump();
}

AppDependencies _withApplications(_ControlledApplications source) {
  final base = AppDependencies.fake();
  return AppDependencies(
    auth: base.auth,
    opportunities: base.opportunities,
    applications: ApplicationRepository(source),
    donations: base.donations,
    notifications: base.notifications,
    certificates: base.certificates,
    preferences: base.preferences,
  );
}

Future<void> _tap(WidgetTester tester, Finder finder) async {
  await tester.ensureVisible(finder);
  await tester.pumpAndSettle();
  await tester.tap(finder);
  await tester.pumpAndSettle();
}

void main() {
  setUpAll(() => GoogleFonts.config.allowRuntimeFetching = false);

  testWidgets(
    'Perfil a 360 px y texto 1.3 muestra horas y guarda meta e intereses',
    (tester) async {
      tester.view.physicalSize = const Size(360, 800);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final dependencies = AppDependencies.fake();
      await _pumpProfile(tester, dependencies);
      await tester.pumpAndSettle();
      expect(find.text('45 horas acreditadas'), findsOneWidget);
      expect(find.text('45 / 80 hrs'), findsOneWidget);
      await _tap(tester, find.text('Editar perfil'));
      final hours = find.widgetWithText(TextFormField, 'Horas requeridas');
      await tester.enterText(hours, '');
      await _tap(tester, find.text('Guardar cambios'));
      expect(
        find.text('Escribe un número entero igual o mayor que cero.'),
        findsOneWidget,
      );
      await tester.enterText(hours, '120');
      await _tap(tester, find.widgetWithText(FilterChip, 'Animales'));
      await _tap(tester, find.text('Guardar cambios'));
      expect(find.text('45 / 120 hrs'), findsOneWidget);
      expect(find.widgetWithText(Chip, 'Animales'), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'Perfil muestra cargando y luego vacío con descarga deshabilitada',
    (tester) async {
      final source = _ControlledApplications([])..gate = Completer<void>();
      await _pumpProfile(tester, _withApplications(source));
      expect(find.byType(LinearProgressIndicator), findsWidgets);
      source.gate?.complete();
      await tester.pumpAndSettle();
      await tester.scrollUntilVisible(
        find.textContaining('Todavía no tienes actividades'),
        180,
      );
      expect(
        find.textContaining('Todavía no tienes actividades'),
        findsOneWidget,
      );
      final button = tester.widget<FilledButton>(
        find.widgetWithText(FilledButton, 'Descargar reporte'),
      );
      expect(button.onPressed, isNull);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'Error de postulaciones permite reintentar sin mostrar horas inventadas',
    (tester) async {
      final source = _ControlledApplications(FakeSeed.applications())
        ..fail = true;
      await _pumpProfile(tester, _withApplications(source));
      await tester.pumpAndSettle();
      await tester.scrollUntilVisible(find.text('Reintentar'), 180);
      expect(find.text('No pudimos cargar tus postulaciones.'), findsOneWidget);
      expect(find.text('45 horas acreditadas'), findsNothing);
      source.fail = false;
      await _tap(tester, find.text('Reintentar'));
      await tester.scrollUntilVisible(find.text('45 horas acreditadas'), -180);
      expect(find.text('45 horas acreditadas'), findsOneWidget);
    },
  );

  testWidgets(
    'Valida un código persistido y distingue un certificado inexistente',
    (tester) async {
      final dependencies = AppDependencies.fake();
      await dependencies.certificates.guardar(
        Certificate(
          codigo: 'NOD-ABCD-EFGH',
          userId: FakeSeed.sofiaId,
          nombre: 'Sofía',
          applicationIds: const ['app'],
          totalHoras: 12,
          emitidoEn: DateTime(2026, 11, 2),
        ),
      );
      await _pumpProfile(tester, dependencies);
      await tester.pumpAndSettle();
      await tester.scrollUntilVisible(find.text('Validar certificado'), 180);
      await _tap(tester, find.text('Validar certificado'));
      await tester.enterText(find.byType(TextFormField), 'nod-abcd-efgh');
      await _tap(tester, find.text('Validar'));
      expect(find.text('Certificado encontrado'), findsOneWidget);
      expect(find.text('12 horas acreditadas'), findsOneWidget);
      await tester.enterText(find.byType(TextFormField), 'NOD-ZZZZ-ZZZZ');
      await _tap(tester, find.text('Validar'));
      expect(
        find.text('No encontramos un certificado con ese código.'),
        findsOneWidget,
      );
    },
  );

  testWidgets('El diálogo rechaza horas vacías, acredita y cierra con true', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(360, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final dependencies = AppDependencies.fake();
    await dependencies.auth.signIn(email: 'org@nodara.app', password: '123456');
    final items = await dependencies.applications
        .watchForOrg(FakeSeed.orgFuturoId)
        .first;
    final item = items.first;
    await dependencies.applications.cambiarEstado(
      applicationId: item.id,
      estado: EstadoPostulacion.enCurso,
    );
    bool? result;
    await tester.pumpWidget(
      Provider<AppDependencies>.value(
        value: dependencies,
        child: MaterialApp(
          theme: AppTheme.light,
          builder: (context, child) => MediaQuery(
            data: MediaQuery.of(context)
                .copyWith(textScaler: TextScaler.linear(1.3)),
            child: child ?? const SizedBox.shrink(),
          ),
          home: Builder(
            builder: (context) => Scaffold(
              body: TextButton(
                onPressed: () async {
                  result = await showAccreditationDialog(context, item);
                },
                child: const Text('Abrir acreditar'),
              ),
            ),
          ),
        ),
      ),
    );
    await _tap(tester, find.text('Abrir acreditar'));
    await tester.enterText(find.byType(TextFormField), '');
    await _tap(tester, find.text('Confirmar horas'));
    expect(
      find.text('Escribe un número entero mayor que cero.'),
      findsOneWidget,
    );
    await tester.enterText(find.byType(TextFormField), '6');
    await _tap(tester, find.text('Confirmar horas'));
    expect(result, isTrue);
    final updated = await dependencies.applications
        .watchForOrg(FakeSeed.orgFuturoId)
        .first;
    expect(updated.where((a) => a.id == item.id).single.horasQueCuentan, 6);
    expect(tester.takeException(), isNull);
  });
}
