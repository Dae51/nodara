import 'package:nodara/data/models/application.dart';

/// Contrato de acceso a `applications`.
abstract class ApplicationDataSource {
  Stream<List<Application>> watchByUser(String userId);

  /// Postulaciones a las oportunidades de una organización (panel org).
  Stream<List<Application>> watchByOrg(String orgId);

  /// Crea la postulación y devuelve su ID.
  Future<String> create(Application application);

  Future<void> updateEstado({
    required String applicationId,
    required EstadoPostulacion estado,
    int? horasAcreditadas,
    String? motivo,
  });
}
