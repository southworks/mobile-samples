import Foundation

final class TaskService {
    private let store: SharedTaskStore

    init(store: SharedTaskStore = .shared) {
        self.store = store
    }

    func fetchTasks() -> [TaskItem] {
        store.fetchTasks().map(\.asTaskItem)
    }

    func createTask(title: String) -> [TaskItem] {
        store.createTask(title: title).map(\.asTaskItem)
    }

    func deleteTask(id: UUID) -> [TaskItem] {
        store.deleteTask(id: id).map(\.asTaskItem)
    }
}

private extension SharedTaskRecord {
    var asTaskItem: TaskItem {
        TaskItem(id: id, title: title)
    }
}
