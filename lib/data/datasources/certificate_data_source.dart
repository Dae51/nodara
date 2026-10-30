import 'package:nodara/data/models/certificate.dart';

/// Contrato de acceso a `certificates/{codigo}`.
abstract class CertificateDataSource {
  Future<void> create(Certificate certificate);

  Future<Certificate?> getByCodigo(String codigo);
}
