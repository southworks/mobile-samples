import 'package:flutter/material.dart';

import 'shared_example_views.dart';

class BasicsMenuView extends StatelessWidget {
  const BasicsMenuView({super.key});

  @override
  Widget build(BuildContext context) {
    return const BasicsExampleView();
  }
}

class BasicsExampleView extends StatefulWidget {
  const BasicsExampleView({super.key});

  @override
  State<BasicsExampleView> createState() => _BasicsExampleViewState();
}

class _BasicsExampleViewState extends State<BasicsExampleView> {
  double progress = 0.55;

  @override
  Widget build(BuildContext context) {
    return ExampleScreen(
      title: 'Basics',
      children: [
        sectionTitle(context, 'Text'),
        Text(
          'Text with title font.',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        Text(
          'Text with secondary style.',
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
        Text(
          'Text with bold, italic and underline styles.',
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontStyle: FontStyle.italic,
            decoration: TextDecoration.underline,
          ),
        ),
        const Divider(),
        sectionTitle(context, 'Label'),
        const Row(
          children: [
            Icon(Icons.star, color: Colors.amber),
            SizedBox(width: 8),
            Text('Star label'),
          ],
        ),
        const Row(
          children: [
            Icon(Icons.arrow_circle_down, color: Colors.blue),
            SizedBox(width: 8),
            Text('Down arrow label', style: TextStyle(color: Colors.blue)),
          ],
        ),
        Row(
          children: [
            const Icon(Icons.account_circle),
            const SizedBox(width: 8),
            Text(
              'Person crop label',
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ],
        ),
        const Divider(),
        sectionTitle(context, 'Image'),
        const Icon(Icons.flutter_dash, size: 100, color: Colors.orange),
        const Icon(Icons.collections, size: 48, color: Colors.purple),
        const Divider(),
        sectionTitle(context, 'AsyncImage'),
        ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Image.network(
            'https://picsum.photos/300',
            height: 180,
            width: double.infinity,
            fit: BoxFit.cover,
            loadingBuilder: (context, child, loadingProgress) {
              if (loadingProgress == null) {
                return child;
              }
              return const SizedBox(
                height: 180,
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircularProgressIndicator(),
                      SizedBox(height: 8),
                      Text('Loading image...'),
                    ],
                  ),
                ),
              );
            },
            errorBuilder: (context, error, stackTrace) {
              return SizedBox(
                height: 180,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.wifi_off,
                      size: 48,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                    const SizedBox(height: 8),
                    const Text('Image not available'),
                  ],
                ),
              );
            },
          ),
        ),
        const Divider(),
        sectionTitle(context, 'ProgressView'),
        LinearProgressIndicator(value: progress),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Uploading files...'),
            const SizedBox(height: 8),
            LinearProgressIndicator(value: progress),
          ],
        ),
        FilledButton(
          onPressed: () {
            setState(() {
              progress = (progress + 0.1).clamp(0.0, 1.0);
            });
          },
          child: const Text('Increase'),
        ),
        FilledButton(
          onPressed: () {
            setState(() {
              progress = (progress - 0.1).clamp(0.0, 1.0);
            });
          },
          child: const Text('Decrease'),
        ),
        const Divider(),
        sectionTitle(context, 'Divider'),
        const Text('Section A'),
        const Divider(),
        const Text('Section B'),
        const Divider(),
        const SizedBox(
          height: 40,
          child: Row(
            children: [
              Text('Left'),
              VerticalDivider(width: 24),
              Text('Right'),
            ],
          ),
        ),
      ],
    );
  }
}
