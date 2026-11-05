// Pruebas R3 que ejecuta flutter test usando fuentes Fake en memoria.
// Guía de estudio R3: Javier Alejandro Paniagua Morán · carné 20245194.
// Pruebas incorporadas en la entrega R3; no verifican reglas ni transacciones de
// Firebase real.
// Referencia del aporte: docs/bitacora/javier.md y commit f0b6416.
// La revisión local añade comprobaciones de ancho, contadores y búsqueda de pestaña.
// Índice: Fakes y demoras; Montaje; Confirmación; Bloqueos; Errores; Estados; Tamaño;
// Humo.

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
import 'package:nodara/features/applications/widgets/application_actions.dart';
import 'package:nodara/features/applications/widgets/applications_tab_selector.dart';
import 'package:nodara/features/auth/auth_provider.dart';
import 'package:nodara/features/explore/explore_provider.dart';
import 'package:nodara/features/explore/widgets/filter_chips_row.dart';
import 'package:nodara/features/opportunity_detail/opportunity_detail_screen.dart';
import 'package:nodara/features/opportunity_detail/widgets/apply_bar.dart';
import 'package:nodara/theme/app_theme.dart';

// SECCIÓN: Fakes y demoras controladas
/// Extiende el Fake del equipo para simular errores y esperas sin Firebase real.
class _ApplicationsFake extends FakeApplicationDataSource {
  /// Pasa seed al Fake base; [] inicia sin postulaciones y omitirlo usa sus ejemplos.
  _ApplicationsFake([super.seed]);

  // Cuenta intentos de creación, incluso los que fallan; detecta envíos repetidos.
  int creations = 0;
  bool failCreate = false;
  bool failWithdraw = false;
  bool failWatch = false;
  // ? permite no poner demora. Completer ofrece un Future que solo termina
  // al llamar complete(): createGate frena escritura y snapshotGate frena lectura.
  Completer<void>? createGate;
  Completer<void>? snapshotGate;

  /// Para userId, simula fallo de lectura o demora cada lista emitida por el Fake.
  @override
  Stream<List<Application>> watchByUser(String userId) {
    if (failWatch) return Stream.error(StateError('Sin conexión'));
    // asyncMap conserva el recorrido del stream y permite esperar cada lista.
    return super.watchByUser(userId).asyncMap((items) async {
      // await pausa hasta complete(); ?. omite la espera efectiva si no hay puerta.
      await snapshotGate?.future;
      return items;
    });
  }

  /// Cuenta el intento, espera createGate y falla o devuelve el ID del Fake base.
  @override
  Future<String> create(Application application) async {
    creations++;
    await createGate?.future;
    if (failCreate) throw StateError('No se pudo guardar');
    return super.create(application);
  }

  /// Recibe ID, estado y opcionales del contrato; simula error o delega al Fake.
  /// required exige ID/estado; este Fake no reproduce la transacción Firestore.
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

/// Entrega solo los eventos que la prueba añade para controlar los estados del detalle.
class _OpportunitiesFake extends FakeOpportunityDataSource {
  // final fija el controlador; broadcast permite que haya varios oyentes.
  final changes = StreamController<List<Opportunity>>.broadcast();

  /// Devuelve el stream controlado; la prueba decide cuándo emitir datos o error.
  @override
  Stream<List<Opportunity>> watchActive() => changes.stream;
}

// SECCIÓN: Montaje de pantalla
/// Monta home con providers y repositorios reales, pero fuentes Fake.
/// tester controla Flutter; source controla postulaciones; opportunities sustituye
/// convocatorias y scale amplía texto. Devuelve el Provider para comprobar su estado.
Future<ApplicationsProvider> _pump(
  WidgetTester tester,
  _ApplicationsFake source, {
  Widget home = const OpportunityDetailScreen(opportunityId: 'salud'),
  FakeOpportunityDataSource? opportunities,
  double scale = 1,
}) async {
  // 1. Construye la cadena pantalla → Provider → Repository → Fake.
  final auth = AuthRepository(FakeAuthDataSource());
  final applications = ApplicationsProvider(
    ApplicationRepository(source),
    auth,
  );
  // Libera el Provider al acabar cada prueba para no conservar escuchas.
  addTearDown(applications.dispose);
  // 2. await monta el árbol; .value usa el Provider ya creado para observarlo aquí.
  await tester.pumpWidget(
    MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: applications),
        ChangeNotifierProvider(create: (_) => AuthProvider(auth)),
        ChangeNotifierProvider(
          create: (_) => ExploreProvider(
            // ?? usa el Fake normal si no se entregó uno controlado.
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
  // 3. Avanza un frame para procesar suscripciones sin resolver puertas pendientes.
  await tester.pump();
  return applications;
}

/// Busca label, lo hace visible, simula un toque y espera los frames pendientes.
/// Recibe el controlador tester; no devuelve datos, solo avanza la interfaz.
Future<void> _tap(WidgetTester tester, String label) async {
  final finder = find.text(label);
  await tester.ensureVisible(finder);
  // pumpAndSettle procesa frames hasta estabilizar la UI, no completa las puertas
  // de los Fake: cada prueba debe llamar complete() explícitamente.
  await tester.pumpAndSettle();
  await tester.tap(finder);
  await tester.pumpAndSettle();
}

/// Lee del widget la selección actual: 0 Activas, 1 Completadas, 2 Cerradas.
int _selectedTab(WidgetTester tester) => tester
    .widget<ApplicationsTabSelector>(find.byType(ApplicationsTabSelector))
    .selected;

/// Registra pruebas de R3; cada callback prepara datos, actúa y comprueba
/// resultados.
void main() {
  // Evita descargar fuentes durante la suite; estas pruebas no necesitan Firebase.
  setUpAll(() => GoogleFonts.config.allowRuntimeFetching = false);

  // SECCIÓN: Confirmación y retiro
  // Prepara lista vacía; cancela/cierra/confirma, navega y retira.
  // Comprueba cero creaciones al cancelar, una al confirmar y cambio a Cerradas.
  testWidgets('cancelar o cerrar no crea; confirmar, navegar y retirarse', (
    tester,
  ) async {
    // 1. Sin solicitudes previas, se puede probar tanto cancelar como confirmar.
    final source = _ApplicationsFake([]);
    final provider = await _pump(tester, source);
    await tester.pumpAndSettle();
    // 2. Simula Cancelar y luego cierre exterior; ambos deben evitar create.
    await _tap(tester, 'Postularme ahora');
    await _tap(tester, 'Cancelar');
    expect(source.creations, 0);
    await _tap(tester, 'Postularme ahora');
    await tester.tapAt(const Offset(5, 5));
    await tester.pumpAndSettle();
    expect(source.creations, 0);
    await _tap(tester, 'Postularme ahora');
    await _tap(tester, 'Confirmar');
    // 3. Confirmar sí escribe y el stream lleva la solicitud a Activas.
    expect(source.creations, 1);
    expect(provider.activas.single.opportunityId, 'salud');
    await _tap(tester, 'Ver mi postulación');
    expect(find.byType(MyApplicationsScreen), findsOneWidget);
    expect(_selectedTab(tester), 0);
    // 4. Volver cancela el retiro; Sí, retirarme lo confirma y selecciona Cerradas.
    await _tap(tester, 'Retirarme');
    await _tap(tester, 'Volver');
    expect(provider.activas, hasLength(1));
    await _tap(tester, 'Retirarme');
    await _tap(tester, 'Sí, retirarme');
    expect(provider.activas, isEmpty);
    expect(provider.cerradas.single.estado, EstadoPostulacion.retirado);
    expect(_selectedTab(tester), 2);
    // 5. Comprueba navegación al detalle y regreso por la pila de pantallas.
    await _tap(tester, 'Ver detalle');
    expect(find.byType(OpportunityDetailScreen), findsOneWidget);
    expect(find.text('Postularme ahora'), findsOneWidget);
    await tester.tap(find.byTooltip('Volver'));
    await tester.pumpAndSettle();
    await tester.pageBack();
    await tester.pumpAndSettle();
    expect(find.byType(OpportunityDetailScreen), findsOneWidget);
  });

  // SECCIÓN: Bloqueo de envíos repetidos
  // Prepara puertas para carga, escritura y siguiente lista; simula doble toque.
  // Comprueba un solo diálogo y creación, y bloqueo hasta recibir el stream.
  testWidgets('bloquea pulsaciones durante carga, envío y espera del stream', (
    tester,
  ) async {
    // 1. .. es cascada: configura el Fake recién creado y conserva ese mismo objeto.
    final source = _ApplicationsFake([])..snapshotGate = Completer<void>();
    final provider = await _pump(tester, source);
    final opportunity = FakeSeed.opportunities().firstWhere(
      (o) => o.id == 'salud',
    );
    expect(provider.isLoading, isTrue);
    expect(await provider.postular(opportunity), isFalse);
    // 2. Libera la carga inicial; crea nuevas puertas para separar escritura y lista.
    source.snapshotGate?.complete();
    await tester.pumpAndSettle();
    source.snapshotGate = Completer<void>();
    source.createGate = Completer<void>();
    // 3. Dos toques seguidos antes de reconstruir no deben abrir dos diálogos.
    final apply = find.text('Postularme ahora');
    final applyPosition = tester.getCenter(apply);
    await tester.tapAt(applyPosition);
    await tester.tapAt(applyPosition);
    await tester.pumpAndSettle();
    expect(find.byType(AlertDialog), findsOneWidget);
    await _tap(tester, 'Confirmar');
    expect(source.creations, 1);
    expect(await provider.postular(opportunity), isFalse);
    // 4. Termina la escritura pero mantiene la lista retenida: aún debe bloquear.
    source.createGate?.complete();
    await tester.pumpAndSettle();
    expect(provider.isSubmitting('salud'), isTrue);
    expect(await provider.postular(opportunity), isFalse);
    expect(source.creations, 1);
    // 5. Ahora llega el snapshot y la UI puede ofrecer Ver mi postulación.
    source.snapshotGate?.complete();
    await tester.pumpAndSettle();
    expect(provider.activas, hasLength(1));
    expect(find.text('Ver mi postulación'), findsOneWidget);
  });

  // SECCIÓN: Errores de escritura
  // Prepara fallos de creación y retiro; los quita para volver a intentar.
  // Comprueba mensajes de error, datos/pestaña conservados y reintento exitoso.
  testWidgets(
    'errores de guardar y retirar permiten reintentar sin fingir éxito',
    (tester) async {
      // 1. Fuerza error al guardar y comprueba que no aparezca una activa falsa.
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
      // 2. Recupera escritura; luego fuerza fallo de retiro para conservar Activas.
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
      // 3. Recupera retiro y comprueba que la misma acción puede completarse.
      source.failWithdraw = false;
      await _tap(tester, 'Retirarme');
      await _tap(tester, 'Sí, retirarme');
      expect(provider.cerradas, hasLength(1));
    },
  );

  // SECCIÓN: Estados del detalle
  // Prepara un stream manual; emite error, lista vacía y convocatorias.
  // Comprueba carga, reintento, no disponible y botón de postulación.
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
      // 1. Emite fallo tras la carga inicial y acciona Reintentar.
      opportunities.changes.addError(StateError('Sin conexión'));
      await tester.pumpAndSettle();
      expect(find.text('Reintentar'), findsOneWidget);
      await tester.tap(find.text('Reintentar'));
      await tester.pump();
      expect(find.byType(LoadingView), findsOneWidget);
      // 2. Lista vacía significa convocatoria ausente, no carga interminable.
      opportunities.changes.add([]);
      await tester.pumpAndSettle();
      expect(
        find.text('Esta convocatoria ya no está disponible.'),
        findsOneWidget,
      );
      // 3. Un evento posterior con datos reconstruye el detalle automáticamente.
      opportunities.changes.add(FakeSeed.opportunities());
      await tester.pumpAndSettle();
      expect(find.text('Postularme ahora'), findsOneWidget);
    },
  );

  // SECCIÓN: Estados de Mis postulaciones
  // Prepara carga demorada y fallo de lectura; reintenta y recorre las pestañas.
  // Comprueba indicador, error y mensaje vacío específico de cada pestaña.
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
      // 1. Fuerza una suscripción fallida; retry debe mostrar el error del Provider.
      source.failWatch = true;
      provider.retry();
      await tester.pumpAndSettle();
      expect(find.text('No pudimos cargar tus postulaciones.'), findsOneWidget);
      source.failWatch = false;
      await _tap(tester, 'Reintentar');
      // 2. Recupera la lectura y verifica los tres grupos vacíos por sus etiquetas.
      for (final tab in ['Activas', 'Completadas', 'Cerradas']) {
        await _tap(tester, tab);
        // Aunque no haya solicitudes, las tres pestañas conservan su cero visible.
        expect(
          find.descendant(
            of: find.byType(ApplicationsTabSelector),
            matching: find.text('0'),
          ),
          findsNWidgets(3),
        );
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

  // SECCIÓN: Estados y getters
  // Prepara una solicitud por cada estado del modelo e intenta retirar enCurso.
  // Comprueba agrupación completa, horas/nivel/progreso y ausencia del botón de retiro.
  testWidgets(
    'conserva todos los estados y getters; enCurso no permite retiro',
    (tester) async {
      final base = FakeSeed.applications().first;
      // 1. Copia el ejemplo una vez por estado para no perder grupos del modelo.
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
      // Los tres grupos tienen datos: sus contadores positivos también se dibujan.
      for (final count in [
        provider.activas.length,
        provider.completadas.length,
        provider.cerradas.length,
      ]) {
        expect(count, greaterThan(0));
        expect(
          find.descendant(
            of: find.byType(ApplicationsTabSelector),
            matching: find.text('$count'),
          ),
          findsOneWidget,
        );
      }
      final inProgress = records.firstWhere(
        (a) => a.estado == EstadoPostulacion.enCurso,
      );
      // 2. Comprueba la restricción en lógica y luego en una tarjeta aislada.
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

  // SECCIÓN: Primera coincidencia y pestaña predeterminada
  // Prepara dos solicitudes de la misma convocatoria y otra más reciente.
  // Comprueba el orden, la primera coincidencia y el regreso; luego simula
  // una acción ya capturada que se ejecuta mientras retry ha vaciado la lista.
  testWidgets(
    'elige la primera coincidencia y usa Activas si ya no hay ninguna',
    (tester) async {
      final base = FakeSeed.applications().first;
      final older = Application.fromMap('anterior', {
        ...base.toMap(),
        'estado': EstadoPostulacion.completado.name,
        'creadaEn': DateTime(2026, 1, 1),
      });
      final first = Application.fromMap('primera', {
        ...base.toMap(),
        'estado': EstadoPostulacion.rechazado.name,
        'creadaEn': DateTime(2026, 1, 2),
      });
      final unrelated = Application.fromMap('otra', {
        ...FakeSeed.applications()[1].toMap(),
        'creadaEn': DateTime(2026, 1, 3),
      });
      final source = _ApplicationsFake([older, first, unrelated]);
      final provider = await _pump(
        tester,
        source,
        home: OpportunityDetailScreen(opportunityId: base.opportunityId),
      );
      await tester.pumpAndSettle();
      expect(provider.applications.map((a) => a.id), [
        'otra',
        'primera',
        'anterior',
      ]);
      await _tap(tester, 'Ver mi postulación');
      expect(_selectedTab(tester), 2);
      await tester.pageBack();
      await tester.pumpAndSettle();
      expect(find.byType(OpportunityDetailScreen), findsOneWidget);

      final openApplications = tester
          .widget<ApplyBar>(find.byType(ApplyBar))
          .onApply;
      expect(openApplications, isNotNull);
      source.snapshotGate = Completer<void>();
      provider.retry();
      expect(provider.applications, isEmpty);
      openApplications?.call();
      source.snapshotGate?.complete();
      await tester.pumpAndSettle();
      expect(_selectedTab(tester), 0);
      await tester.pageBack();
      await tester.pumpAndSettle();
      expect(find.byType(OpportunityDetailScreen), findsOneWidget);
    },
  );

  // SECCIÓN: Tamaño y navegación
  // Prepara pantalla 360 × 800 y texto 1.3 con completada y rechazada.
  // Desplaza y navega; comprueba pestaña, motivo visible y ausencia de excepciones.
  testWidgets('R3 cabe a 360 px con texto 1.3 y navega a Completadas/Cerradas', (
    tester,
  ) async {
    // 1. Fija medidas y registra limpieza para no afectar las siguientes pruebas.
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
        home: OpportunityDetailScreen(opportunityId: application.opportunityId),
      );
      await tester.pumpAndSettle();

      // 2. Recorre el detalle para construir también los bloques fuera de pantalla.
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

      // Ver detalle ocupa todo el ancho de sus acciones, también con texto 1.3.
      final detailButton = find.ancestor(
        of: find.text('Ver detalle'),
        matching: find.byType(InkWell),
      );
      expect(
        tester.getSize(detailButton).width,
        tester.getSize(find.byType(ApplicationActions)).width,
      );
      expect(tester.getSize(detailButton).height, greaterThanOrEqualTo(48));

      // 3. Detecta errores de render como overflow y verifica el motivo de cierre.
      expect(tester.takeException(), isNull);
      if (state.esCerrada) {
        expect(find.text('Cupos completos'), findsOneWidget);
      }
      await tester.pumpWidget(const SizedBox.shrink());
    }
  });
  // SECCIÓN: Humo del recorrido R3
  // Prepara app Fake sin sesión; registra, busca, postula y entra como organización.
  // Comprueba Activas y llegada al panel en construcción; no prueba aceptación ni
  // avisos.
  testWidgets(
    'humo Fake: registro, explorar, R3 y entrada al panel de organización',
    (tester) async {
      // 1. Monta el recorrido completo con dependencias Fake y registro nuevo.
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
      // 2. Busca y filtra antes de contar los tres toques de R3.
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
      // Los tres toques de R3 incluyen abrir la tarjeta desde el feed.
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
      // 3. Regresa, cierra sesión y comprueba acceso al panel de organización.
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
