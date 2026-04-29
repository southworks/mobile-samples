import 'dart:async';

import 'package:authors_collection/services/auth_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

class AuthController extends ChangeNotifier {
  AuthController(this._authService);

  final AuthService _authService;

  StreamSubscription<User?>? _authSubscription;

  User? _user;
  bool _isInitializing = true;
  bool _isSigningIn = false;
  bool _isSigningOut = false;
  String? _errorMessage;

  User? get user => _user;
  bool get isAuthenticated => _user != null;
  bool get isInitializing => _isInitializing;
  bool get isSigningIn => _isSigningIn;
  bool get isSigningOut => _isSigningOut;
  String? get errorMessage => _errorMessage;

  Future<void> start() async {
    try {
      await _authService.initialize();
      _user = _authService.currentUser;
      _authSubscription = _authService.authStateChanges.listen(
        _handleAuthChange,
      );
    } catch (_) {
      _errorMessage =
          'No se pudo preparar la autenticación. Revisa la configuración de Firebase y Google Sign-In.';
    } finally {
      _isInitializing = false;
      notifyListeners();
    }
  }

  Future<void> signInWithGoogle() async {
    if (_isSigningIn) {
      return;
    }

    _errorMessage = null;
    _isSigningIn = true;
    notifyListeners();

    final result = await _authService.signInWithGoogle();

    if (!result.success) {
      _errorMessage = result.message;
    }

    _isSigningIn = false;
    notifyListeners();
  }

  Future<void> signOut() async {
    if (_isSigningOut) {
      return;
    }

    _errorMessage = null;
    _isSigningOut = true;
    notifyListeners();

    final result = await _authService.signOut();

    if (!result.success) {
      _errorMessage = result.message;
    }

    _isSigningOut = false;
    notifyListeners();
  }

  void _handleAuthChange(User? user) {
    _user = user;
    notifyListeners();
  }

  @override
  void dispose() {
    _authSubscription?.cancel();
    super.dispose();
  }
}
