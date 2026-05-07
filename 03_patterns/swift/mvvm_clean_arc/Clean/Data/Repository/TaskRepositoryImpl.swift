import Foundation

final class TaskRepositoryImpl: TaskRepository {
    private let localDataSource: TaskLocalDataSource

    init(localDataSource: TaskLocalDataSource) {
        self.localDataSource = localDataSource
    }

    func getTasks() -> [Task] {
        localDataSource.fetchTasks()
    }

    func createTask(title: String) -> [Task] {
        localDataSource.saveTask(title: title)
    }

    func deleteTask(id: UUID) -> [Task] {
        localDataSource.removeTask(id: id)
    }
}
