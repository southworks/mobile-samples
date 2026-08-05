class TaskItem {
  const TaskItem({required this.id, required this.title});

  final String id;
  final String title;

  @override
  bool operator ==(Object other) {
    return other is TaskItem && other.id == id && other.title == title;
  }

  @override
  int get hashCode => Object.hash(id, title);
}
