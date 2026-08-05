import '../../../shared/models/task_item.dart';
import '../../domain/entities/task.dart';

class TaskItemMapper {
  const TaskItemMapper();

  TaskItem map(Task task) {
    return TaskItem(id: task.id, title: task.title);
  }

  List<TaskItem> mapList(List<Task> tasks) {
    return tasks.map(map).toList();
  }
}
