import 'package:flutter/material.dart';

import 'shared_example_views.dart';

class LayoutMenuView extends StatelessWidget {
  const LayoutMenuView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Layout')),
      body: ListView(
        children: [
          ListTile(
            title: const Text('Stacks'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const StacksExampleView()),
              );
            },
          ),
          ListTile(
            title: const Text('ScrollView'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => const ScrollViewExampleView(),
                ),
              );
            },
          ),
          ListTile(
            title: const Text('LazyVStack'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => const LazyVStackExampleView(),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class StacksExampleView extends StatelessWidget {
  const StacksExampleView({super.key});

  @override
  Widget build(BuildContext context) {
    return ExampleScreen(
      title: 'Stacks',
      children: [
        Text('VStack', style: Theme.of(context).textTheme.titleMedium),
        const Column(
          children: [
            ExampleCard(text: 'Top'),
            SizedBox(height: 12),
            ExampleCard(text: 'Middle'),
            SizedBox(height: 12),
            ExampleCard(text: 'Bottom'),
          ],
        ),
        const Divider(),
        Text('HStack', style: Theme.of(context).textTheme.titleMedium),
        const Row(
          children: [
            Expanded(child: ExampleCard(text: 'One')),
            SizedBox(width: 12),
            Expanded(child: ExampleCard(text: 'Two')),
            SizedBox(width: 12),
            Expanded(child: ExampleCard(text: 'Three')),
          ],
        ),
        const Divider(),
        Text('ZStack', style: Theme.of(context).textTheme.titleMedium),
        SizedBox(
          height: 180,
          child: Stack(
            alignment: Alignment.center,
            children: [
              Container(
                decoration: BoxDecoration(
                  color: Colors.blue.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: Colors.blue.withValues(alpha: 0.45),
                  shape: BoxShape.circle,
                ),
              ),
              Text(
                'Layered content',
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class ScrollViewExampleView extends StatelessWidget {
  const ScrollViewExampleView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('ScrollView')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          for (var index = 1; index <= 12; index++) ...[
            ExampleCard(text: 'Scrollable item $index'),
            if (index < 12) const SizedBox(height: 12),
          ],
        ],
      ),
    );
  }
}

class LazyVStackExampleView extends StatelessWidget {
  const LazyVStackExampleView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('LazyVStack')),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: 20,
        separatorBuilder: (_, _) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          return Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                const Icon(Icons.layers),
                const SizedBox(width: 12),
                Text('Lazy row ${index + 1}'),
                const Spacer(),
              ],
            ),
          );
        },
      ),
    );
  }
}
