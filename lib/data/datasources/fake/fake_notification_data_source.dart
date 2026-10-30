import 'package:nodara/data/datasources/fake/fake_seed.dart';
import 'package:nodara/data/datasources/fake/in_memory_collection.dart';
import 'package:nodara/data/datasources/notification_data_source.dart';
import 'package:nodara/data/models/app_notification.dart';

/// Notificaciones en memoria, separadas por usuario.
class FakeNotificationDataSource implements NotificationDataSource {
  final Map<String, InMemoryCollection<AppNotification>> _byUser = {};

  InMemoryCollection<AppNotification> _collectionFor(String userId) =>
      _byUser.putIfAbsent(
        userId,
        () => InMemoryCollection<AppNotification>(
          userId == FakeSeed.sofiaId ? FakeSeed.notifications() : const [],
        ),
      );

  @override
  Stream<List<AppNotification>> watchByUser(String userId) =>
      _collectionFor(userId).watch();

  @override
  Future<void> create(String userId, AppNotification notification) async {
    _collectionFor(userId).add(notification.copyWith(id: fakeId('not')));
  }

  @override
  Future<void> markAsRead(String userId, String notificationId) async {
    _collectionFor(userId).replaceFirst(
      (n) => n.id == notificationId,
      (n) => n.copyWith(leida: true),
    );
  }
}
