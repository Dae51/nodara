import 'package:nodara/data/models/app_user.dart';
import 'package:nodara/data/models/opportunity.dart';

/// Error de autenticación con un mensaje listo para mostrar al usuario.
class AuthException implements Exception {
  const AuthException(this.message);

  final String message;

  @override
  String toString() => message;
}

/// Contrato de autenticación y perfil del usuario.
///
/// Implementaciones: `FakeAuthDataSource` (desarrollo/tests) y
/// `FirebaseAuthDataSource` (F1).
abstract class AuthDataSource {
  /// Emite el usuario actual y cada cambio de sesión o de perfil.
  Stream<AppUser?> authStateChanges();

  Future<AppUser> signIn({required String email, required String password});

  Future<AppUser> register({
    required String nombre,
    required String email,
    required String password,
    required TipoUsuario tipo,
    required RolUsuario rol,
    required List<Causa> intereses,
    required int horasRequeridas,
  });

  Future<void> signOut();

  /// Envía un correo para restablecer la contraseña. Por seguridad no revela
  /// si la cuenta existe.
  Future<void> sendPasswordReset({required String email});

  Future<void> updateUser(AppUser user);
}
