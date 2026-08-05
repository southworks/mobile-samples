import '../../../shared/storage/shared_task_store.dart';
import '../../domain/entities/task.dart';

class TaskLocalDataSource {
  TaskLocalDataSource({SharedTaskStore? store})
      : _store = store ?? SharedTaskStore.shared;

  final SharedTaskStore _store;

  List<Task> fetchTasks() {
    return _store.fetchTasks().map(_asTask).toList();
  }

  List<Task> saveTask({required String title}) {
    return _store.createTask(title: title).map(_asTask).toList();
  }

  List<Task> removeTask({required String id}) {
    return _store.deleteTask(id: id).map(_asTask).toList();
  }

  Task _asTask(SharedTaskRecord record) {
    return Task(id: record.id, title: record.title);
  }
}
