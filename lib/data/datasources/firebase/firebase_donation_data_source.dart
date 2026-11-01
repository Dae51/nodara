import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:nodara/data/datasources/donation_data_source.dart';
import 'package:nodara/data/datasources/firebase/firestore_utils.dart';
import 'package:nodara/data/models/donation_point.dart';

/// Fuente Firestore de los puntos de donación visibles en el módulo Donar.
class FirebaseDonationDataSource implements DonationDataSource {
  FirebaseDonationDataSource({FirebaseFirestore? firestore})
      : _db = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _db;

  @override
  Stream<List<DonationPoint>> watchActive() => _db
      .collection('donationPoints')
      .where('activa', isEqualTo: true)
      .snapshots()
      .map(
        (snapshot) => snapshot.docs
            .map(
              (doc) => DonationPoint.fromMap(
                doc.id,
                fromFirestore(doc.data()),
              ),
            )
            .toList(growable: false),
      );
}
