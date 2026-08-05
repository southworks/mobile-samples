import 'package:flutter/foundation.dart';

import '../../../shared/models/task_item.dart';
import '../../domain/use_cases/create_task_use_case.dart';
import '../../domain/use_cases/delete_task_use_case.dart';
import '../../domain/use_cases/get_tasks_use_case.dart';
import '../mappers/task_item_mapper.dart';

class CleanTaskListViewModel extends ChangeNotifier {
  CleanTaskListViewModel({
    required GetTasksUseCase getTasksUseCase,
    required CreateTaskUseCase createTaskUseCase,
    required DeleteTaskUseCase deleteTaskUseCase,
    TaskItemMapper taskItemMapper = const TaskItemMapper(),
  }) : _getTasksUseCase = getTasksUseCase,
       _createTaskUseCase = createTaskUseCase,
       _deleteTaskUseCase = deleteTaskUseCase,
       _taskItemMapper = taskItemMapper {
    loadTasks();
  }

  final GetTasksUseCase _getTasksUseCase;
  final CreateTaskUseCase _createTaskUseCase;
  final DeleteTaskUseCase _deleteTaskUseCase;
  final TaskItemMapper _taskItemMapper;

  List<TaskItem> _tasks = const [];
  List<TaskItem> get tasks => List.unmodifiable(_tasks);

  void loadTasks() {
    _tasks = _taskItemMapper.mapList(_getTasksUseCase.execute());
    notifyListeners();
  }

  void createTask({required String title}) {
    final trimmedTitle = title.trim();
    if (trimmedTitle.isEmpty) {
      return;
    }

    _tasks = _taskItemMapper.mapList(
      _createTaskUseCase.execute(title: trimmedTitle),
    );
    notifyListeners();
  }

  void deleteTask({required int index}) {
    if (index < 0 || index >= _tasks.length) {
      return;
    }

    final taskId = _tasks[index].id;
    _tasks = _taskItemMapper.mapList(
      _deleteTaskUseCase.execute(id: taskId),
    );
    notifyListeners();
  }
}
