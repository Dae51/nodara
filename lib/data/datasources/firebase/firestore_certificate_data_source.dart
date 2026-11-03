import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:nodara/data/datasources/certificate_data_source.dart';
import 'package:nodara/data/datasources/firebase/firestore_utils.dart';
import 'package:nodara/data/models/certificate.dart';

/// Guarda reportes inmutables; el código es también el ID en Firestore.
class FirestoreCertificateDataSource implements CertificateDataSource {
  FirestoreCertificateDataSource({FirebaseFirestore? firestore})
    : _db = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _db;

  @override
  Future<void> create(Certificate certificate) async {
    final reference = _db.collection('certificates').doc(certificate.codigo);
    // La transacción evita reemplazar un reporte si se repite un código.
    await _db.runTransaction<void>((transaction) async {
      final existing = await transaction.get(reference);
      if (existing.exists) {
        throw StateError('El código de este certificado ya existe.');
      }
      transaction.set(reference, certificate.toMap());
    });
  }

  @override
  Future<Certificate?> getByCodigo(String codigo) async {
    if (RegExp(r'^NOD-[A-HJ-NP-Z2-9]{4}-[A-HJ-NP-Z2-9]{4}$').hasMatch(codigo) ==
        false) {
      return null;
    }
    final snapshot = await _db
        .collection('certificates')
        .doc(codigo)
        .get(const GetOptions(source: Source.server));
    final data = snapshot.data();
    return data == null
        ? null
        : Certificate.fromMap(snapshot.id, fromFirestore(data));
  }
}
