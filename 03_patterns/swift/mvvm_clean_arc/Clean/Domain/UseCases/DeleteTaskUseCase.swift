import Foundation

struct DeleteTaskUseCase {
    private let repository: TaskRepository

    init(repository: TaskRepository) {
        self.repository = repository
    }

    func execute(id: UUID) -> [Task] {
        repository.deleteTask(id: id)
    }
}
