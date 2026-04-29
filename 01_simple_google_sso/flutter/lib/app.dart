import 'package:authors_collection/services/auth_service.dart';
import 'package:authors_collection/screens/startup_error_screen.dart';
import 'package:authors_collection/state/auth_controller.dart';
import 'package:authors_collection/widgets/auth_gate.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class AuthorsCollectionApp extends StatelessWidget {
  const AuthorsCollectionApp({super.key, this.startupError});

  final Object? startupError;

  @override
  Widget build(BuildContext context) {
    if (startupError != null) {
      return MaterialApp(
        title: 'Authors Collection',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFF0F766E),
            brightness: Brightness.light,
          ),
          scaffoldBackgroundColor: const Color(0xFFF6F8FB),
        ),
        home: StartupErrorScreen(error: startupError!),
      );
    }

    return MultiProvider(
      providers: [
        Provider<AuthService>(create: (_) => AuthService()),
        ChangeNotifierProvider<AuthController>(
          create: (context) =>
              AuthController(context.read<AuthService>())..start(),
        ),
      ],
      child: MaterialApp(
        title: 'Authors Collection',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFF0F766E),
            brightness: Brightness.light,
          ),
          scaffoldBackgroundColor: const Color(0xFFF6F8FB),
        ),
        home: const AuthGate(),
      ),
    );
  }
}
