import 'package:flutter/material.dart';
import 'screens/home_screen.dart';

void main() {
  runApp(const NativeSamplesApp());
}

class NativeSamplesApp extends StatelessWidget {
  const NativeSamplesApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter + native calls',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF0F766E)),
        useMaterial3: true,
      ),
      home: const HomeScreen(),
    );
  }
}
