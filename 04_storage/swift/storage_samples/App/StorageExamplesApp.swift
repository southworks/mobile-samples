import SwiftUI
import SwiftData

@main
struct StorageExamplesApp: App {
    var body: some Scene {
        WindowGroup {
            RootView()
        }
        .modelContainer(for: SwiftDataNote.self)
    }
}
