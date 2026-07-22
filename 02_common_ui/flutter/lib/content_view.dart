import 'package:flutter/material.dart';

import 'basics_tab_view.dart';
import 'inputs_tab_view.dart';
import 'layout_tab_view.dart';
import 'navigation_tab_view.dart';

class ContentView extends StatefulWidget {
  const ContentView({super.key});

  @override
  State<ContentView> createState() => _ContentViewState();
}

class _ContentViewState extends State<ContentView> {
  int currentIndex = 0;

  final pages = const [
    BasicsMenuView(),
    LayoutMenuView(),
    NavigationExamplesMenuView(),
    InputsMenuView(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: currentIndex,
        children: pages,
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: currentIndex,
        onDestinationSelected: (index) {
          setState(() => currentIndex = index);
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.auto_awesome_outlined),
            selectedIcon: Icon(Icons.auto_awesome),
            label: 'Basics',
          ),
          NavigationDestination(
            icon: Icon(Icons.grid_view_outlined),
            selectedIcon: Icon(Icons.grid_view),
            label: 'Layout',
          ),
          NavigationDestination(
            icon: Icon(Icons.alt_route_outlined),
            selectedIcon: Icon(Icons.alt_route),
            label: 'Navigation',
          ),
          NavigationDestination(
            icon: Icon(Icons.tune_outlined),
            selectedIcon: Icon(Icons.tune),
            label: 'Inputs',
          ),
        ],
      ),
    );
  }
}
