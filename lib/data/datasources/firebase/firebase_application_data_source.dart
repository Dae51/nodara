// Fuente Firestore inyectada en ApplicationRepository por AppDependencies.firebase().
// Guía de estudio R3: Javier Alejandro Paniagua Morán · carné 20245194.
// Consultas, creación y transacción vienen de la base; R3 evitó borrar opcionales y
// modificar horas al retirar.
// Referencia del aporte: docs/bitacora/javier.md y commit f0b6416.
// Índice: watchByUser; watchByOrg; create; updateEstado.

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
  /// Acepta firestore opcional para inyección; ? permite null y ?? usa la instancia
  /// global.
  FirebaseApplicationDataSource({FirebaseFirestore? firestore})
    : _db = firestore ?? FirebaseFirestore.instance;

  // final conserva la conexión elegida por el constructor.
  final FirebaseFirestore _db;

  /// Getter que referencia la colección applications sin leerla todavía.
  CollectionReference<Map<String, dynamic>> get _applications =>
      _db.collection('applications');

  // SECCIÓN: Actualización mediante stream
  /// Recibe userId y emite su lista inicial y posteriores cambios de Firestore.
  /// Repository.watchMine la ordena; el Provider escucha y notifica a la pantalla.
  @override
  Stream<List<Application>> watchByUser(String userId) => _applications
      // 1. Filtra por dueño; snapshots mantiene la escucha y map convierte cada lista.
      .where('userId', isEqualTo: userId)
      .snapshots()
      .map(
        // 2. fromFirestore adapta valores; Application.fromMap construye modelos.
        (snapshot) => snapshot.docs
            .map(
              (doc) => Application.fromMap(doc.id, fromFirestore(doc.data())),
            )
            .toList(),
      );

  /// Recibe orgId y emite postulaciones de esa organización para watchForOrg.
  /// Implementa el contrato compartido; no es el filtro de Mis postulaciones.
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

  // SECCIÓN: Guardado de postulación
  /// Recibe la Application preparada por el Repository y devuelve el ID creado.
  /// Los errores suben al Provider; aquí no se controla la interfaz.
  @override
  Future<String> create(Application application) async {
    // 1. toMap serializa el modelo; add crea un documento con ID automático.
    // 2. await espera la escritura para devolver su referencia; no hay context
    // ni mounted en esta capa. Esta operación no comprueba duplicados por sí sola.
    final reference = await _applications.add(application.toMap());
    return reference.id;
  }

  // SECCIÓN: Transacción de cambio de estado
  /// Recibe applicationId y estado obligatorios (required), más horas/motivo
  /// opcionales.
  /// Espera la transacción sin devolver datos; lanza error si falta el documento
  /// o la transición no está permitida. Repository.retirar pide estado retirado.
  @override
  Future<void> updateEstado({
    required String applicationId,
    required EstadoPostulacion estado,
    int? horasAcreditadas,
    String? motivo,
  }) async {
    final reference = _applications.doc(applicationId);
    // 1. La transacción relee ante conflictos; su callback puede ejecutarse de nuevo.
    await _db.runTransaction((transaction) async {
      // 2. await obtiene el estado actual antes de decidir si se permite el cambio.
      final snapshot = await transaction.get(reference);
      final data = snapshot.data();
      if (!snapshot.exists || data == null) {
        throw StateError('Postulación no encontrada.');
      }
      final current = Application.fromMap(snapshot.id, fromFirestore(data));
      // 3. siguientes es un getter del modelo que define las transiciones válidas.
      if (!current.estado.siguientes.contains(estado)) {
        throw StateError('Transición de estado no permitida.');
      }
      // 4. Registra estado, fecha local y actor; ?. y ?? usan UID vacío si no hay
      // sesión. Los permisos finales los decide Firestore, no este valor local.
      final change = ApplicationStatusChange(
        estado: estado,
        en: DateTime.now(),
        actorId: FirebaseAuth.instance.currentUser?.uid ?? '',
        motivo: motivo,
      );
      // 5. Actualiza estado e historial juntos. No modifica cupos ni crea avisos.
      transaction.update(reference, {
        'estado': estado.name,
        // Retirarse no debe modificar las horas ni borrar datos anteriores.
        if (horasAcreditadas != null && estado != EstadoPostulacion.retirado)
          'horasAcreditadas': horasAcreditadas,
        // ?motivo omite esta entrada del mapa cuando es null: conserva el valor previo.
        'motivo': ?motivo,
        // Fecha del servidor para actualización; arrayUnion agrega el cambio al
        // historial.
        'actualizadaEn': FieldValue.serverTimestamp(),
        'historial': FieldValue.arrayUnion([change.toMap()]),
      });
    });
  }
}
