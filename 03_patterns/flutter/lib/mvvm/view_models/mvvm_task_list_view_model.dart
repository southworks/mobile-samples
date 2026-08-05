import 'package:flutter/foundation.dart';

import '../../shared/models/task_item.dart';
import '../services/task_service.dart';

class MVVMTaskListViewModel extends ChangeNotifier {
  MVVMTaskListViewModel({TaskService? service})
      : _service = service ?? TaskService() {
    loadTasks();
  }

  final TaskService _service;

  List<TaskItem> _tasks = const [];
  List<TaskItem> get tasks => List.unmodifiable(_tasks);

  void loadTasks() {
    _tasks = _service.fetchTasks();
    notifyListeners();
  }

  void createTask({required String title}) {
    final trimmedTitle = title.trim();
    if (trimmedTitle.isEmpty) {
      return;
    }

    _tasks = _service.createTask(title: trimmedTitle);
    notifyListeners();
  }

  void deleteTask({required int index}) {
    if (index < 0 || index >= _tasks.length) {
      return;
    }

    final taskId = _tasks[index].id;
    _tasks = _service.deleteTask(id: taskId);
    notifyListeners();
  }
}
