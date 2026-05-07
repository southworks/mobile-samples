import Foundation
import SwiftData
import Testing
@testable import mvvm_clean_arc

@Suite("Shared Task Store")
struct SharedTaskStoreTests {
    @Test("Seeds default tasks once when flag is false")
    func seedsDefaultTasksOnceWhenFlagIsFalse() throws {
        let userDefaults = try makeUserDefaults()
        let sut = SharedTaskStore(
            modelContainer: try makeModelContainer(),
            userDefaults: userDefaults
        )

        let result = sut.fetchTasks()

        #expect(result.map(\.title) == [
            "Plan sprint",
            "Write unit tests",
            "Review pull request"
        ])
        #expect(userDefaults.bool(forKey: SharedTaskStore.seedPopulatedKey))
    }

    @Test("Does not seed when flag is already true")
    func doesNotSeedWhenFlagIsAlreadyTrue() throws {
        let userDefaults = try makeUserDefaults()
        userDefaults.set(true, forKey: SharedTaskStore.seedPopulatedKey)

        let sut = SharedTaskStore(
            modelContainer: try makeModelContainer(),
            userDefaults: userDefaults
        )

        let result = sut.fetchTasks()

        #expect(result.isEmpty)
    }

    @Test("Create persists a new task")
    func createPersistsANewTask() throws {
        let userDefaults = try makeUserDefaults()
        userDefaults.set(true, forKey: SharedTaskStore.seedPopulatedKey)
        let modelContainer = try makeModelContainer()
        let sut = SharedTaskStore(
            modelContainer: modelContainer,
            userDefaults: userDefaults
        )

        _ = sut.createTask(title: "New task")

        let reloadedStore = SharedTaskStore(
            modelContainer: modelContainer,
            userDefaults: userDefaults
        )

        #expect(reloadedStore.fetchTasks().map(\.title) == ["New task"])
    }

    @Test("Delete removes the matching task")
    func deleteRemovesTheMatchingTask() throws {
        let userDefaults = try makeUserDefaults()
        userDefaults.set(true, forKey: SharedTaskStore.seedPopulatedKey)
        let sut = SharedTaskStore(
            modelContainer: try makeModelContainer(),
            userDefaults: userDefaults
        )

        let createdTasks = sut.createTask(title: "Delete me")
        let deletedTaskID = try #require(createdTasks.first?.id)

        let result = sut.deleteTask(id: deletedTaskID)

        #expect(result.isEmpty)
    }

    @Test("Does not duplicate seed when store is rebuilt")
    func doesNotDuplicateSeedWhenStoreIsRebuilt() throws {
        let userDefaults = try makeUserDefaults()
        let modelContainer = try makeModelContainer()

        let firstStore = SharedTaskStore(
            modelContainer: modelContainer,
            userDefaults: userDefaults
        )
        let secondStore = SharedTaskStore(
            modelContainer: modelContainer,
            userDefaults: userDefaults
        )

        #expect(firstStore.fetchTasks().count == 3)
        #expect(secondStore.fetchTasks().count == 3)
    }

    private func makeModelContainer() throws -> ModelContainer {
        let schema = Schema([SharedTaskRecord.self])
        let configuration = ModelConfiguration(isStoredInMemoryOnly: true)
        return try ModelContainer(for: schema, configurations: [configuration])
    }

    private func makeUserDefaults() throws -> UserDefaults {
        let suiteName = "SharedTaskStoreTests-\(UUID().uuidString)"
        guard let userDefaults = UserDefaults(suiteName: suiteName) else {
            throw TestError.failedToCreateUserDefaults
        }

        userDefaults.removePersistentDomain(forName: suiteName)
        return userDefaults
    }
}

private enum TestError: Error {
    case failedToCreateUserDefaults
}
