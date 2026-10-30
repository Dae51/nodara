import 'dart:async';

import 'package:flutter/foundation.dart';

import 'package:nodara/data/models/app_notification.dart';
import 'package:nodara/data/models/app_user.dart';
import 'package:nodara/data/repositories/auth_repository.dart';
import 'package:nodara/data/repositories/notification_repository.dart';

/// Avisos del usuario. En F4 aquí se dispara la notificación local
/// cuando llega un aviso nuevo.
class NotificationsProvider extends ChangeNotifier {
  NotificationsProvider(this._repository, AuthRepository authRepository) {
    _authSubscription =
        authRepository.authStateChanges().listen(_onUserChanged);
  }

  final NotificationRepository _repository;
  StreamSubscription<AppUser?>? _authSubscription;
  StreamSubscription<List<AppNotification>>? _subscription;

  String? _userId;
  List<AppNotification> _items = const [];
  bool _isLoading = true;
  String? _error;

  bool get isLoading => _isLoading;
  String? get error => _error;
  List<AppNotification> get items => _items;
  int get unreadCount => _items.where((n) => !n.leida).length;

  Future<void> markAsRead(AppNotification notification) async {
    final userId = _userId;
    if (userId == null || notification.leida) return;
    await _repository.marcarLeida(userId, notification.id);
  }

  void _onUserChanged(AppUser? user) {
    if (user?.uid == _userId && _subscription != null) return;
    _userId = user?.uid;
    _subscription?.cancel();
    _subscription = null;
    _items = const [];
    _error = null;
    if (user == null) {
      _isLoading = false;
      notifyListeners();
      return;
    }
    _isLoading = true;
    notifyListeners();
    _subscription = _repository.watchMine(user.uid).listen(
      (items) {
        _items = items;
        _isLoading = false;
        notifyListeners();
      },
      onError: (Object _) {
        _isLoading = false;
        _error = 'No pudimos cargar tus notificaciones.';
        notifyListeners();
      },
    );
  }

  @override
  void dispose() {
    _authSubscription?.cancel();
    _subscription?.cancel();
    super.dispose();
  }
}
