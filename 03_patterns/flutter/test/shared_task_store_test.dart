import 'package:flutter_test/flutter_test.dart';
import 'package:patterns/shared/storage/shared_task_store.dart';

void main() {
  group('Shared Task Store', () {
    test('Seeds default tasks once when flag is false', () {
      final seedFlags = SeedFlagStore();
      final sut = SharedTaskStore(seedFlags: seedFlags);

      final result = sut.fetchTasks();

      expect(result.map((task) => task.title), [
        'Plan sprint',
        'Write unit tests',
        'Review pull request',
      ]);
      expect(seedFlags.getBool(SharedTaskStore.seedPopulatedKey), isTrue);
    });

    test('Does not seed when flag is already true', () {
      final seedFlags = SeedFlagStore()
        ..setBool(SharedTaskStore.seedPopulatedKey, true);
      final sut = SharedTaskStore(seedFlags: seedFlags);

      expect(sut.fetchTasks(), isEmpty);
    });

    test('Create persists a new task', () {
      final seedFlags = SeedFlagStore()
        ..setBool(SharedTaskStore.seedPopulatedKey, true);
      final records = <SharedTaskRecord>[];
      final sut = SharedTaskStore(
        seedFlags: seedFlags,
        initialRecords: records,
      );

      sut.createTask(title: 'New task');

      final reloadedStore = SharedTaskStore(
        seedFlags: seedFlags,
        initialRecords: records,
      );

      expect(reloadedStore.fetchTasks().map((task) => task.title), [
        'New task',
      ]);
    });

    test('Delete removes the matching task', () {
      final seedFlags = SeedFlagStore()
        ..setBool(SharedTaskStore.seedPopulatedKey, true);
      final sut = SharedTaskStore(seedFlags: seedFlags);

      final createdTasks = sut.createTask(title: 'Delete me');
      final deletedTaskId = createdTasks.first.id;

      final result = sut.deleteTask(id: deletedTaskId);

      expect(result, isEmpty);
    });

    test('Does not duplicate seed when store is rebuilt with same flags', () {
      final seedFlags = SeedFlagStore();
      final records = <SharedTaskRecord>[];

      final firstStore = SharedTaskStore(
        seedFlags: seedFlags,
        initialRecords: records,
      );
      final secondStore = SharedTaskStore(
        seedFlags: seedFlags,
        initialRecords: records,
      );

      expect(firstStore.fetchTasks().length, 3);
      expect(secondStore.fetchTasks().length, 3);
    });
  });
}
