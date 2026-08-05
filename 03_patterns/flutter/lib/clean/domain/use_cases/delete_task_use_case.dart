import '../entities/task.dart';
import '../repositories/task_repository.dart';

class DeleteTaskUseCase {
  const DeleteTaskUseCase({required TaskRepository repository})
      : _repository = repository;

  final TaskRepository _repository;

  List<Task> execute({required String id}) {
    return _repository.deleteTask(id: id);
  }
}
