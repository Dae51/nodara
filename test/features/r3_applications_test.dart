import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import 'package:nodara/core/widgets/loading_view.dart';
import 'package:nodara/core/di/app_dependencies.dart';
import 'package:nodara/main.dart';
import 'package:nodara/data/datasources/fake/fake_application_data_source.dart';
import 'package:nodara/data/datasources/fake/fake_auth_data_source.dart';
import 'package:nodara/data/datasources/fake/fake_opportunity_data_source.dart';
import 'package:nodara/data/datasources/fake/fake_seed.dart';
import 'package:nodara/data/models/application.dart';
import 'package:nodara/data/models/opportunity.dart';
import 'package:nodara/data/repositories/application_repository.dart';
import 'package:nodara/data/repositories/auth_repository.dart';
import 'package:nodara/data/repositories/opportunity_repository.dart';
import 'package:nodara/features/applications/applications_provider.dart';
import 'package:nodara/features/applications/my_applications_screen.dart';
import 'package:nodara/features/applications/widgets/applications_tab_selector.dart';
import 'package:nodara/features/auth/auth_provider.dart';
import 'package:nodara/features/explore/explore_provider.dart';
import 'package:nodara/features/explore/widgets/filter_chips_row.dart';
import 'package:nodara/features/opportunity_detail/opportunity_detail_screen.dart';
import 'package:nodara/theme/app_theme.dart';

// Extiende el Fake del equipo para controlar errores y demoras sin Firebase.
class _ApplicationsFake extends FakeApplicationDataSource {
  _ApplicationsFake([super.seed]);

  int creations = 0;
  bool failCreate = false;
  bool failWithdraw = false;
  bool failWatch = false;
  Completer<void>? createGate;
  Completer<void>? snapshotGate;

  @override
  Stream<List<Application>> watchByUser(String userId) {
    if (failWatch) return Stream.error(StateError('Sin conexión'));
    return super.watchByUser(userId).asyncMap((items) async {
      await snapshotGate?.future;
      return items;
    });
  }

  @override
  Future<String> create(Application application) async {
    creations++;
    await createGate?.future;
    if (failCreate) throw StateError('No se pudo guardar');
    return super.create(application);
  }

  @override
  Future<void> updateEstado({
    required String applicationId,
    required EstadoPostulacion estado,
    int? horasAcreditadas,
    String? motivo,
  }) async {
    if (failWithdraw) throw StateError('No se pudo retirar');
    await super.updateEstado(
      applicationId: applicationId,
      estado: estado,
      horasAcreditadas: horasAcreditadas,
      motivo: motivo,
    );
  }
}

class _OpportunitiesFake extends FakeOpportunityDataSource {
  final changes = StreamController<List<Opportunity>>.broadcast();

  @override
  Stream<List<Opportunity>> watchActive() => changes.stream;
}

Future<ApplicationsProvider> _pump(
  WidgetTester tester,
  _ApplicationsFake source, {
  Widget home = const OpportunityDetailScreen(opportunityId: 'salud'),
  FakeOpportunityDataSource? opportunities,
  double scale = 1,
}) async {
  final auth = AuthRepository(FakeAuthDataSource());
  final applications = ApplicationsProvider(
    ApplicationRepository(source),
    auth,
  );
  addTearDown(applications.dispose);
  await tester.pumpWidget(
    MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: applications),
        ChangeNotifierProvider(create: (_) => AuthProvider(auth)),
        ChangeNotifierProvider(
          create: (_) => ExploreProvider(
            OpportunityRepository(opportunities ?? FakeOpportunityDataSource()),
          ),
        ),
      ],
      child: MaterialApp(
        theme: AppTheme.light,
        builder: (context, child) => MediaQuery(
          data: MediaQuery.of(context)
              .copyWith(textScaler: TextScaler.linear(scale)),
          child: child ?? const SizedBox.shrink(),
        ),
        home: home,
      ),
    ),
  );
  await tester.pump();
  return applications;
}

Future<void> _tap(WidgetTester tester, String label) async {
  final finder = find.text(label);
  await tester.ensureVisible(finder);
  await tester.pumpAndSettle();
  await tester.tap(finder);
  await tester.pumpAndSettle();
}

int _selectedTab(WidgetTester tester) => tester
    .widget<ApplicationsTabSelector>(find.byType(ApplicationsTabSelector))
    .selected;

void main() {
  setUpAll(() => GoogleFonts.config.allowRuntimeFetching = false);

  testWidgets('cancelar o cerrar no crea; confirmar, navegar y retirarse', (
    tester,
  ) async {
    final source = _ApplicationsFake([]);
    final provider = await _pump(tester, source);
    await tester.pumpAndSettle();
    await _tap(tester, 'Postularme ahora');
    await _tap(tester, 'Cancelar');
    expect(source.creations, 0);
    await _tap(tester, 'Postularme ahora');
    await tester.tapAt(const Offset(5, 5));
    await tester.pumpAndSettle();
    expect(source.creations, 0);
    await _tap(tester, 'Postularme ahora');
    await _tap(tester, 'Confirmar');
    expect(source.creations, 1);
    expect(provider.activas.single.opportunityId, 'salud');
    await _tap(tester, 'Ver mi postulación');
    expect(find.byType(MyApplicationsScreen), findsOneWidget);
    expect(_selectedTab(tester), 0);
    await _tap(tester, 'Retirarme');
    await _tap(tester, 'Volver');
    expect(provider.activas, hasLength(1));
    await _tap(tester, 'Retirarme');
    await _tap(tester, 'Sí, retirarme');
    expect(provider.activas, isEmpty);
    expect(provider.cerradas.single.estado, EstadoPostulacion.retirado);
    expect(_selectedTab(tester), 2);
    await _tap(tester, 'Ver detalle');
    expect(find.byType(OpportunityDetailScreen), findsOneWidget);
    expect(find.text('Postularme ahora'), findsOneWidget);
    await tester.tap(find.byTooltip('Volver'));
    await tester.pumpAndSettle();
    await tester.pageBack();
    await tester.pumpAndSettle();
    expect(find.byType(OpportunityDetailScreen), findsOneWidget);
  });

  testWidgets('bloquea pulsaciones durante carga, envío y espera del stream', (
    tester,
  ) async {
    final source = _ApplicationsFake([])..snapshotGate = Completer<void>();
    final provider = await _pump(tester, source);
    final opportunity = FakeSeed.opportunities().firstWhere(
      (o) => o.id == 'salud',
    );
    expect(provider.isLoading, isTrue);
    expect(await provider.postular(opportunity), isFalse);
    source.snapshotGate?.complete();
    await tester.pumpAndSettle();
    source.snapshotGate = Completer<void>();
    source.createGate = Completer<void>();
    final apply = find.text('Postularme ahora');
    final applyPosition = tester.getCenter(apply);
    await tester.tapAt(applyPosition);
    await tester.tapAt(applyPosition);
    await tester.pumpAndSettle();
    expect(find.byType(AlertDialog), findsOneWidget);
    await _tap(tester, 'Confirmar');
    expect(source.creations, 1);
    expect(await provider.postular(opportunity), isFalse);
    source.createGate?.complete();
    await tester.pumpAndSettle();
    expect(provider.isSubmitting('salud'), isTrue);
    expect(await provider.postular(opportunity), isFalse);
    expect(source.creations, 1);
    source.snapshotGate?.complete();
    await tester.pumpAndSettle();
    expect(provider.activas, hasLength(1));
    expect(find.text('Ver mi postulación'), findsOneWidget);
  });

  testWidgets(
    'errores de guardar y retirar permiten reintentar sin fingir éxito',
    (tester) async {
      final source = _ApplicationsFake([])..failCreate = true;
      final provider = await _pump(tester, source);
      await tester.pumpAndSettle();
      await _tap(tester, 'Postularme ahora');
      await _tap(tester, 'Confirmar');
      expect(provider.activas, isEmpty);
      expect(
        find.text('No pudimos enviar tu postulación. Intenta de nuevo.'),
        findsOneWidget,
      );
      source.failCreate = false;
      await _tap(tester, 'Postularme ahora');
      await _tap(tester, 'Confirmar');
      await _tap(tester, 'Ver mi postulación');
      source.failWithdraw = true;
      await _tap(tester, 'Retirarme');
      await _tap(tester, 'Sí, retirarme');
      expect(provider.activas, hasLength(1));
      expect(_selectedTab(tester), 0);
      expect(find.text('No pudimos procesar tu solicitud'), findsOneWidget);
      source.failWithdraw = false;
      await _tap(tester, 'Retirarme');
      await _tap(tester, 'Sí, retirarme');
      expect(provider.cerradas, hasLength(1));
    },
  );

  testWidgets(
    'detalle distingue carga, error con reintento, inexistente y datos',
    (tester) async {
      final opportunities = _OpportunitiesFake();
      addTearDown(opportunities.changes.close);
      await _pump(tester, _ApplicationsFake([]), opportunities: opportunities);
      expect(find.byType(LoadingView), findsOneWidget);
      expect(
        find.text('Esta convocatoria ya no está disponible.'),
        findsNothing,
      );
      opportunities.changes.addError(StateError('Sin conexión'));
      await tester.pumpAndSettle();
      expect(find.text('Reintentar'), findsOneWidget);
      await tester.tap(find.text('Reintentar'));
      await tester.pump();
      expect(find.byType(LoadingView), findsOneWidget);
      opportunities.changes.add([]);
      await tester.pumpAndSettle();
      expect(
        find.text('Esta convocatoria ya no está disponible.'),
        findsOneWidget,
      );
      opportunities.changes.add(FakeSeed.opportunities());
      await tester.pumpAndSettle();
      expect(find.text('Postularme ahora'), findsOneWidget);
    },
  );

  testWidgets(
    'Mis postulaciones distingue carga, error, reintento y vacíos por pestaña',
    (tester) async {
      final source = _ApplicationsFake([])..snapshotGate = Completer<void>();
      final provider = await _pump(
        tester,
        source,
        home: const MyApplicationsScreen(),
      );
      expect(find.byType(LoadingView), findsOneWidget);
      source.snapshotGate?.complete();
      await tester.pumpAndSettle();
      source.failWatch = true;
      provider.retry();
      await tester.pumpAndSettle();
      expect(find.text('No pudimos cargar tus postulaciones.'), findsOneWidget);
      source.failWatch = false;
      await _tap(tester, 'Reintentar');
      for (final tab in ['Activas', 'Completadas', 'Cerradas']) {
        await _tap(tester, tab);
        expect(
          find.text(
            tab == 'Cerradas'
                ? 'Todavía no tenés postulaciones cerradas.'
                : 'No hay postulaciones en esta sección.',
          ),
          findsOneWidget,
        );
      }
    },
  );

  testWidgets(
    'conserva todos los estados y getters; enCurso no permite retiro',
    (tester) async {
      final base = FakeSeed.applications().first;
      final records = [
        for (final state in EstadoPostulacion.values)
          base.copyWith(
            id: state.name,
            estado: state,
            motivo: 'Motivo del cierre',
          ),
      ];
      final provider = await _pump(
        tester,
        _ApplicationsFake(records),
        home: const MyApplicationsScreen(),
      );
      await tester.pumpAndSettle();
      expect(
        provider.activas.length +
            provider.completadas.length +
            provider.cerradas.length,
        EstadoPostulacion.values.length,
      );
      expect(
        provider.horasCompletadas,
        provider.completadas.single.horasQueCuentan,
      );
      expect(provider.nivel, 1 + provider.horasCompletadas ~/ 15);
      expect(provider.progresoPorcentaje, (provider.progreso * 100).round());
      final inProgress = records.firstWhere(
        (a) => a.estado == EstadoPostulacion.enCurso,
      );
      expect(await provider.retirar(inProgress), isFalse);
      // Una sola tarjeta permite comprobar que la UI tampoco ofrece retirarse.
      await _pump(
        tester,
        _ApplicationsFake([inProgress]),
        home: const MyApplicationsScreen(),
      );
      await tester.pumpAndSettle();
      expect(find.text('Retirarme'), findsNothing);
    },
  );

  testWidgets(
    'R3 cabe a 360 px con texto 1.3 y navega a Completadas/Cerradas',
    (tester) async {
      tester.view.physicalSize = const Size(360, 800);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      for (final state in [
        EstadoPostulacion.completado,
        EstadoPostulacion.rechazado,
      ]) {
        final application = FakeSeed.applications().first.copyWith(
          estado: state,
          motivo: 'Cupos completos',
        );
        await _pump(
          tester,
          _ApplicationsFake([application]),
          scale: 1.3,
          home: OpportunityDetailScreen(
            opportunityId: application.opportunityId,
          ),
        );
        await tester.pumpAndSettle();

        for (var i = 0; i < 6; i++) {
          await tester.drag(find.byType(ListView), const Offset(0, -450));
          await tester.pumpAndSettle();
        }
        await _tap(tester, 'Ver mi postulación');
        expect(_selectedTab(tester), state.cuentaHoras ? 1 : 2);

        await tester.drag(
          find.byType(CustomScrollView).last,
          const Offset(0, -450),
        );
        await tester.pumpAndSettle();

        expect(tester.takeException(), isNull);
        if (state.esCerrada) {
          expect(find.text('Cupos completos'), findsOneWidget);
        }
        await tester.pumpWidget(const SizedBox.shrink());
      }
    },
  );
  testWidgets(
    'humo Fake: registro, explorar, R3 y entrada al panel de organización',
    (tester) async {
      await tester.pumpWidget(
        NodaraApp(
          dependencies: AppDependencies.fake(
            startSignedIn: false,
            onboardingVisto: true,
          ),
        ),
      );
      await tester.pumpAndSettle();
      await _tap(tester, 'Crear cuenta');
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Nombre'),
        'Prueba R3',
      );
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Correo'),
        'prueba-r3@example.com',
      );
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Contraseña'),
        'prueba123',
      );
      await _tap(tester, 'Crear cuenta');
      expect(find.text('¡Hola, Prueba R3!'), findsOneWidget);
      await tester.enterText(find.byType(TextField), 'Cruz');
      await tester.pumpAndSettle();
      await tester.scrollUntilVisible(
        find.text('Salud'),
        200,
        scrollable: find.descendant(
          of: find.byType(FilterChipsRow).first,
          matching: find.byType(Scrollable),
        ),
      );
      await _tap(tester, 'Salud');
      // Los tres toques de R3, una vez elegida la convocatoria en el feed.
      await _tap(tester, 'Campaña de Salud y Prevención Dental Comunitaria');
      await _tap(tester, 'Postularme ahora');
      await _tap(tester, 'Confirmar');
      await _tap(tester, 'Ver mi postulación');
      expect(_selectedTab(tester), 0);
      expect(
        find.text('Campaña de Salud y Prevención Dental Comunitaria'),
        findsOneWidget,
      );
      await tester.pageBack();
      await tester.pumpAndSettle();
      await tester.tap(find.byTooltip('Volver'));
      await tester.pumpAndSettle();
      await _tap(tester, 'Perfil');
      await _tap(tester, 'Cerrar sesión');
      // Deja terminar el mensaje temporal antes de tocar el enlace inferior.
      await tester.pump(const Duration(seconds: 5));
      await tester.pumpAndSettle();
      await _tap(tester, 'Iniciar sesión');
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Correo'),
        'org@nodara.app',
      );
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Contraseña'),
        '123456',
      );
      await _tap(tester, 'Ingresar');
      // El panel sigue siendo un placeholder ajeno a R3: el humo se detiene aquí.
      expect(
        find.text('Panel de organización · en construcción'),
        findsOneWidget,
      );
      expect(find.text('Aceptar'), findsNothing);
      expect(find.text('Acreditar'), findsNothing);
    },
  );
}
