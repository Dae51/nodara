import 'package:nodara/data/datasources/opportunity_data_source.dart';
import 'package:nodara/data/models/opportunity.dart';

class OpportunityRepository {
  OpportunityRepository(this._dataSource);

  final OpportunityDataSource _dataSource;

  /// Solo las vigentes, ordenadas por fecha de cierre (las que cierran
  /// antes primero).
  Stream<List<Opportunity>> watchVigentes() =>
      _dataSource.watchActive().map((list) {
        final ahora = DateTime.now();
        final vigentes = list.where((o) => o.estaVigente(ahora)).toList()
          ..sort((a, b) => a.cierreInscripcion.compareTo(b.cierreInscripcion));
        return vigentes;
      });

  Stream<List<Opportunity>> watchByOrg(String orgId) =>
      _dataSource.watchByOrg(orgId);

  Future<String> publicar(Opportunity opportunity) =>
      _dataSource.create(opportunity);

  Future<void> actualizar(Opportunity opportunity) =>
      _dataSource.update(opportunity);

  /// Al aceptar a un voluntario se ocupa un cupo; al retirarse se libera.
  Future<void> ocuparCupo(String opportunityId) =>
      _dataSource.incrementCuposOcupados(opportunityId, 1);

  Future<void> liberarCupo(String opportunityId) =>
      _dataSource.incrementCuposOcupados(opportunityId, -1);
}
