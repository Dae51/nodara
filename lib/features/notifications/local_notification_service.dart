import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:nodara/data/models/app_notification.dart';

abstract interface class LocalNoticeService {
  Future<void> show(AppNotification notification);
  Future<void> clear();
}

/// El stream entrega el aviso; el sistema muestra una alerta local.
/// No recibe mensajes cuando la aplicación está cerrada.
class LocalNotificationService implements LocalNoticeService {
  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();
  Future<void>? _initialization;
  bool get _supported =>
      kIsWeb == false &&
      (defaultTargetPlatform == TargetPlatform.android ||
          defaultTargetPlatform == TargetPlatform.iOS);

  Future<void> _initialize() async {
    await _plugin.initialize(
      settings: const InitializationSettings(
        android: AndroidInitializationSettings('@mipmap/ic_launcher'),
        iOS: DarwinInitializationSettings(),
      ),
    );
    final allowed = await _plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.requestNotificationsPermission();
    if (allowed == false) {
      throw StateError('Permiso de notificaciones denegado.');
    }
  }

  @override
  Future<void> show(AppNotification notification) async {
    if (_supported == false) return;
    try {
      await (_initialization ??= _initialize());
    } catch (_) {
      _initialization = null;
      rethrow;
    }
    await _plugin.show(
      id: notification.id.hashCode & 0x7fffffff,
      title: notification.titulo,
      body: notification.cuerpo,
      notificationDetails: const NotificationDetails(
        android: AndroidNotificationDetails(
          'nodara_avisos',
          'Avisos de postulaciones',
          channelDescription:
              'Respuestas de las organizaciones a tus postulaciones',
          importance: Importance.high,
          priority: Priority.high,
        ),
        iOS: DarwinNotificationDetails(),
      ),
    );
  }

  @override
  Future<void> clear() async {
    if (_supported == false || _initialization == null) return;
    await _initialization;
    await _plugin.cancelAll();
  }
}
