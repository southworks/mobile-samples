import 'dart:async';

import 'package:authors_collection/config/google_sign_in_config.dart';
import 'package:authors_collection/models/auth_result.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthService {
  AuthService({FirebaseAuth? firebaseAuth, GoogleSignIn? googleSignIn})
    : _firebaseAuth = firebaseAuth ?? FirebaseAuth.instance,
      _googleSignIn = googleSignIn ?? GoogleSignIn.instance;

  final FirebaseAuth _firebaseAuth;
  final GoogleSignIn _googleSignIn;

  bool _googleInitialized = false;

  Stream<User?> get authStateChanges => _firebaseAuth.authStateChanges();

  User? get currentUser => _firebaseAuth.currentUser;

  Future<void> initialize() async {
    if (_googleInitialized) {
      return;
    }

    await _googleSignIn.initialize(
      serverClientId: GoogleSignInConfig.resolvedServerClientId,
    );
    _googleInitialized = true;
  }

  Future<AuthResult> signInWithGoogle() async {
    try {
      await initialize();

      final GoogleSignInAccount googleUser = await _googleSignIn.authenticate();
      final GoogleSignInAuthentication googleAuth = googleUser.authentication;
      final String? idToken = googleAuth.idToken;

      if (idToken == null || idToken.isEmpty) {
        return const AuthResult(
          success: false,
          message:
              'Google no devolvió un token válido. Revisa la configuración del proyecto.',
        );
      }

      final credential = GoogleAuthProvider.credential(idToken: idToken);
      await _firebaseAuth.signInWithCredential(credential);

      return const AuthResult(success: true);
    } on GoogleSignInException catch (error) {
      return AuthResult(success: false, message: _googleErrorMessage(error));
    } on FirebaseAuthException catch (error) {
      return AuthResult(success: false, message: _firebaseErrorMessage(error));
    } catch (_) {
      return const AuthResult(
        success: false,
        message: 'No se pudo iniciar sesión. Intenta nuevamente.',
      );
    }
  }

  Future<AuthResult> signOut() async {
    try {
      await Future.wait<void>([
        _firebaseAuth.signOut(),
        _googleSignIn.signOut(),
      ]);

      return const AuthResult(success: true);
    } on FirebaseAuthException catch (error) {
      return AuthResult(success: false, message: _firebaseErrorMessage(error));
    } catch (_) {
      return const AuthResult(
        success: false,
        message: 'No se pudo cerrar la sesión. Intenta nuevamente.',
      );
    }
  }

  String _firebaseErrorMessage(FirebaseAuthException error) {
    switch (error.code) {
      case 'account-exists-with-different-credential':
        return 'Ya existe una cuenta con ese email usando otro método de acceso.';
      case 'invalid-credential':
        return 'Las credenciales recibidas no son válidas.';
      case 'network-request-failed':
        return 'No hay conexión disponible. Revisa tu red e intenta nuevamente.';
      case 'user-disabled':
        return 'Esta cuenta fue deshabilitada.';
      default:
        return error.message ??
            'Ocurrió un error autenticando contra Firebase.';
    }
  }

  String _googleErrorMessage(GoogleSignInException error) {
    switch (error.code) {
      case GoogleSignInExceptionCode.canceled:
        return 'Inicio de sesión cancelado.';
      case GoogleSignInExceptionCode.clientConfigurationError:
        return 'Google Sign-In no está configurado correctamente. Revisa SHA-1, google-services.json e Info.plist.';
      case GoogleSignInExceptionCode.providerConfigurationError:
        return 'El proveedor de Google no está disponible o está mal configurado.';
      case GoogleSignInExceptionCode.uiUnavailable:
        return 'No se pudo mostrar la interfaz de Google Sign-In.';
      case GoogleSignInExceptionCode.interrupted:
        return 'La autenticación fue interrumpida. Intenta nuevamente.';
      default:
        return error.description ??
            'Ocurrió un error al iniciar sesión con Google.';
    }
  }
}
