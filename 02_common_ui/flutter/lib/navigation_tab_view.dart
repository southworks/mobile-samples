import 'package:flutter/material.dart';

import 'shared_example_views.dart';

class NavigationExamplesMenuView extends StatelessWidget {
  const NavigationExamplesMenuView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Navigation')),
      body: ListView(
        children: [
          const Padding(
            padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Text(
              'Planets',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
          ListTile(
            title: const Text('Mercury'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => const DetailMessageView(
                    title: 'Mercury',
                    message:
                        'Mercury is the smallest planet in our solar system.',
                  ),
                ),
              );
            },
          ),
          ListTile(
            title: const Text('Venus'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => const DetailMessageView(
                    title: 'Venus',
                    message: 'Venus is the second planet from the Sun.',
                  ),
                ),
              );
            },
          ),
          const Padding(
            padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Text(
              'Stars',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
          ListTile(
            title: const Text('Sun'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => const DetailMessageView(
                    title: 'Sun',
                    message:
                        'Sun is the star at the center of our solar system.',
                  ),
                ),
              );
            },
          ),
          ListTile(
            title: const Text('Open sheet'),
            onTap: () => _openSheet(context),
          ),
        ],
      ),
    );
  }

  void _openSheet(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (sheetContext) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('Sheet'),
            automaticallyImplyLeading: false,
            actions: [
              TextButton(
                onPressed: () => Navigator.of(sheetContext).pop(),
                child: const Text('Done'),
              ),
            ],
          ),
          body: ListView(
            children: [
              const Padding(
                padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
                child: Text(
                  'Elements',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
              ),
              for (var i = 0; i < 10; i++)
                ListTile(
                  title: Text('Element $i'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    Navigator.of(sheetContext).push(
                      MaterialPageRoute(
                        builder: (_) => DetailMessageView(
                          title: 'Navigation $i',
                          message: 'Detail message for navigation $i.',
                        ),
                      ),
                    );
                  },
                ),
            ],
          ),
        );
      },
    );
  }
}
