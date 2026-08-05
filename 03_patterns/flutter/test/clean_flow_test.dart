import 'package:flutter_test/flutter_test.dart';
import 'package:patterns/clean/data/data_source/task_local_data_source.dart';
import 'package:patterns/clean/data/repository/task_repository_impl.dart';
import 'package:patterns/clean/domain/entities/task.dart';
import 'package:patterns/clean/domain/repositories/task_repository.dart';
import 'package:patterns/clean/domain/use_cases/create_task_use_case.dart';
import 'package:patterns/clean/domain/use_cases/delete_task_use_case.dart';
import 'package:patterns/clean/domain/use_cases/get_tasks_use_case.dart';
import 'package:patterns/clean/presentation/mappers/task_item_mapper.dart';
import 'package:patterns/clean/presentation/view_models/clean_task_list_view_model.dart';
import 'package:patterns/shared/storage/shared_task_store.dart';

void main() {
  group('Clean Flow', () {
    test('Mapper converts a domain task into presentation data', () {
      const task = Task(id: '1', title: 'Review PR');
      const sut = TaskItemMapper();

      final result = sut.map(task);

      expect(result.id, task.id);
      expect(result.title, 'Review PR');
    });

    test('Data source uses the shared store contract', () {
      final store = _makeStore(tasks: []);
      final sut = TaskLocalDataSource(store: store);

      final createdTasks = sut.saveTask(title: 'New task');
      final remainingTasks = sut.removeTask(id: createdTasks[0].id);

      expect(createdTasks.length, 1);
      expect(createdTasks.first.title, 'New task');
      expect(remainingTasks, isEmpty);
    });

    test('Repository delegates CRUD operations to the data source', () {
      final store = _makeStore(tasks: []);
      final dataSource = TaskLocalDataSource(store: store);
      final sut = TaskRepositoryImpl(localDataSource: dataSource);

      final createdTasks = sut.createTask(title: 'Task from repository');
      final fetchedTasks = sut.getTasks();
      final remainingTasks = sut.deleteTask(id: createdTasks[0].id);

      expect(createdTasks.length, 1);
      expect(fetchedTasks.length, 1);
      expect(fetchedTasks.first.title, 'Task from repository');
      expect(remainingTasks, isEmpty);
    });

    test('Use cases call the repository and return repository results', () {
      final repository = SpyTaskRepository(
        tasks: [const Task(id: '1', title: 'Existing task')],
      );
      final getTasksUseCase = GetTasksUseCase(repository: repository);
      final createTaskUseCase = CreateTaskUseCase(repository: repository);
      final deleteTaskUseCase = DeleteTaskUseCase(repository: repository);

      final fetchedTasks = getTasksUseCase.execute();
      final createdTasks = createTaskUseCase.execute(title: 'Created task');
      final deletedTasks = deleteTaskUseCase.execute(id: createdTasks[1].id);

      expect(repository.didCallGetTasks, isTrue);
      expect(repository.createdTitles, ['Created task']);
      expect(repository.deletedIds, [createdTasks[1].id]);
      expect(fetchedTasks.length, 1);
      expect(createdTasks.length, 2);
      expect(deletedTasks.length, 1);
    });

    test('Clean view model loads tasks on init', () {
      final sut = _makeViewModel(
        tasks: [
          const Task(id: '1', title: 'Task A'),
          const Task(id: '2', title: 'Task B'),
        ],
      );

      expect(sut.tasks.map((task) => task.title), ['Task A', 'Task B']);
    });

    test('Clean view model creates trimmed tasks', () {
      final sut = _makeViewModel(tasks: []);

      sut.createTask(title: '  New clean task  ');

      expect(sut.tasks.length, 1);
      expect(sut.tasks.first.title, 'New clean task');
    });

    test('Clean view model ignores blank task titles', () {
      final sut = _makeViewModel(tasks: []);

      sut.createTask(title: '   ');

      expect(sut.tasks, isEmpty);
    });

    test('Clean view model deletes tasks by index', () {
      const deletedTaskId = 'delete-me';
      final sut = _makeViewModel(
        tasks: [
          const Task(id: deletedTaskId, title: 'Delete me'),
          const Task(id: 'keep-me', title: 'Keep me'),
        ],
      );

      sut.deleteTask(index: 0);

      expect(sut.tasks.length, 1);
      expect(sut.tasks.any((task) => task.id == deletedTaskId), isFalse);
      expect(sut.tasks.first.title, 'Keep me');
    });
  });
}

CleanTaskListViewModel _makeViewModel({required List<Task> tasks}) {
  final repository = SpyTaskRepository(tasks: tasks);

  return CleanTaskListViewModel(
    getTasksUseCase: GetTasksUseCase(repository: repository),
    createTaskUseCase: CreateTaskUseCase(repository: repository),
    deleteTaskUseCase: DeleteTaskUseCase(repository: repository),
  );
}

SharedTaskStore _makeStore({required List<String> tasks}) {
  final seedFlags = SeedFlagStore()
    ..setBool(SharedTaskStore.seedPopulatedKey, true);
  final store = SharedTaskStore(seedFlags: seedFlags);

  for (final title in tasks) {
    store.createTask(title: title);
  }

  return store;
}

class SpyTaskRepository implements TaskRepository {
  SpyTaskRepository({required List<Task> tasks}) : _tasks = List.of(tasks);

  final List<Task> _tasks;
  bool didCallGetTasks = false;
  final List<String> createdTitles = [];
  final List<String> deletedIds = [];
  int _idSequence = 0;

  @override
  List<Task> getTasks() {
    didCallGetTasks = true;
    return List.of(_tasks);
  }

  @override
  List<Task> createTask({required String title}) {
    createdTitles.add(title);
    _idSequence += 1;
    _tasks.add(Task(id: 'spy-$_idSequence', title: title));
    return List.of(_tasks);
  }

  @override
  List<Task> deleteTask({required String id}) {
    deletedIds.add(id);
    _tasks.removeWhere((task) => task.id == id);
    return List.of(_tasks);
  }
}
