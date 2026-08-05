import '../entities/task.dart';

abstract class TaskRepository {
  List<Task> getTasks();
  List<Task> createTask({required String title});
  List<Task> deleteTask({required String id});
}
