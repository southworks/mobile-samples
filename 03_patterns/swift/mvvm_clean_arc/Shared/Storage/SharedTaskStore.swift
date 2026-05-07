import Foundation

struct SharedTaskRecord: Identifiable, Equatable {
    let id: UUID
    let title: String
}

final class SharedTaskStore {
    static let shared = SharedTaskStore()

    static let defaultTasks: [SharedTaskRecord] = [
        SharedTaskRecord(id: UUID(), title: "Plan sprint"),
        SharedTaskRecord(id: UUID(), title: "Write unit tests"),
        SharedTaskRecord(id: UUID(), title: "Review pull request")
    ]

    private var tasks: [SharedTaskRecord]

    init(tasks: [SharedTaskRecord] = SharedTaskStore.defaultTasks) {
        self.tasks = tasks
    }

    func fetchTasks() -> [SharedTaskRecord] {
        tasks
    }

    func createTask(title: String) -> [SharedTaskRecord] {
        let task = SharedTaskRecord(id: UUID(), title: title)
        tasks.append(task)
        return tasks
    }

    func deleteTask(id: UUID) -> [SharedTaskRecord] {
        tasks.removeAll { $0.id == id }
        return tasks
    }
}
