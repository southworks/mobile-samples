import 'package:flutter/material.dart';

import '../clean/di/dependencies.dart';
import '../clean/presentation/views/clean_task_list_page.dart';
import '../mvvm/views/mvvm_task_list_page.dart';

class RootPage extends StatelessWidget {
  const RootPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Task Manager')),
      body: ListView(
        children: [
          ListTile(
            title: const Text('MVVM Task Manager'),
            subtitle: const Text('View + ViewModel + Service'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => const MVVMTaskListPage(),
                ),
              );
            },
          ),
          ListTile(
            title: const Text('Clean Arc Task Manager'),
            subtitle: const Text('Domain + Data + Presentation'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => CleanTaskListPage(
                    viewModel: Dependencies.makeTaskListViewModel(),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
