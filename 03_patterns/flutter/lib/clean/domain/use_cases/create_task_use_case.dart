import '../entities/task.dart';
import '../repositories/task_repository.dart';

class CreateTaskUseCase {
  const CreateTaskUseCase({required TaskRepository repository})
      : _repository = repository;

  final TaskRepository _repository;

  List<Task> execute({required String title}) {
    return _repository.createTask(title: title);
  }
}
