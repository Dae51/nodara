import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:nodara/core/di/app_dependencies.dart';
import 'package:nodara/data/datasources/fake/fake_seed.dart';
import 'package:nodara/features/applicants/applicants_screen.dart';
import 'package:nodara/data/models/application.dart';

void main() {
  testWidgets(
    'Postulantes permite aceptar desde su diálogo y actualiza estado',
    (tester) async {
      final dependencies = AppDependencies.fake();
      await dependencies.auth.signIn(
        email: 'org@nodara.app',
        password: '123456',
      );
      final opportunity = FakeSeed.opportunities().first;
      await dependencies.applications.cambiarEstado(
        applicationId: FakeSeed.applications().first.id,
        estado: EstadoPostulacion.pendiente,
      );
      await tester.pumpWidget(
        Provider.value(
          value: dependencies,
          child: MaterialApp(
            home: ApplicantsScreen(opportunityId: opportunity.id),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('Postulantes'), findsOneWidget);
      await tester.tap(find.text('Aceptar'));
      await tester.pumpAndSettle();
      expect(find.text('¿Aceptar postulación?'), findsOneWidget);
      await tester.tap(find.widgetWithText(FilledButton, 'Aceptar').last);
      await tester.pumpAndSettle();
      expect(find.text('Seleccionado / En curso'), findsOneWidget);
      expect(find.text('Respuesta guardada y aviso enviado.'), findsOneWidget);
    },
  );

  testWidgets(
    'Convocatoria ajena no muestra postulantes de otra organización',
    (tester) async {
      final dependencies = AppDependencies.fake();
      await dependencies.auth.signIn(
        email: 'org@nodara.app',
        password: '123456',
      );
      await tester.pumpWidget(
        Provider.value(
          value: dependencies,
          child: const MaterialApp(
            home: ApplicantsScreen(opportunityId: 'reforestacion'),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(
        find.text('No encontramos esta convocatoria en tu organización.'),
        findsOneWidget,
      );
      expect(find.text('Aceptar'), findsNothing);
    },
  );
}
