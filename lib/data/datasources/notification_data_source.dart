import 'package:nodara/data/models/app_notification.dart';

/// Contrato de acceso a `users/{uid}/notifications`.
abstract class NotificationDataSource {
  Stream<List<AppNotification>> watchByUser(String userId);

  Future<void> create(String userId, AppNotification notification);

  Future<void> markAsRead(String userId, String notificationId);
}
