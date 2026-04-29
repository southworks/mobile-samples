import 'package:authors_collection/screens/home_screen.dart';
import 'package:authors_collection/screens/login_screen.dart';
import 'package:authors_collection/screens/startup_error_screen.dart';
import 'package:authors_collection/state/auth_controller.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({super.key, this.startupError});

  final Object? startupError;

  @override
  Widget build(BuildContext context) {
    if (startupError != null) {
      return StartupErrorScreen(error: startupError!);
    }

    return Consumer<AuthController>(
      builder: (context, authController, _) {
        if (authController.isInitializing) {
          return const _LoadingScreen();
        }

        if (authController.isAuthenticated && authController.user != null) {
          return HomeScreen(user: authController.user!);
        }

        return const LoginScreen();
      },
    );
  }
}

class _LoadingScreen extends StatelessWidget {
  const _LoadingScreen();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: Center(child: CircularProgressIndicator()));
  }
}
