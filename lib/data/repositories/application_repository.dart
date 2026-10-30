import 'package:nodara/data/datasources/application_data_source.dart';
import 'package:nodara/data/models/app_user.dart';
import 'package:nodara/data/models/application.dart';
import 'package:nodara/data/models/opportunity.dart';

class ApplicationRepository {
  ApplicationRepository(this._dataSource);

  final ApplicationDataSource _dataSource;

  /// Postulaciones del voluntario, más recientes primero.
  Stream<List<Application>> watchMine(String userId) =>
      _dataSource.watchByUser(userId).map(_sortByDate);

  /// Postulaciones recibidas por una organización (panel org, F3).
  Stream<List<Application>> watchForOrg(String orgId) =>
      _dataSource.watchByOrg(orgId).map(_sortByDate);

  /// Crea una postulación `pendiente` copiando los datos de la oportunidad
  /// que se muestran en la tarjeta.
  Future<String> postular({
    required Opportunity opportunity,
    required AppUser user,
  }) {
    final ahora = DateTime.now();
    return _dataSource.create(
      Application(
        id: '',
        opportunityId: opportunity.id,
        oportunidadTitulo: opportunity.tituloTarjeta,
        orgId: opportunity.orgId,
        orgNombre: opportunity.orgNombre,
        userId: user.uid,
        causa: opportunity.causa,
        imagenUrl: opportunity.imagenUrl,
        horario: opportunity.horario,
        horasEstimadas: opportunity.horasEstimadas,
        estado: EstadoPostulacion.pendiente,
        creadaEn: ahora,
        actualizadaEn: ahora,
      ),
    );
  }

  Future<void> retirar(Application application) => _dataSource.updateEstado(
        applicationId: application.id,
        estado: EstadoPostulacion.retirado,
      );

  /// Cambio de estado hecho por la organización (F3).
  Future<void> cambiarEstado({
    required String applicationId,
    required EstadoPostulacion estado,
    int? horasAcreditadas,
    String? motivo,
  }) =>
      _dataSource.updateEstado(
        applicationId: applicationId,
        estado: estado,
        horasAcreditadas: horasAcreditadas,
        motivo: motivo,
      );

  static List<Application> _sortByDate(List<Application> list) =>
      [...list]..sort((a, b) => b.creadaEn.compareTo(a.creadaEn));
}
