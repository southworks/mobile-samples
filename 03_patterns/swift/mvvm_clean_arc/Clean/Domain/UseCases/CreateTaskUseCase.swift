import Foundation

struct CreateTaskUseCase {
    private let repository: TaskRepository

    init(repository: TaskRepository) {
        self.repository = repository
    }

    func execute(title: String) -> [Task] {
        repository.createTask(title: title)
    }
}
