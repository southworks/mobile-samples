import SwiftUI

struct APICacheView: View {
    @StateObject private var viewModel = APICacheViewModel()

    var body: some View {
        Form {
            Section("User") {
                if let user = viewModel.user {
                    LabeledContent("Name", value: user.name)
                    LabeledContent("Email", value: user.email)
                } else {
                    Text("No user loaded yet.")
                        .foregroundStyle(.secondary)
                }
            }

            Section {
                Button(viewModel.isLoading ? "Loading..." : "Fetch User") {
                    Task {
                        await viewModel.loadUser()
                    }
                }
                .disabled(viewModel.isLoading)
            }

            Section("Status") {
                Text(viewModel.statusMessage)
                    .foregroundStyle(.secondary)
            }
        }
        .navigationTitle("API + Cache")
        .task {
            guard viewModel.user == nil, !viewModel.isLoading else { return }
            await viewModel.loadUser()
        }
    }
}

#Preview {
    NavigationStack {
        APICacheView()
    }
}
