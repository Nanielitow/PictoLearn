import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

/// Servicio que centraliza toda la lógica de autenticación de PictoLearn.
/// Las pantallas (login.dart, register.dart) solo deben llamar a estos
/// métodos, nunca usar FirebaseAuth directamente.
class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  /// Usuario actualmente autenticado (null si no hay sesión iniciada).
  User? get currentUser => _auth.currentUser;

  /// Stream que emite cada vez que cambia el estado de sesión
  /// (útil para proteger rutas con go_router).
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  /// Inicia sesión con correo y contraseña.
  /// Lanza [AuthException] con un mensaje ya traducido al español
  /// si algo falla, para mostrarlo directo en la UI.
  Future<User?> signIn({
    required String email,
    required String password,
  }) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      return credential.user;
    } on FirebaseAuthException catch (e) {
      throw AuthException(_mapErrorMessage(e.code));
    }
  }

  /// Crea una cuenta nueva y guarda datos adicionales del usuario
  /// (nombre, edad, etc.) en Firestore, en la colección 'users'.
  Future<User?> signUp({
    required String email,
    required String password,
    required String name,
    int? age,
  }) async {
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      final user = credential.user;
      if (user != null) {
        // Guardamos el nombre también en el perfil de Firebase Auth.
        await user.updateDisplayName(name);

        // Guardamos datos extra en Firestore, indexados por uid.
        await _db.collection('users').doc(user.uid).set({
          'name': name,
          'email': email.trim(),
          'age': age,
          'createdAt': FieldValue.serverTimestamp(),
        });
      }

      return user;
    } on FirebaseAuthException catch (e) {
      throw AuthException(_mapErrorMessage(e.code));
    }
  }

  /// Cierra la sesión del usuario actual.
  Future<void> signOut() async {
    await _auth.signOut();
  }

  /// Envía un correo de recuperación de contraseña.
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email.trim());
    } on FirebaseAuthException catch (e) {
      throw AuthException(_mapErrorMessage(e.code));
    }
  }

  /// Traduce los códigos de error de Firebase a mensajes amigables,
  /// coherentes con el tono infantil del resto de la app.
  String _mapErrorMessage(String code) {
    switch (code) {
      case 'user-not-found':
        return '¡No encontramos una cuenta con ese correo!';
      case 'wrong-password':
        return '¡Ups! La palabra secreta no es correcta';
      case 'email-already-in-use':
        return '¡Ese correo ya tiene una cuenta! Intenta iniciar sesión';
      case 'invalid-email':
        return 'Ese correo no parece válido';
      case 'weak-password':
        return '¡La palabra secreta debe ser más larga!';
      case 'too-many-requests':
        return 'Intentaste muchas veces, espera un momento e inténtalo de nuevo';
      case 'network-request-failed':
        return 'No hay conexión a internet, revisa tu red';
      default:
        return 'Algo salió mal, inténtalo de nuevo';
    }
  }
}

/// Excepción simple para propagar mensajes de error ya traducidos
/// desde AuthService hasta la UI.
class AuthException implements Exception {
  final String message;
  AuthException(this.message);

  @override
  String toString() => message;
}