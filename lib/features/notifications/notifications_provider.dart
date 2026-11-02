import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:nodara/data/models/app_notification.dart';
import 'package:nodara/data/models/app_user.dart';
import 'package:nodara/data/repositories/auth_repository.dart';
import 'package:nodara/data/repositories/notification_repository.dart';
import 'package:nodara/features/notifications/local_notification_service.dart';

class NotificationsProvider extends ChangeNotifier {
  NotificationsProvider(
    this._repository,
    AuthRepository authRepository, {
    LocalNoticeService? localNotifications,
  }) : _local = localNotifications ?? LocalNotificationService() {
    _authSubscription = authRepository.authStateChanges().listen(
      _onUserChanged,
    );
  }
  final NotificationRepository _repository;
  final LocalNoticeService _local;
  StreamSubscription<AppUser?>? _authSubscription;
  StreamSubscription<List<AppNotification>>? _subscription;
  String? _userId;
  List<AppNotification> _items = const [];
  final Set<String> _seen = {};
  bool _firstSnapshot = true;
  bool _isLoading = true;
  bool _disposed = false;
  int _generation = 0;
  String? _error;
  String? _localError;
  Future<void> _localQueue = Future<void>.value();

  bool get isLoading => _isLoading;
  String? get error => _error;
  String? get localError => _localError;
  List<AppNotification> get items => List.unmodifiable(_items);
  int get unreadCount => _items.where((n) => n.leida == false).length;
  void _emit() {
    if (_disposed == false) notifyListeners();
  }

  Future<bool> markAsRead(AppNotification notification) async {
    final userId = _userId;
    final generation = _generation;
    if (userId == null || notification.leida) return true;
    try {
      await _repository.marcarLeida(userId, notification.id);
      return true;
    } catch (_) {
      if (generation == _generation) {
        _error = 'No pudimos marcar el aviso como leído. Reintenta.';
        _emit();
      }
      return false;
    }
  }

  void retry() => _listen();

  void _onUserChanged(AppUser? user) {
    if (user?.uid == _userId && _subscription != null) return;
    _userId = user?.uid;
    _seen.clear();
    _firstSnapshot = true;
    _localError = null;
    // Serializar evita que una alerta anterior aparezca tras cerrar sesión.
    _localQueue = _localQueue
        .then((_) => _local.clear())
        .catchError((Object _) {});
    _listen();
  }

  void _listen() {
    final generation = ++_generation;
    _subscription?.cancel();
    _subscription = null;
    _items = const [];
    _error = null;
    final userId = _userId;
    _isLoading = userId != null;
    _emit();
    if (userId == null) return;
    _subscription = _repository
        .watchMine(userId)
        .listen(
          (items) {
            if (generation != _generation) return;
            // La primera emisión es historial; no debe repetir alertas antiguas.
            final fresh = _firstSnapshot
                ? <AppNotification>[]
                : items
                      .where(
                        (item) =>
                            item.leida == false &&
                            _seen.contains(item.id) == false,
                      )
                      .toList();
            _seen.addAll(items.map((item) => item.id));
            _firstSnapshot = false;
            _items = items;
            _isLoading = false;
            _error = null;
            _emit();
            for (final item in fresh) {
              _localQueue = _localQueue.then((_) async {
                if (generation != _generation || _disposed) return;
                try {
                  await _local.show(item);
                } catch (_) {
                  if (generation == _generation) {
                    _localError = 'No se pudo mostrar la alerta del celular. El aviso sigue disponible aquí.';
                    _emit();
                  }
                }
              });
            }
          },
          onError: (Object _) {
            if (generation != _generation) return;
            _isLoading = false;
            _error = 'No pudimos cargar tus notificaciones.';
            _emit();
          },
        );
  }

  @override
  void dispose() {
    _disposed = true;
    _generation++;
    _authSubscription?.cancel();
    _subscription?.cancel();
    super.dispose();
  }
}
