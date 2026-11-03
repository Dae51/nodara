import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'package:nodara/core/di/app_dependencies.dart';
import 'package:nodara/data/datasources/fake/fake_seed.dart';
import 'package:nodara/features/auth/auth_provider.dart';
import 'package:nodara/features/organization/opportunity_form_screen.dart';
import 'package:nodara/features/organization/org_home_screen.dart';
import 'package:nodara/features/organization/organization_provider.dart';

Widget _buildTestApp({
  required AppDependencies dependencies,
  required Widget child,
}) {
  return MultiProvider(
    providers: [
      Provider<AppDependencies>.value(value: dependencies),
      ChangeNotifierProvider(create: (_) => AuthProvider(dependencies.auth)),
    ],
    child: MaterialApp(home: child),
  );
}

void main() {
  testWidgets('El formulario no deja guardar sin los campos obligatorios', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(800, 1600);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final dependencies = AppDependencies.fake();
    await dependencies.auth.signIn(email: 'org@nodara.app', password: '123456');

    final orgProvider = OrganizationProvider(
      opportunities: dependencies.opportunities,
      orgId: FakeSeed.orgFuturoId,
    );

    await tester.pumpWidget(
      _buildTestApp(
        dependencies: dependencies,
        child: ChangeNotifierProvider.value(
          value: orgProvider,
          child: const OpportunityFormScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    final botonGuardar = find.widgetWithText(
      FilledButton,
      'Publicar convocatoria',
    );
    await tester.tap(botonGuardar);
    await tester.pumpAndSettle();

    expect(find.text('Ingresa un título para la convocatoria'), findsOneWidget);
    expect(find.text('Ingresa una descripción'), findsOneWidget);

    orgProvider.dispose();
  });

  testWidgets('El formulario permite crear una convocatoria válida', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(800, 1600);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final dependencies = AppDependencies.fake();
    await dependencies.auth.signIn(email: 'org@nodara.app', password: '123456');

    final orgProvider = OrganizationProvider(
      opportunities: dependencies.opportunities,
      orgId: FakeSeed.orgFuturoId,
    );

    await tester.pumpWidget(
      _buildTestApp(
        dependencies: dependencies,
        child: ChangeNotifierProvider.value(
          value: orgProvider,
          child: const OpportunityFormScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.enterText(
      find.widgetWithText(TextFormField, 'Título de la convocatoria *'),
      'Limpieza Comunitaria del Parque',
    );
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Descripción *'),
      'Actividad voluntaria para revitalizar las áreas verdes del parque comunal.',
    );

    final botonGuardar = find.widgetWithText(
      FilledButton,
      'Publicar convocatoria',
    );
    await tester.tap(botonGuardar);
    await tester.pumpAndSettle();

    expect(
      orgProvider.opportunities.any(
        (o) => o.titulo == 'Limpieza Comunitaria del Parque',
      ),
      isTrue,
    );

    orgProvider.dispose();
  });

  testWidgets(
    'Panel de organización muestra las convocatorias y cupos ocupados',
    (tester) async {
      final dependencies = AppDependencies.fake();
      await dependencies.auth.signIn(
        email: 'org@nodara.app',
        password: '123456',
      );

      await tester.pumpWidget(
        _buildTestApp(dependencies: dependencies, child: const OrgHomeScreen()),
      );
      await tester.pumpAndSettle();

      expect(find.textContaining('Panel de organización'), findsOneWidget);
      expect(
        find.text('Tutorías Universitarias de Matemáticas y Apoyo Escolar'),
        findsOneWidget,
      );
      expect(find.textContaining('cupos ocupados'), findsWidgets);
      expect(find.text('Editar'), findsOneWidget);
      expect(find.text('Postulantes'), findsOneWidget);
    },
  );
}
