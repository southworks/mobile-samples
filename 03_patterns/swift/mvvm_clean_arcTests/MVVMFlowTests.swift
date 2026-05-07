import Foundation
import SwiftData
import Testing
@testable import mvvm_clean_arc

@Suite("MVVM Flow")
struct MVVMFlowTests {
    @Test("Service maps shared records into task items")
    func serviceMapsSharedRecordsIntoTaskItems() throws {
        let sut = TaskService(store: try makeStore(tasks: ["Task A", "Task B"]))

        let result = sut.fetchTasks()

        #expect(result.count == 2)
        #expect(result.map(\.title) == ["Task A", "Task B"])
        #expect(Set(result.map(\.id)).count == 2)
    }

    @Test("View model loads tasks on init")
    @MainActor
    func viewModelLoadsTasksOnInit() throws {
        let store = try makeStore(tasks: ["Plan sprint", "Write tests"])
        let sut = MVVMTaskListViewModel(service: TaskService(store: store))

        #expect(sut.tasks.map(\.title) == ["Plan sprint", "Write tests"])
    }

    @Test("View model creates trimmed tasks")
    @MainActor
    func viewModelCreatesTrimmedTasks() throws {
        let store = try makeStore(tasks: [])
        let sut = MVVMTaskListViewModel(service: TaskService(store: store))

        sut.createTask(title: "  New task  ")

        #expect(sut.tasks.count == 1)
        #expect(sut.tasks.first?.title == "New task")
    }

    @Test("View model ignores blank task titles")
    @MainActor
    func viewModelIgnoresBlankTaskTitles() throws {
        let store = try makeStore(tasks: [])
        let sut = MVVMTaskListViewModel(service: TaskService(store: store))

        sut.createTask(title: "   ")

        #expect(sut.tasks.isEmpty)
    }

    @Test("View model deletes tasks by index set")
    @MainActor
    func viewModelDeletesTasksByIndexSet() throws {
        let store = try makeStore(tasks: ["Delete me", "Keep me"])
        let sut = MVVMTaskListViewModel(service: TaskService(store: store))

        sut.deleteTask(at: IndexSet(integer: 0))

        #expect(sut.tasks.count == 1)
        #expect(sut.tasks.first?.title == "Keep me")
    }

    private func makeStore(tasks: [String]) throws -> SharedTaskStore {
        let schema = Schema([SharedTaskRecord.self])
        let configuration = ModelConfiguration(isStoredInMemoryOnly: true)
        let modelContainer = try ModelContainer(for: schema, configurations: [configuration])
        let suiteName = "MVVMFlowTests-\(UUID().uuidString)"
        guard let userDefaults = UserDefaults(suiteName: suiteName) else {
            throw MVVMFlowTestError.failedToCreateUserDefaults
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

private enum MVVMFlowTestError: Error {
    case failedToCreateUserDefaults
}
