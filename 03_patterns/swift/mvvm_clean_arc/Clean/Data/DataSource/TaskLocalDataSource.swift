import Foundation

final class TaskLocalDataSource {
    private let store: SharedTaskStore

    init(store: SharedTaskStore = .shared) {
        self.store = store
    }

    func fetchTasks() -> [Task] {
        store.fetchTasks().map(\.asTask)
    }

    func saveTask(title: String) -> [Task] {
        store.createTask(title: title).map(\.asTask)
    }

    func removeTask(id: UUID) -> [Task] {
        store.deleteTask(id: id).map(\.asTask)
    }
}

private extension SharedTaskRecord {
    var asTask: Task {
        Task(id: id, title: title)
    }
}
