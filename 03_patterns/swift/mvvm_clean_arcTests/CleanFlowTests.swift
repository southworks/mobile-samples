import Foundation
import SwiftData
import Testing
@testable import mvvm_clean_arc

@Suite("Clean Flow")
struct CleanFlowTests {
    @Test("Mapper converts a domain task into presentation data")
    func mapperConvertsDomainTaskIntoPresentationData() {
        let task = Task(id: UUID(), title: "Review PR")
        let sut = TaskItemMapper()

        let result = sut.map(task)

        #expect(result.id == task.id)
        #expect(result.title == "Review PR")
    }

    @Test("Data source uses the shared store contract")
    func dataSourceUsesTheSharedStoreContract() throws {
        let store = try makeStore(tasks: [])
        let sut = TaskLocalDataSource(store: store)

        let createdTasks = sut.saveTask(title: "New task")
        let remainingTasks = sut.removeTask(id: createdTasks[0].id)

        #expect(createdTasks.count == 1)
        #expect(createdTasks.first?.title == "New task")
        #expect(remainingTasks.isEmpty)
    }

    @Test("Repository delegates CRUD operations to the data source")
    func repositoryDelegatesCrudOperationsToTheDataSource() throws {
        let store = try makeStore(tasks: [])
        let dataSource = TaskLocalDataSource(store: store)
        let sut = TaskRepositoryImpl(localDataSource: dataSource)

        let createdTasks = sut.createTask(title: "Task from repository")
        let fetchedTasks = sut.getTasks()
        let remainingTasks = sut.deleteTask(id: createdTasks[0].id)

        #expect(createdTasks.count == 1)
        #expect(fetchedTasks.count == 1)
        #expect(fetchedTasks.first?.title == "Task from repository")
        #expect(remainingTasks.isEmpty)
    }

    @Test("Use cases call the repository and return repository results")
    func useCasesCallTheRepositoryAndReturnRepositoryResults() {
        let repository = SpyTaskRepository(tasks: [Task(id: UUID(), title: "Existing task")])
        let getTasksUseCase = GetTasksUseCase(repository: repository)
        let createTaskUseCase = CreateTaskUseCase(repository: repository)
        let deleteTaskUseCase = DeleteTaskUseCase(repository: repository)

        let fetchedTasks = getTasksUseCase.execute()
        let createdTasks = createTaskUseCase.execute(title: "Created task")
        let deletedTasks = deleteTaskUseCase.execute(id: createdTasks[1].id)

        #expect(repository.didCallGetTasks)
        #expect(repository.createdTitles == ["Created task"])
        #expect(repository.deletedIDs == [createdTasks[1].id])
        #expect(fetchedTasks.count == 1)
        #expect(createdTasks.count == 2)
        #expect(deletedTasks.count == 1)
    }

    @Test("Clean view model loads tasks on init")
    @MainActor
    func viewModelLoadsTasksOnInit() throws {
        let sut = try makeViewModel(tasks: [
            Task(id: UUID(), title: "Task A"),
            Task(id: UUID(), title: "Task B")
        ])

        #expect(sut.tasks.map(\.title) == ["Task A", "Task B"])
    }

    @Test("Clean view model creates trimmed tasks")
    @MainActor
    func viewModelCreatesTrimmedTasks() throws {
        let sut = try makeViewModel(tasks: [])

        sut.createTask(title: "  New clean task  ")

        #expect(sut.tasks.count == 1)
        #expect(sut.tasks.first?.title == "New clean task")
    }

    @Test("Clean view model ignores blank task titles")
    @MainActor
    func viewModelIgnoresBlankTaskTitles() throws {
        let sut = try makeViewModel(tasks: [])

        sut.createTask(title: "   ")

        #expect(sut.tasks.isEmpty)
    }

    @Test("Clean view model deletes tasks by index set")
    @MainActor
    func viewModelDeletesTasksByIndexSet() throws {
        let deletedTaskID = UUID()
        let sut = try makeViewModel(tasks: [
            Task(id: deletedTaskID, title: "Delete me"),
            Task(id: UUID(), title: "Keep me")
        ])

        sut.deleteTask(at: IndexSet(integer: 0))

        #expect(sut.tasks.count == 1)
        #expect(sut.tasks.contains { $0.id == deletedTaskID } == false)
        #expect(sut.tasks.first?.title == "Keep me")
    }

    @MainActor
    private func makeViewModel(tasks: [Task]) throws -> CleanTaskListViewModel {
        let repository = SpyTaskRepository(tasks: tasks)

        return CleanTaskListViewModel(
            getTasksUseCase: GetTasksUseCase(repository: repository),
            createTaskUseCase: CreateTaskUseCase(repository: repository),
            deleteTaskUseCase: DeleteTaskUseCase(repository: repository),
            taskItemMapper: TaskItemMapper()
        )
    }

    private func makeStore(tasks: [String]) throws -> SharedTaskStore {
        let schema = Schema([SharedTaskRecord.self])
        let configuration = ModelConfiguration(isStoredInMemoryOnly: true)
        let modelContainer = try ModelContainer(for: schema, configurations: [configuration])
        let suiteName = "CleanFlowTests-\(UUID().uuidString)"
        guard let userDefaults = UserDefaults(suiteName: suiteName) else {
            throw CleanFlowTestError.failedToCreateUserDefaults
        }

        userDefaults.removePersistentDomain(forName: suiteName)
        userDefaults.set(true, forKey: SharedTaskStore.seedPopulatedKey)

        let store = SharedTaskStore(
            modelContainer: modelContainer,
            userDefaults: userDefaults
        )

        for title in tasks {
            _ = store.createTask(title: title)
        }

        return store
    }
}

private enum CleanFlowTestError: Error {
    case failedToCreateUserDefaults
}

private final class SpyTaskRepository: TaskRepository {
    private(set) var tasks: [Task]
    private(set) var didCallGetTasks = false
    private(set) var createdTitles: [String] = []
    private(set) var deletedIDs: [UUID] = []

    init(tasks: [Task]) {
        self.tasks = tasks
    }

    func getTasks() -> [Task] {
        didCallGetTasks = true
        return tasks
    }

    func createTask(title: String) -> [Task] {
        createdTitles.append(title)
        tasks.append(Task(id: UUID(), title: title))
        return tasks
    }

    func deleteTask(id: UUID) -> [Task] {
        deletedIDs.append(id)
        tasks.removeAll { $0.id == id }
        return tasks
    }
}
