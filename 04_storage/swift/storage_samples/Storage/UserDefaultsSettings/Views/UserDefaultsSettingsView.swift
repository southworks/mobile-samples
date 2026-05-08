import SwiftUI

struct UserDefaultsSettingsView: View {
    @StateObject private var viewModel = UserDefaultsSettingsViewModel()

    var body: some View {
        Form {
            Section {
                InfoBoxView(
                    title: "UserDefaults",
                    storageLocation: "Stored in the app's preferences database through UserDefaults.",
                    persistence: "Persists across launches until reset by the app, cleared from settings, or the app is removed."
                )
            }

            Section("Preferences") {
                TextField("Username", text: $viewModel.username)
                Toggle("Dark Mode Enabled", isOn: $viewModel.isDarkModeEnabled)
            }

            Section {
                Button("Save Settings") {
                    viewModel.saveValues()
                }

                Button("Reload Saved Values") {
                    viewModel.loadValues()
                }

                Button("Reset Settings", role: .destructive) {
                    viewModel.resetValues()
                }
            }
        }
        .navigationTitle("UserDefaults")
    }
}

#Preview {
    NavigationStack {
        UserDefaultsSettingsView()
    }
}
