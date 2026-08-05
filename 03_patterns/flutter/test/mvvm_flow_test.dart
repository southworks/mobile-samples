import 'package:flutter_test/flutter_test.dart';
import 'package:patterns/mvvm/services/task_service.dart';
import 'package:patterns/mvvm/view_models/mvvm_task_list_view_model.dart';
import 'package:patterns/shared/storage/shared_task_store.dart';

void main() {
  group('MVVM Flow', () {
    test('Service maps shared records into task items', () {
      final store = _makeStore(tasks: ['Task A', 'Task B']);
      final sut = TaskService(store: store);

      final result = sut.fetchTasks();

      expect(result.length, 2);
      expect(result.map((task) => task.title), ['Task A', 'Task B']);
      expect(result.map((task) => task.id).toSet().length, 2);
    });

    test('View model loads tasks on init', () {
      final store = _makeStore(tasks: ['Plan sprint', 'Write tests']);
      final sut = MVVMTaskListViewModel(service: TaskService(store: store));

      expect(sut.tasks.map((task) => task.title), [
        'Plan sprint',
        'Write tests',
      ]);
    });

    test('View model creates trimmed tasks', () {
      final store = _makeStore(tasks: []);
      final sut = MVVMTaskListViewModel(service: TaskService(store: store));

      sut.createTask(title: '  New task  ');

      expect(sut.tasks.length, 1);
      expect(sut.tasks.first.title, 'New task');
    });

    test('View model ignores blank task titles', () {
      final store = _makeStore(tasks: []);
      final sut = MVVMTaskListViewModel(service: TaskService(store: store));

      sut.createTask(title: '   ');

      expect(sut.tasks, isEmpty);
    });

    test('View model deletes tasks by index', () {
      final store = _makeStore(tasks: ['Delete me', 'Keep me']);
      final sut = MVVMTaskListViewModel(service: TaskService(store: store));

      sut.deleteTask(index: 0);

      expect(sut.tasks.length, 1);
      expect(sut.tasks.first.title, 'Keep me');
    });
  });
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
