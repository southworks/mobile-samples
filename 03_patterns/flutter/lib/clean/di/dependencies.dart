import '../data/data_source/task_local_data_source.dart';
import '../data/repository/task_repository_impl.dart';
import '../domain/use_cases/create_task_use_case.dart';
import '../domain/use_cases/delete_task_use_case.dart';
import '../domain/use_cases/get_tasks_use_case.dart';
import '../presentation/view_models/clean_task_list_view_model.dart';

class Dependencies {
  static CleanTaskListViewModel makeTaskListViewModel() {
    final localDataSource = TaskLocalDataSource();
    final repository = TaskRepositoryImpl(localDataSource: localDataSource);

    return CleanTaskListViewModel(
      getTasksUseCase: GetTasksUseCase(repository: repository),
      createTaskUseCase: CreateTaskUseCase(repository: repository),
      deleteTaskUseCase: DeleteTaskUseCase(repository: repository),
    );
  }
}
