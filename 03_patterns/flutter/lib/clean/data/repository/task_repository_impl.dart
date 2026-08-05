import '../../domain/entities/task.dart';
import '../../domain/repositories/task_repository.dart';
import '../data_source/task_local_data_source.dart';

class TaskRepositoryImpl implements TaskRepository {
  TaskRepositoryImpl({required TaskLocalDataSource localDataSource})
      : _localDataSource = localDataSource;

  final TaskLocalDataSource _localDataSource;

  @override
  List<Task> getTasks() => _localDataSource.fetchTasks();

  @override
  List<Task> createTask({required String title}) {
    return _localDataSource.saveTask(title: title);
  }

  @override
  List<Task> deleteTask({required String id}) {
    return _localDataSource.removeTask(id: id);
  }
}
