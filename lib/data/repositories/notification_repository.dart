import 'package:nodara/data/datasources/notification_data_source.dart';
import 'package:nodara/data/models/app_notification.dart';

class NotificationRepository {
  NotificationRepository(this._dataSource);

  final NotificationDataSource _dataSource;

  /// Avisos del usuario, más recientes primero.
  Stream<List<AppNotification>> watchMine(String userId) =>
      _dataSource.watchByUser(userId).map(
            (list) =>
                [...list]..sort((a, b) => b.creadaEn.compareTo(a.creadaEn)),
          );

  Future<void> enviar(String userId, AppNotification notification) =>
      _dataSource.create(userId, notification);

  Future<void> marcarLeida(String userId, String notificationId) =>
      _dataSource.markAsRead(userId, notificationId);
}
