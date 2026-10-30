import 'dart:async';

import 'package:nodara/data/datasources/auth_data_source.dart';
import 'package:nodara/data/datasources/fake/fake_seed.dart';
import 'package:nodara/data/datasources/fake/in_memory_collection.dart';
import 'package:nodara/data/models/app_user.dart';
import 'package:nodara/data/models/opportunity.dart';

/// Autenticación en memoria. Arranca con la sesión de Sofía iniciada.
///
/// Cuentas de prueba: `sofia@nodara.app` (voluntaria) y `org@nodara.app`
/// (organización). Cualquier contraseña de 6+ caracteres funciona.
class FakeAuthDataSource implements AuthDataSource {
  FakeAuthDataSource({AppUser? initialUser, bool startSignedIn = true})
      : _current = startSignedIn ? (initialUser ?? FakeSeed.sofia) : null {
    for (final user in FakeSeed.users) {
      _users[user.email] = user;
    }
  }

  final Map<String, AppUser> _users = {};
  final StreamController<AppUser?> _changes =
      StreamController<AppUser?>.broadcast();
  AppUser? _current;

  @override
  Stream<AppUser?> authStateChanges() async* {
    yield _current;
    yield* _changes.stream;
  }

  @override
  Future<AppUser> signIn({
    required String email,
    required String password,
  }) async {
    final user = _users[email.trim().toLowerCase()];
    if (user == null || password.length < 6) {
      throw const AuthException('Correo o contraseña incorrectos.');
    }
    _setCurrent(user);
    return user;
  }

  @override
  Future<AppUser> register({
    required String nombre,
    required String email,
    required String password,
    required TipoUsuario tipo,
    required RolUsuario rol,
    required List<Causa> intereses,
    required int horasRequeridas,
  }) async {
    final key = email.trim().toLowerCase();
    if (_users.containsKey(key)) {
      throw const AuthException('Ya existe una cuenta con ese correo.');
    }
    final user = AppUser(
      uid: fakeId('user'),
      nombre: nombre.trim(),
      email: key,
      tipo: tipo,
      rol: rol,
      intereses: intereses,
      horasRequeridas: horasRequeridas,
      creadoEn: DateTime.now(),
    );
    _users[key] = user;
    _setCurrent(user);
    return user;
  }

  @override
  Future<void> signOut() async => _setCurrent(null);

  @override
  Future<void> sendPasswordReset({required String email}) async {
    // Fake: no envía nada. Igual que Firebase, no revela si la cuenta existe.
  }

  @override
  Future<void> updateUser(AppUser user) async {
    _users[user.email] = user;
    if (_current?.uid == user.uid) _setCurrent(user);
  }

  void _setCurrent(AppUser? user) {
    _current = user;
    _changes.add(user);
  }
}
