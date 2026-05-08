import SwiftUI

struct KeychainAuthView: View {
    @StateObject private var viewModel = KeychainAuthViewModel()

    var body: some View {
        Form {
            Section("Fake Token") {
                TextField("Enter token", text: $viewModel.tokenInput)
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled()

                Button("Save Token") {
                    viewModel.saveToken()
                }

                Button("Check Token") {
                    viewModel.refreshState()
                }

                Button("Delete Token", role: .destructive) {
                    viewModel.deleteToken()
                }
            }

            Section("Status") {
                Text(viewModel.tokenExists ? "Token exists." : "Token not found.")
                Text(viewModel.statusMessage)
                    .foregroundStyle(.secondary)
            }
        }
        .navigationTitle("Keychain")
    }
}

#Preview {
    NavigationStack {
        KeychainAuthView()
    }
}
