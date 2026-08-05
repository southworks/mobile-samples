import '../../shared/models/task_item.dart';
import '../../shared/storage/shared_task_store.dart';

class TaskService {
  TaskService({SharedTaskStore? store}) : _store = store ?? SharedTaskStore.shared;

  final SharedTaskStore _store;

  List<TaskItem> fetchTasks() {
    return _store.fetchTasks().map(_asTaskItem).toList();
  }

  List<TaskItem> createTask({required String title}) {
    return _store.createTask(title: title).map(_asTaskItem).toList();
  }

  List<TaskItem> deleteTask({required String id}) {
    return _store.deleteTask(id: id).map(_asTaskItem).toList();
  }

  TaskItem _asTaskItem(SharedTaskRecord record) {
    return TaskItem(id: record.id, title: record.title);
  }
}
