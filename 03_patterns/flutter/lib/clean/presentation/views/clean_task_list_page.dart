import 'package:flutter/material.dart';

import '../../../shared/ui/task_row.dart';
import '../view_models/clean_task_list_view_model.dart';

class CleanTaskListPage extends StatefulWidget {
  const CleanTaskListPage({super.key, required this.viewModel});

  final CleanTaskListViewModel viewModel;

  @override
  State<CleanTaskListPage> createState() => _CleanTaskListPageState();
}

class _CleanTaskListPageState extends State<CleanTaskListPage> {
  @override
  void initState() {
    super.initState();
    widget.viewModel.loadTasks();
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
              const Text('Add a new task through the use cases.'),
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
      widget.viewModel.createTask(title: controller.text);
    }

    controller.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: widget.viewModel,
      builder: (context, _) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('Clean Arc'),
            actions: [
              IconButton(
                onPressed: _showCreateTaskDialog,
                icon: const Icon(Icons.add),
                tooltip: 'Create task',
              ),
            ],
          ),
          body: widget.viewModel.tasks.isEmpty
              ? const Center(child: Text('No tasks yet'))
              : ListView.builder(
                  itemCount: widget.viewModel.tasks.length,
                  itemBuilder: (context, index) {
                    final task = widget.viewModel.tasks[index];
                    return Dismissible(
                      key: ValueKey(task.id),
                      direction: DismissDirection.endToStart,
                      background: Container(
                        color: Colors.red,
                        alignment: Alignment.centerRight,
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: const Icon(Icons.delete, color: Colors.white),
                      ),
                      onDismissed: (_) {
                        widget.viewModel.deleteTask(index: index);
                      },
                      child: TaskRow(task: task),
                    );
                  },
                ),
        );
      },
    );
  }
}
