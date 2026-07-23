import 'package:flutter/material.dart';

import 'content_view.dart';

void main() {
  runApp(const CommonUiApp());
}

class CommonUiApp extends StatelessWidget {
  const CommonUiApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'common_ui',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const ContentView(),
    );
  }
}
