import Foundation
import SwiftData

@Model
final class SharedTaskRecord: Identifiable {
    let id: UUID
    var title: String
    let createdAt: Date

    init(id: UUID = UUID(), title: String, createdAt: Date = .now) {
        self.id = id
        self.title = title
        self.createdAt = createdAt
    }
}

final class SharedTaskStore {
    static let seedPopulatedKey = "SeedPopulated"
    static let defaultTasks: [SharedTaskSeed] = [
        SharedTaskSeed(title: "Plan sprint"),
        SharedTaskSeed(title: "Write unit tests"),
        SharedTaskSeed(title: "Review pull request")
    ]

    private(set) static var shared = SharedTaskStore(
        modelContainer: SharedTaskStore.makeFallbackContainer(),
        userDefaults: .standard
    )

    private let modelContainer: ModelContainer
    private let userDefaults: UserDefaults

    static func configureShared(
        modelContainer: ModelContainer,
        userDefaults: UserDefaults = .standard
    ) {
        shared = SharedTaskStore(
            modelContainer: modelContainer,
            userDefaults: userDefaults
        )
    }

    init(
        modelContainer: ModelContainer,
        userDefaults: UserDefaults = .standard
    ) {
        self.modelContainer = modelContainer
        self.userDefaults = userDefaults
        populateSeedIfNeeded()
    }

    func fetchTasks() -> [SharedTaskRecord] {
        let descriptor = FetchDescriptor<SharedTaskRecord>(
            sortBy: [SortDescriptor(\.createdAt, order: .forward)]
        )

        return (try? modelContext.fetch(descriptor)) ?? []
    }

    func createTask(title: String) -> [SharedTaskRecord] {
        let task = SharedTaskRecord(title: title)
        modelContext.insert(task)
        saveContext()
        return fetchTasks()
    }

    func deleteTask(id: UUID) -> [SharedTaskRecord] {
        let descriptor = FetchDescriptor<SharedTaskRecord>(
            predicate: #Predicate { $0.id == id }
        )

        if let task = try? modelContext.fetch(descriptor).first {
            modelContext.delete(task)
            saveContext()
        }

        return fetchTasks()
    }

    private var modelContext: ModelContext {
        modelContainer.mainContext
    }

    private func populateSeedIfNeeded() {
        guard userDefaults.bool(forKey: Self.seedPopulatedKey) == false else { return }

        for task in Self.defaultTasks {
            modelContext.insert(SharedTaskRecord(title: task.title))
        }

        saveContext()
        userDefaults.set(true, forKey: Self.seedPopulatedKey)
    }

    private func saveContext() {
        do {
            try modelContext.save()
        } catch {
            assertionFailure("Failed to save SharedTaskStore context: \(error)")
        }
    }

    private static func makeFallbackContainer() -> ModelContainer {
        do {
            let schema = Schema([SharedTaskRecord.self])
            let configuration = ModelConfiguration(
                isStoredInMemoryOnly: true
            )
            return try ModelContainer(
                for: schema,
                configurations: [configuration]
            )
        } catch {
            fatalError("Failed to create fallback SharedTaskStore container: \(error)")
        }
    }
}

struct SharedTaskSeed {
    let title: String
}
