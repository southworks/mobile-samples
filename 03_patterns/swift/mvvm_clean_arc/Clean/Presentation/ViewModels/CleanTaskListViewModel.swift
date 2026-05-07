import Combine
import Foundation

@MainActor
final class CleanTaskListViewModel: ObservableObject {
    @Published private(set) var tasks: [TaskItem] = []

    private let getTasksUseCase: GetTasksUseCase
    private let createTaskUseCase: CreateTaskUseCase
    private let deleteTaskUseCase: DeleteTaskUseCase
    private let taskItemMapper: TaskItemMapper

    init(
        getTasksUseCase: GetTasksUseCase,
        createTaskUseCase: CreateTaskUseCase,
        deleteTaskUseCase: DeleteTaskUseCase,
        taskItemMapper: TaskItemMapper = TaskItemMapper()
    ) {
        self.getTasksUseCase = getTasksUseCase
        self.createTaskUseCase = createTaskUseCase
        self.deleteTaskUseCase = deleteTaskUseCase
        self.taskItemMapper = taskItemMapper
        loadTasks()
    }

    func loadTasks() {
        tasks = taskItemMapper.map(getTasksUseCase.execute())
    }

    func createTask(title: String) {
        let trimmedTitle = title.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedTitle.isEmpty else { return }

        tasks = taskItemMapper.map(createTaskUseCase.execute(title: trimmedTitle))
    }

    func deleteTask(at offsets: IndexSet) {
        let selectedTaskIDs = offsets.map { tasks[$0].id }

        for taskID in selectedTaskIDs {
            tasks = taskItemMapper.map(deleteTaskUseCase.execute(id: taskID))
        }
    }
}
