import 'package:flutter/material.dart';

import '../models/task_item.dart';

class TaskRow extends StatelessWidget {
  const TaskRow({super.key, required this.task});

  final TaskItem task;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: const Icon(Icons.checklist, color: Colors.blue),
      title: Text(task.title),
    );
  }
}
