import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:nodara/main.dart';
import 'package:nodara/theme/app_colors.dart';
import 'package:nodara/widgets/opportunity_card.dart';

Future<void> _goToHome(WidgetTester tester) async {
  await tester.pumpWidget(const NodaraApp());
  await tester.pumpAndSettle();
  await tester.tap(find.text('Empezar ahora'));
  await tester.pumpAndSettle();
}

Finder _favoritedHeart() => find.byWidgetPredicate(
      (w) => w is Icon && w.color == AppColors.error,
    );

void main() {
  setUpAll(() {
    // Avoid network font fetching during tests.
    GoogleFonts.config.allowRuntimeFetching = false;
  });

  testWidgets('onboarding navega al feed y la búsqueda filtra',
      (WidgetTester tester) async {
    await _goToHome(tester);

    expect(find.text('¡Hola, Sofía!'), findsOneWidget);
    expect(find.text('Oportunidades Destacadas'), findsOneWidget);
    expect(find.text('Tutorías de Matemáticas y Ciencias'), findsOneWidget);

    await tester.enterText(find.byType(TextField), 'EcoVida');
    await tester.pumpAndSettle();

    expect(
      find.text('Jornada de Reforestación y Limpieza de Cuencas'),
      findsOneWidget,
    );
    expect(find.text('Tutorías de Matemáticas y Ciencias'), findsNothing);
  });

  testWidgets('los chips filtran por categoría y el favorito alterna',
      (WidgetTester tester) async {
    await _goToHome(tester);

    await tester.tap(find.text('Educación'));
    await tester.pumpAndSettle();

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
      (WidgetTester tester) async {
    await _goToHome(tester);

    await tester.enterText(find.byType(TextField), 'Cruz');
    await tester.pumpAndSettle();

    await tester.tap(
      find.text('Campaña de Salud y Prevención Dental Comunitaria'),
    );
    await tester.pumpAndSettle();

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
}
