import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:nodara/data/datasources/firebase/firestore_utils.dart';
import 'package:nodara/data/datasources/notification_data_source.dart';
import 'package:nodara/data/models/app_notification.dart';

/// Fuente Firestore de los avisos privados de cada usuario.
class FirebaseNotificationDataSource implements NotificationDataSource {
  FirebaseNotificationDataSource({FirebaseFirestore? firestore})
    : _db = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _db;

  CollectionReference<Map<String, Object?>> _notifications(String userId) =>
      _db.collection('users').doc(userId).collection('notifications');

  @override
  Stream<List<AppNotification>> watchByUser(String userId) =>
      _notifications(userId).snapshots().map(
        (snapshot) => snapshot.docs
            .map(
              (doc) =>
                  AppNotification.fromMap(doc.id, fromFirestore(doc.data())),
            )
            .toList(growable: false),
      );

  @override
  Future<void> create(String userId, AppNotification notification) async {
    await _notifications(userId).add(notification.toMap());
  }

  @override
  Future<void> markAsRead(String userId, String notificationId) =>
      _notifications(userId).doc(notificationId).update({'leida': true});
}
