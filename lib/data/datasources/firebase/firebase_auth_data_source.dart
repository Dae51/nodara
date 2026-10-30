import 'dart:async';

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

  /// Combina `authStateChanges()` con el documento del perfil: cada vez que
  /// cambia la sesión se cancela la escucha anterior y se escucha el
  /// documento del nuevo usuario.
  @override
  Stream<AppUser?> authStateChanges() {
    final controller = StreamController<AppUser?>();
    StreamSubscription<User?>? authSub;
    StreamSubscription<DocumentSnapshot<Map<String, dynamic>>>? docSub;

    controller.onListen = () {
      authSub = _auth.authStateChanges().listen(
        (user) {
          docSub?.cancel();
          docSub = null;
          if (user == null) {
            controller.add(null);
            return;
          }
          docSub = _users.doc(user.uid).snapshots().listen(
                (doc) => controller.add(_toAppUser(user, doc.data())),
                onError: controller.addError,
              );
        },
        onError: controller.addError,
      );
    };
    controller.onCancel = () async {
      await docSub?.cancel();
      await authSub?.cancel();
    };
    return controller.stream;
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
  static String _mensajeDeError(String code) => switch (code) {
        'invalid-email' => 'El correo no es válido.',
        'user-disabled' => 'Esta cuenta fue deshabilitada.',
        'user-not-found' ||
        'wrong-password' ||
        'invalid-credential' =>
          'Correo o contraseña incorrectos.',
        'email-already-in-use' => 'Ya existe una cuenta con ese correo.',
        'weak-password' => 'La contraseña es muy débil (mínimo 6 caracteres).',
        'too-many-requests' =>
          'Demasiados intentos. Espera unos minutos e intenta de nuevo.',
        'network-request-failed' => 'Sin conexión. Revisa tu internet.',
        'operation-not-allowed' =>
          'El inicio con correo no está habilitado en Firebase.',
        _ => 'Ocurrió un error ($code). Intenta de nuevo.',
      };
}
