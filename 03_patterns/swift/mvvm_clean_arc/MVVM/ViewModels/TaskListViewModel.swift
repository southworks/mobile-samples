import Foundation

@MainActor
final class MVVMTaskListViewModel: ObservableObject {
    @Published private(set) var tasks: [TaskItem] = []

    private let service: TaskService

    init(service: TaskService = TaskService()) {
        self.service = service
        loadTasks()
    }

    func loadTasks() {
        tasks = service.fetchTasks()
    }

    func createTask(title: String) {
        let trimmedTitle = title.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedTitle.isEmpty else { return }

        tasks = service.createTask(title: trimmedTitle)
    }

    func deleteTask(at offsets: IndexSet) {
        let selectedTaskIDs = offsets.map { tasks[$0].id }

        for taskID in selectedTaskIDs {
            tasks = service.deleteTask(id: taskID)
        }
    }
}
