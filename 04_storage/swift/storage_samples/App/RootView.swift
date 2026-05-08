import SwiftUI

struct RootView: View {
    var body: some View {
        TabView {
            NavigationStack {
                FileCodableView()
            }
            .tabItem {
                Label("File/Codable", systemImage: "doc.text")
            }

            NavigationStack {
                SwiftDataNotesView()
            }
            .tabItem {
                Label("SwiftData", systemImage: "square.stack.3d.up")
            }

            NavigationStack {
                APICacheView()
            }
            .tabItem {
                Label("API + Cache", systemImage: "network")
            }

            NavigationStack {
                UserDefaultsSettingsView()
            }
            .tabItem {
                Label("UserDefaults", systemImage: "switch.2")
            }

            NavigationStack {
                KeychainAuthView()
            }
            .tabItem {
                Label("Keychain", systemImage: "key")
            }
        }
    }
}

#Preview {
    DashboardView()
        .modelContainer(for: SwiftDataNote.self, inMemory: true)
}
