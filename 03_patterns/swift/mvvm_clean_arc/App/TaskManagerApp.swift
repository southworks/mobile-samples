import SwiftUI
import SwiftData

@main
struct TaskManagerApp: App {
    private let sharedTaskContainer: ModelContainer

    init() {
        do {
            let schema = Schema([SharedTaskRecord.self])
            sharedTaskContainer = try ModelContainer(for: schema)
            SharedTaskStore.configureShared(modelContainer: sharedTaskContainer)
        } catch {
            fatalError("Failed to initialize SwiftData container: \(error)")
        }
    }

    var body: some Scene {
        WindowGroup {
            RootView()
        }
        .modelContainer(sharedTaskContainer)
    }
}
