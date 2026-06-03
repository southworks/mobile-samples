import 'package:flutter/material.dart';

class ProviderPlaceholderPage extends StatelessWidget {
  const ProviderPlaceholderPage({
    super.key,
    required this.title,
    required this.status,
    required this.description,
    required this.nextSteps,
    required this.configKeys,
  });

  final String title;
  final String status;
  final String description;
  final List<String> nextSteps;
  final List<String> configKeys;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      status,
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    const SizedBox(height: 12),
                    Text(description),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Siguientes pasos',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 12),
                    for (final step in nextSteps) ...[
                      Text('- $step'),
                      const SizedBox(height: 8),
                    ],
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Configuracion esperada',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 12),
                    if (configKeys.isEmpty)
                      const Text(
                        'No faltan claves requeridas para este scaffold.',
                      )
                    else
                      Text(configKeys.join(', ')),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
