import Foundation

enum Dependencies {
    static func makeTaskListViewModel() -> CleanTaskListViewModel {
        let localDataSource = TaskLocalDataSource()
        let repository = TaskRepositoryImpl(localDataSource: localDataSource)

        return CleanTaskListViewModel(
            getTasksUseCase: GetTasksUseCase(repository: repository),
            createTaskUseCase: CreateTaskUseCase(repository: repository),
            deleteTaskUseCase: DeleteTaskUseCase(repository: repository)
        )
    }
}
