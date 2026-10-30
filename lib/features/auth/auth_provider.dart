import 'dart:async';

import 'package:flutter/foundation.dart';

import 'package:nodara/data/datasources/auth_data_source.dart';
import 'package:nodara/data/models/app_user.dart';
import 'package:nodara/data/models/opportunity.dart';
import 'package:nodara/data/repositories/auth_repository.dart';

/// Estado de la sesión y del perfil del usuario actual.
class AuthProvider extends ChangeNotifier {
  AuthProvider(this._repository) {
    _subscription = _repository.authStateChanges().listen(
      _onUserChanged,
      onError: (Object _) {
        _initialized = true;
        _error = 'No pudimos verificar tu sesión.';
        notifyListeners();
      },
    );
  }

  final AuthRepository _repository;
  StreamSubscription<AppUser?>? _subscription;

  AppUser? _user;
  bool _initialized = false;
  bool _isBusy = false;
  String? _error;

  AppUser? get user => _user;

  /// `false` hasta recibir la primera respuesta de la fuente de datos.
  bool get initialized => _initialized;
  bool get isAuthenticated => _user != null;

  /// `true` mientras se procesa login / registro / logout.
  bool get isBusy => _isBusy;
  String? get error => _error;

  bool isFavorite(String opportunityId) =>
      _user?.favoritos.contains(opportunityId) ?? false;

  /// Alterna el favorito y devuelve el nuevo estado.
  Future<bool> toggleFavorite(String opportunityId) async {
    final current = _user;
    if (current == null) return false;
    final favoritos = [...current.favoritos];
    final added = !favoritos.remove(opportunityId);
    if (added) favoritos.add(opportunityId);
    final updated = current.copyWith(favoritos: favoritos);
    _user = updated; // actualización optimista
    notifyListeners();
    await _repository.updateUser(updated);
    return added;
  }

  /// Inicia sesión. Devuelve `true` si funcionó; si no, deja el mensaje
  /// en [error] para que la pantalla lo muestre.
  Future<bool> signIn({required String email, required String password}) async {
    _empezarCarga();
    try {
      await _repository.signIn(email: email, password: password);
      return true;
    } on AuthException catch (e) {
      _error = e.message;
      return false;
    } catch (_) {
      _error = 'Ocurrió un error inesperado. Intenta de nuevo.';
      return false;
    } finally {
      _terminarCarga();
    }
  }

  /// Crea la cuenta y su perfil. Igual que [signIn], devuelve `true` o
  /// deja el mensaje en [error].
  Future<bool> register({
    required String nombre,
    required String email,
    required String password,
    required TipoUsuario tipo,
    required RolUsuario rol,
    required List<Causa> intereses,
    int horasRequeridas = 0,
  }) async {
    _empezarCarga();
    try {
      await _repository.register(
        nombre: nombre,
        email: email,
        password: password,
        tipo: tipo,
        rol: rol,
        intereses: intereses,
        horasRequeridas: horasRequeridas,
      );
      return true;
    } on AuthException catch (e) {
      _error = e.message;
      return false;
    } catch (_) {
      _error = 'Ocurrió un error inesperado. Intenta de nuevo.';
      return false;
    } finally {
      _terminarCarga();
    }
  }

  Future<void> signOut() => _repository.signOut();

  void clearError() {
    if (_error == null) return;
    _error = null;
    notifyListeners();
  }

  /// Muestra el indicador de carga y limpia el error anterior.
  void _empezarCarga() {
    _isBusy = true;
    _error = null;
    notifyListeners();
  }

  /// Quita el indicador de carga y avisa a la pantalla.
  void _terminarCarga() {
    _isBusy = false;
    notifyListeners();
  }

  void _onUserChanged(AppUser? user) {
    _user = user;
    _initialized = true;
    notifyListeners();
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}
