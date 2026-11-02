import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:nodara/data/datasources/application_data_source.dart';
import 'package:nodara/data/datasources/firebase/firestore_utils.dart';
import 'package:nodara/data/models/application.dart';

/// Implementación Firestore de las postulaciones.
///
/// El cambio de estado se ejecuta en una transacción para conservar
/// el historial cuando dos coordinadores actúan al mismo tiempo. La validación
/// final de permisos vive también en firestore.rules.
class FirebaseApplicationDataSource implements ApplicationDataSource {
  FirebaseApplicationDataSource({FirebaseFirestore? firestore})
    : _db = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _db;

  CollectionReference<Map<String, dynamic>> get _applications =>
      _db.collection('applications');

  @override
  Stream<List<Application>> watchByUser(String userId) => _applications
      .where('userId', isEqualTo: userId)
      .snapshots()
      .map(
        (snapshot) => snapshot.docs
            .map(
              (doc) => Application.fromMap(doc.id, fromFirestore(doc.data())),
            )
            .toList(),
      );

  @override
  Stream<List<Application>> watchByOrg(String orgId) => _applications
      .where('orgId', isEqualTo: orgId)
      .snapshots()
      .map(
        (snapshot) => snapshot.docs
            .map(
              (doc) => Application.fromMap(doc.id, fromFirestore(doc.data())),
            )
            .toList(),
      );

  @override
  Future<String> create(Application application) async {
    final reference = await _applications.add(application.toMap());
    return reference.id;
  }

  @override
  Future<void> updateEstado({
    required String applicationId,
    required EstadoPostulacion estado,
    int? horasAcreditadas,
    String? motivo,
  }) async {
    final reference = _applications.doc(applicationId);
    await _db.runTransaction((transaction) async {
      final snapshot = await transaction.get(reference);
      final data = snapshot.data();
      if (!snapshot.exists || data == null) {
        throw StateError('Postulación no encontrada.');
      }
      final current = Application.fromMap(snapshot.id, fromFirestore(data));
      if (!current.estado.siguientes.contains(estado)) {
        throw StateError('Transición de estado no permitida.');
      }
      final change = ApplicationStatusChange(
        estado: estado,
        en: DateTime.now(),
        actorId: FirebaseAuth.instance.currentUser?.uid ?? '',
        motivo: motivo,
      );
      transaction.update(reference, {
        'estado': estado.name,
        // Retirarse no debe modificar las horas ni borrar datos anteriores.
        if (horasAcreditadas != null && estado != EstadoPostulacion.retirado)
          'horasAcreditadas': horasAcreditadas,
        'motivo': ?motivo,
        'actualizadaEn': FieldValue.serverTimestamp(),
        'historial': FieldValue.arrayUnion([change.toMap()]),
      });
    });
  }
}
