import 'package:flutter/material.dart';

import '../../shared/ui/task_row.dart';
import '../view_models/mvvm_task_list_view_model.dart';

class MVVMTaskListPage extends StatefulWidget {
  const MVVMTaskListPage({super.key, this.viewModel});

  final MVVMTaskListViewModel? viewModel;

  @override
  State<MVVMTaskListPage> createState() => _MVVMTaskListPageState();
}

class _MVVMTaskListPageState extends State<MVVMTaskListPage> {
  late final MVVMTaskListViewModel _viewModel;
  late final bool _ownsViewModel;

  @override
  void initState() {
    super.initState();
    _ownsViewModel = widget.viewModel == null;
    _viewModel = widget.viewModel ?? MVVMTaskListViewModel();
  }

  @override
  void dispose() {
    if (_ownsViewModel) {
      _viewModel.dispose();
    }
    super.dispose();
  }

  Future<void> _showCreateTaskDialog() async {
    final controller = TextEditingController();

    final shouldCreate = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Create Task'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Add a new task to the MVVM list.'),
              const SizedBox(height: 12),
              TextField(
                controller: controller,
                autofocus: true,
                decoration: const InputDecoration(
                  labelText: 'Task title',
                  border: OutlineInputBorder(),
                ),
                onSubmitted: (_) => Navigator.of(context).pop(true),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Create'),
            ),
          ],
        );
      },
    );

    if (shouldCreate == true) {
      _viewModel.createTask(title: controller.text);
    }

    controller.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _viewModel,
      builder: (context, _) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('MVVM'),
            actions: [
              IconButton(
                onPressed: _showCreateTaskDialog,
                icon: const Icon(Icons.add),
                tooltip: 'Create task',
              ),
            ],
          ),
          body: _viewModel.tasks.isEmpty
              ? const Center(child: Text('No tasks yet'))
              : ListView.builder(
                  itemCount: _viewModel.tasks.length,
                  itemBuilder: (context, index) {
                    final task = _viewModel.tasks[index];
                    return Dismissible(
                      key: ValueKey(task.id),
                      direction: DismissDirection.endToStart,
                      background: Container(
                        color: Colors.red,
                        alignment: Alignment.centerRight,
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: const Icon(Icons.delete, color: Colors.white),
                      ),
                      onDismissed: (_) => _viewModel.deleteTask(index: index),
                      child: TaskRow(task: task),
                    );
                  },
                ),
        );
      },
    );
  }
}
