import 'package:nodara/data/models/opportunity.dart';

/// Contrato de acceso a `opportunities`.
abstract class OpportunityDataSource {
  /// Todas las oportunidades activas, en tiempo real.
  Stream<List<Opportunity>> watchActive();

  /// Oportunidades publicadas por una organización (panel org).
  Stream<List<Opportunity>> watchByOrg(String orgId);

  /// Crea la oportunidad y devuelve su ID.
  Future<String> create(Opportunity opportunity);

  Future<void> update(Opportunity opportunity);

  /// Suma (o resta, con delta negativo) cupos ocupados de forma atómica.
  /// En Firestore: `FieldValue.increment(delta)`.
  Future<void> incrementCuposOcupados(String opportunityId, int delta);
}
