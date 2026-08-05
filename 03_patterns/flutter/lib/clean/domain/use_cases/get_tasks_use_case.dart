import '../entities/task.dart';
import '../repositories/task_repository.dart';

class GetTasksUseCase {
  const GetTasksUseCase({required TaskRepository repository})
      : _repository = repository;

  final TaskRepository _repository;

  List<Task> execute() => _repository.getTasks();
}
