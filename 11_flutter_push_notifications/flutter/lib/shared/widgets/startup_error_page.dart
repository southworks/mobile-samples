import 'package:flutter/material.dart';

class StartupErrorPage extends StatelessWidget {
  const StartupErrorPage({required this.error, super.key});

  final Object error;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Startup error')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Firebase failed to initialize.',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 12),
            Text(
              'Complete Firebase setup in flutter/README.md, then run '
              '`flutterfire configure` to generate firebase_options.dart.',
            ),
            const SizedBox(height: 16),
            Text(
              error.toString(),
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
          ],
        ),
      ),
    );
  }
}
