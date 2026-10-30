import 'package:nodara/data/datasources/auth_data_source.dart';
import 'package:nodara/data/models/app_user.dart';
import 'package:nodara/data/models/opportunity.dart';

/// Punto de acceso a la sesión y al perfil. La UI solo conoce esta clase.
class AuthRepository {
  AuthRepository(this._dataSource);

  final AuthDataSource _dataSource;

  Stream<AppUser?> authStateChanges() => _dataSource.authStateChanges();

  Future<AppUser> signIn({required String email, required String password}) =>
      _dataSource.signIn(email: email.trim(), password: password);

  Future<AppUser> register({
    required String nombre,
    required String email,
    required String password,
    required TipoUsuario tipo,
    required RolUsuario rol,
    required List<Causa> intereses,
    int horasRequeridas = 0,
  }) =>
      _dataSource.register(
        nombre: nombre.trim(),
        email: email.trim(),
        password: password,
        tipo: tipo,
        rol: rol,
        intereses: intereses,
        horasRequeridas: horasRequeridas,
      );

  Future<void> signOut() => _dataSource.signOut();

  Future<void> sendPasswordReset({required String email}) =>
      _dataSource.sendPasswordReset(email: email.trim());

  Future<void> updateUser(AppUser user) => _dataSource.updateUser(user);
}
