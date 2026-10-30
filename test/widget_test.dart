import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:nodara/core/di/app_dependencies.dart';
import 'package:nodara/features/explore/widgets/opportunity_card.dart';
import 'package:nodara/main.dart';
import 'package:nodara/theme/app_colors.dart';

/// Arranca la app con DataSources Fake (estado limpio en cada test).
Future<void> _pumpApp(
  WidgetTester tester, {
  bool signedIn = true,
  bool onboardingVisto = false,
}) async {
  await tester.pumpWidget(
    NodaraApp(
      dependencies: AppDependencies.fake(
        startSignedIn: signedIn,
        onboardingVisto: onboardingVisto,
      ),
    ),
  );
  await tester.pumpAndSettle();
}

Future<void> _tap(WidgetTester tester, Finder finder) async {
  await tester.ensureVisible(finder);
  await tester.pumpAndSettle();
  await tester.tap(finder);
  await tester.pumpAndSettle();
}

Finder _field(String label) => find.widgetWithText(TextFormField, label);

Finder _favoritedHeart() => find.byWidgetPredicate(
      (w) => w is Icon && w.color == AppColors.error,
    );

void main() {
  setUpAll(() {
    // Evita descargar fuentes durante los tests.
    GoogleFonts.config.allowRuntimeFetching = false;
  });

  group('Autenticación (F1)', () {
    testWidgets('sin sesión muestra onboarding y permite iniciar sesión',
        (tester) async {
      await _pumpApp(tester, signedIn: false);

      expect(find.text('Empezar ahora'), findsOneWidget);
      await _tap(tester, find.text('Iniciar sesión'));

      expect(find.text('Inicia sesión'), findsOneWidget);
      await tester.enterText(_field('Correo'), 'sofia@nodara.app');
      await tester.enterText(_field('Contraseña'), '123456');
      await _tap(tester, find.text('Ingresar'));

      expect(find.text('¡Hola, Sofía!'), findsOneWidget);
    });

    testWidgets('el onboarding ya visto no se repite', (tester) async {
      await _pumpApp(tester, signedIn: false, onboardingVisto: true);

      expect(find.text('Empezar ahora'), findsNothing);
      expect(find.text('Inicia sesión'), findsOneWidget);
    });

    testWidgets('login con credenciales incorrectas muestra el error',
        (tester) async {
      await _pumpApp(tester, signedIn: false, onboardingVisto: true);

      await tester.enterText(_field('Correo'), 'nadie@nodara.app');
      await tester.enterText(_field('Contraseña'), '123456');
      await _tap(tester, find.text('Ingresar'));

      expect(find.text('Correo o contraseña incorrectos.'), findsOneWidget);
    });

    testWidgets('el registro valida campos y crea la cuenta', (tester) async {
      await _pumpApp(tester, signedIn: false);
      await _tap(tester, find.text('Empezar ahora'));

      expect(find.text('Crea tu cuenta'), findsOneWidget);
      await _tap(tester, find.text('Crear cuenta'));
      expect(find.text('Ingresa tu nombre.'), findsOneWidget);
      expect(find.text('Ingresa tu correo.'), findsOneWidget);

      await tester.enterText(_field('Nombre'), 'Ana');
      await tester.enterText(_field('Correo'), 'ana@correo.com');
      await tester.enterText(_field('Contraseña'), 'secreta1');
      await _tap(tester, find.text('Crear cuenta'));

      expect(find.text('¡Hola, Ana!'), findsOneWidget);
    });

    testWidgets('una organización entra a su panel y puede cerrar sesión',
        (tester) async {
      await _pumpApp(tester, signedIn: false, onboardingVisto: true);

      await tester.enterText(_field('Correo'), 'org@nodara.app');
      await tester.enterText(_field('Contraseña'), '123456');
      await _tap(tester, find.text('Ingresar'));
      expect(find.textContaining('Panel de organización'), findsOneWidget);

      await _tap(tester, find.byTooltip('Cerrar sesión'));
      expect(find.text('Inicia sesión'), findsOneWidget);
    });
  });

  group('Voluntario', () {
    testWidgets('el feed carga y la búsqueda filtra', (tester) async {
      await _pumpApp(tester);

      expect(find.text('¡Hola, Sofía!'), findsOneWidget);
      expect(find.text('Oportunidades Destacadas'), findsOneWidget);

      // El feed se ordena por fecha de cierre: la primera tarjeta es la
      // campaña de salud (cierra antes). La lista es perezosa
      // (SliverList.builder), así que solo validamos lo que está en pantalla.
      expect(
        find.text('Campaña de Salud y Prevención Dental Comunitaria'),
        findsOneWidget,
      );

      await tester.enterText(find.byType(TextField), 'EcoVida');
      await tester.pumpAndSettle();

      expect(
        find.text('Jornada de Reforestación y Limpieza de Cuencas'),
        findsOneWidget,
      );
      expect(find.text('Tutorías de Matemáticas y Ciencias'), findsNothing);
    });

    testWidgets('los chips filtran por causa y el favorito alterna',
        (tester) async {
      await _pumpApp(tester);

      await _tap(tester, find.text('Educación'));

      expect(find.text('Tutorías de Matemáticas y Ciencias'), findsOneWidget);
      expect(
        find.text('Jornada de Reforestación y Limpieza de Cuencas'),
        findsNothing,
      );

      final card = find.byType(OpportunityCard);
      expect(card, findsOneWidget);
      expect(_favoritedHeart(), findsNothing);

      final heart = find.descendant(
        of: card,
        matching: find.byWidgetPredicate(
          (w) => w is Icon && w.color == AppColors.onSurface,
        ),
      );
      expect(heart, findsOneWidget);

      await tester.tap(heart);
      await tester.pumpAndSettle();
      expect(_favoritedHeart(), findsOneWidget);
    });

    testWidgets('postularse en el detalle agrega la postulación',
        (tester) async {
      await _pumpApp(tester);

      await tester.enterText(find.byType(TextField), 'Cruz');
      await tester.pumpAndSettle();

      await _tap(
        tester,
        find.text('Campaña de Salud y Prevención Dental Comunitaria'),
      );

      expect(find.text('Postularme ahora'), findsOneWidget);
      expect(find.text('Requisitos para postular'), findsOneWidget);

      await tester.tap(find.text('Postularme ahora'));
      await tester.pumpAndSettle();

      expect(find.text('¡Ya estás postulado!'), findsOneWidget);

      await tester.tap(find.byIcon(Icons.arrow_back));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Postulaciones'));
      await tester.pumpAndSettle();

      expect(
        find.text('Campaña de Salud y Prevención Dental Comunitaria'),
        findsOneWidget,
      );
    });

    testWidgets('las horas del perfil se calculan de las completadas',
        (tester) async {
      await _pumpApp(tester);

      await tester.tap(find.text('Perfil'));
      await tester.pumpAndSettle();

      // 20 + 25 horas de las dos postulaciones completadas del seed.
      expect(find.text('45 / 80 hrs'), findsOneWidget);
    });
  });
}
