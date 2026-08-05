class SharedTaskRecord {
  SharedTaskRecord({
    required this.id,
    required this.title,
    required this.createdAt,
  });

  final String id;
  String title;
  final DateTime createdAt;
}

class SharedTaskSeed {
  const SharedTaskSeed({required this.title});

  final String title;
}

/// Simple injectable flag store, analogous to UserDefaults in the Swift sample.
class SeedFlagStore {
  final Map<String, bool> _values = {};

  bool getBool(String key) => _values[key] ?? false;

  void setBool(String key, bool value) => _values[key] = value;

  void clear() => _values.clear();
}

class SharedTaskStore {
  SharedTaskStore({
    SeedFlagStore? seedFlags,
    List<SharedTaskRecord>? initialRecords,
  }) : _seedFlags = seedFlags ?? SeedFlagStore(),
       // Keep the same list reference when provided so multiple store
       // instances can share persistence (mirrors a shared ModelContainer).
       _records = initialRecords ?? <SharedTaskRecord>[] {
    _populateSeedIfNeeded();
  }

  static const seedPopulatedKey = 'SeedPopulated';
  static const defaultTasks = [
    SharedTaskSeed(title: 'Plan sprint'),
    SharedTaskSeed(title: 'Write unit tests'),
    SharedTaskSeed(title: 'Review pull request'),
  ];

  static SharedTaskStore shared = SharedTaskStore();

  static void configureShared(SharedTaskStore store) {
    shared = store;
  }

  static void resetShared() {
    shared = SharedTaskStore();
  }

  final SeedFlagStore _seedFlags;
  final List<SharedTaskRecord> _records;
  int _idSequence = 0;

  List<SharedTaskRecord> fetchTasks() {
    final sorted = List<SharedTaskRecord>.from(_records)
      ..sort((a, b) => a.createdAt.compareTo(b.createdAt));
    return sorted;
  }

  List<SharedTaskRecord> createTask({required String title}) {
    _records.add(
      SharedTaskRecord(
        id: _nextId(),
        title: title,
        createdAt: DateTime.now(),
      ),
    );
    return fetchTasks();
  }

  List<SharedTaskRecord> deleteTask({required String id}) {
    _records.removeWhere((task) => task.id == id);
    return fetchTasks();
  }

  String _nextId() {
    _idSequence += 1;
    return 'task-$_idSequence-${DateTime.now().microsecondsSinceEpoch}';
  }

  void _populateSeedIfNeeded() {
    if (_seedFlags.getBool(seedPopulatedKey)) {
      return;
    }

    for (final task in defaultTasks) {
      _records.add(
        SharedTaskRecord(
          id: _nextId(),
          title: task.title,
          createdAt: DateTime.now(),
        ),
      );
    }

    _seedFlags.setBool(seedPopulatedKey, true);
  }
}
