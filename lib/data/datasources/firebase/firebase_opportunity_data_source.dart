import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:nodara/data/datasources/firebase/firestore_utils.dart';
import 'package:nodara/data/datasources/opportunity_data_source.dart';
import 'package:nodara/data/models/opportunity.dart';

/// Fuente Firestore de `opportunities`.
///
/// Los filtros visuales viven en [OpportunityRepository], por lo que esta
/// clase se limita a escuchar y persistir documentos del servidor.
class FirebaseOpportunityDataSource implements OpportunityDataSource {
  FirebaseOpportunityDataSource({FirebaseFirestore? firestore})
      : _db = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _db;

  CollectionReference<Map<String, dynamic>> get _opportunities =>
      _db.collection('opportunities');

  @override
  Stream<List<Opportunity>> watchActive() => _opportunities
      .where('activa', isEqualTo: true)
      .snapshots()
      .map(_toOpportunities);

  @override
  Stream<List<Opportunity>> watchByOrg(String orgId) => _opportunities
      .where('orgId', isEqualTo: orgId)
      .snapshots()
      .map(_toOpportunities);

  @override
  Future<String> create(Opportunity opportunity) async {
    final reference = await _opportunities.add(opportunity.toMap());
    return reference.id;
  }

  @override
  Future<void> update(Opportunity opportunity) =>
      _opportunities.doc(opportunity.id).set(opportunity.toMap());

  @override
  Future<void> incrementCuposOcupados(String opportunityId, int delta) =>
      _opportunities.doc(opportunityId).update({
        'cuposOcupados': FieldValue.increment(delta),
      });

  List<Opportunity> _toOpportunities(
    QuerySnapshot<Map<String, dynamic>> snapshot,
  ) => snapshot.docs
      .map((doc) => Opportunity.fromMap(doc.id, fromFirestore(doc.data())))
      .toList(growable: false);
}
