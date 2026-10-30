import 'dart:math';

import 'package:nodara/data/datasources/certificate_data_source.dart';
import 'package:nodara/data/models/certificate.dart';

class CertificateRepository {
  CertificateRepository(this._dataSource, {Random? random})
      : _random = random ?? Random.secure();

  final CertificateDataSource _dataSource;
  final Random _random;

  static const _alfabeto = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789';

  /// Código legible tipo `NOD-7F3K-92QA` (sin 0/O ni 1/I para evitar
  /// confusiones al escribirlo).
  String generarCodigo() {
    String bloque() => List.generate(
          4,
          (_) => _alfabeto[_random.nextInt(_alfabeto.length)],
        ).join();
    return 'NOD-${bloque()}-${bloque()}';
  }

  Future<void> guardar(Certificate certificate) =>
      _dataSource.create(certificate);

  Future<Certificate?> validar(String codigo) =>
      _dataSource.getByCodigo(codigo.trim().toUpperCase());
}
