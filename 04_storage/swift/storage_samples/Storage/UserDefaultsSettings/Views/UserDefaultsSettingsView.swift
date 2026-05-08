import SwiftUI

struct UserDefaultsSettingsView: View {
    @StateObject private var viewModel = UserDefaultsSettingsViewModel()

    var body: some View {
        Form {
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
