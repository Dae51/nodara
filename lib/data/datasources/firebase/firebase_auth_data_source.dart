import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:nodara/data/datasources/auth_data_source.dart';
import 'package:nodara/data/datasources/firebase/firestore_utils.dart';
import 'package:nodara/data/models/app_user.dart';
import 'package:nodara/data/models/opportunity.dart';

/// Autenticación con Firebase Auth (correo/contraseña) + perfil en
/// `users/{uid}` de Firestore.
class FirebaseAuthDataSource implements AuthDataSource {
  FirebaseAuthDataSource({FirebaseAuth? auth, FirebaseFirestore? firestore})
      : _auth = auth ?? FirebaseAuth.instance,
        _db = firestore ?? FirebaseFirestore.instance;

  final FirebaseAuth _auth;
  final FirebaseFirestore _db;

  CollectionReference<Map<String, dynamic>> get _users =>
      _db.collection('users');

  /// Cada vez que cambia la sesión (entrar o salir), lee el perfil del
  /// usuario en `users/{uid}` y lo convierte en [AppUser].
  @override
  Stream<AppUser?> authStateChanges() {
    return _auth.authStateChanges().asyncMap((user) async {
      if (user == null) return null;
      final data = await _leerPerfil(user.uid);
      return _toAppUser(user, data);
    });
  }

  /// Lee el perfil. Justo después de registrarse, Firebase avisa de la
  /// sesión antes de que el perfil termine de guardarse; por eso se
  /// reintenta hasta 3 veces esperando medio segundo.
  Future<Map<String, dynamic>?> _leerPerfil(String uid) async {
    for (var intento = 0; intento < 3; intento++) {
      final doc = await _users.doc(uid).get();
      final data = doc.data();
      if (data != null) return data;
      await Future<void>.delayed(const Duration(milliseconds: 500));
    }
    return null;
  }

  @override
  Future<AppUser> signIn({
    required String email,
    required String password,
  }) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      final user = credential.user;
      if (user == null) throw const AuthException('No pudimos iniciar sesión.');
      final doc = await _users.doc(user.uid).get();
      return _toAppUser(user, doc.data());
    } on FirebaseAuthException catch (e) {
      throw AuthException(_mensajeDeError(e.code));
    }
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
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      final user = credential.user;
      if (user == null) throw const AuthException('No pudimos crear tu cuenta.');
      await user.updateDisplayName(nombre);
      final appUser = AppUser(
        uid: user.uid,
        nombre: nombre,
        email: email.toLowerCase(),
        tipo: tipo,
        rol: rol,
        intereses: intereses,
        horasRequeridas: horasRequeridas,
        creadoEn: DateTime.now(),
      );
      await _users.doc(user.uid).set(appUser.toMap());
      return appUser;
    } on FirebaseAuthException catch (e) {
      throw AuthException(_mensajeDeError(e.code));
    }
  }

  @override
  Future<void> signOut() => _auth.signOut();

  @override
  Future<void> sendPasswordReset({required String email}) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      throw AuthException(_mensajeDeError(e.code));
    }
  }

  @override
  Future<void> updateUser(AppUser user) =>
      _users.doc(user.uid).set(user.toMap(), SetOptions(merge: true));

  /// Si el perfil todavía no existe (justo después de registrarse) se arma
  /// uno mínimo con los datos de Firebase Auth para evitar parpadeos.
  AppUser _toAppUser(User user, Map<String, dynamic>? data) {
    if (data == null) {
      return AppUser(
        uid: user.uid,
        nombre: user.displayName ?? '',
        email: user.email ?? '',
        creadoEn: DateTime.now(),
      );
    }
    return AppUser.fromMap(user.uid, fromFirestore(data));
  }

  /// Traduce los códigos de `FirebaseAuthException` a mensajes claros.
  static String _mensajeDeError(String code) {
    switch (code) {
      case 'invalid-email':
        return 'El correo no es válido.';
      case 'user-disabled':
        return 'Esta cuenta fue deshabilitada.';
      case 'user-not-found':
      case 'wrong-password':
      case 'invalid-credential':
        return 'Correo o contraseña incorrectos.';
      case 'email-already-in-use':
        return 'Ya existe una cuenta con ese correo.';
      case 'weak-password':
        return 'La contraseña es muy débil (mínimo 6 caracteres).';
      case 'too-many-requests':
        return 'Demasiados intentos. Espera unos minutos e intenta de nuevo.';
      case 'network-request-failed':
        return 'Sin conexión. Revisa tu internet.';
      case 'operation-not-allowed':
        return 'El inicio con correo no está habilitado en Firebase.';
      default:
        return 'Ocurrió un error ($code). Intenta de nuevo.';
    }
  }
}
