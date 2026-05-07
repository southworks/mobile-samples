import Foundation

protocol TaskRepository {
    func getTasks() -> [Task]
    func createTask(title: String) -> [Task]
    func deleteTask(id: UUID) -> [Task]
}

struct GetTasksUseCase {
    private let repository: TaskRepository

    init(repository: TaskRepository) {
        self.repository = repository
    }

    func execute() -> [Task] {
        repository.getTasks()
    }
}
