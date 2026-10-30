import 'package:nodara/data/datasources/certificate_data_source.dart';
import 'package:nodara/data/models/certificate.dart';

class FakeCertificateDataSource implements CertificateDataSource {
  final Map<String, Certificate> _byCodigo = {};

  @override
  Future<void> create(Certificate certificate) async {
    _byCodigo[certificate.codigo] = certificate;
  }

  @override
  Future<Certificate?> getByCodigo(String codigo) async => _byCodigo[codigo];
}
