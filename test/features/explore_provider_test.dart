import 'package:flutter_test/flutter_test.dart';
import 'package:nodara/data/datasources/fake/fake_opportunity_data_source.dart';
import 'package:nodara/data/models/opportunity.dart';
import 'package:nodara/data/repositories/opportunity_repository.dart';
import 'package:nodara/features/explore/explore_provider.dart';

void main() {
  test('ExploreProvider aplica formato, horas y departamento', () async {
    final provider = ExploreProvider(
      OpportunityRepository(FakeOpportunityDataSource()),
    );

    // Espera la primera emisión del stream en memoria.
    await Future<void>.delayed(Duration.zero);

    expect(provider.isLoading, isFalse);
    expect(provider.filtered.length, 3);

    provider.toggleFormato(Formato.jornada);
    expect(
      provider.filtered.map((o) => o.id),
      containsAll(['reforestacion', 'salud']),
    );
    expect(provider.filtered.length, 2);

    provider.clearFilters();
    provider.setHoras(FranjaHoras.masDe20);
    expect(provider.filtered, isEmpty);

    provider.clearFilters();
    provider.setDepartamento('La Libertad');
    expect(provider.filtered, isEmpty);

    provider.clearFilters();
    expect(provider.filtered.length, 3);

    provider.dispose();
  });
}
