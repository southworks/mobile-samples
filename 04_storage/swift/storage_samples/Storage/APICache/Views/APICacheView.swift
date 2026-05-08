import SwiftUI

struct APICacheView: View {
    @StateObject private var viewModel = APICacheViewModel()

    var body: some View {
        Form {
            Section("User") {
                LabeledContent("Name", value: viewModel.user?.name ?? "")
                LabeledContent("Email", value: viewModel.user?.email ?? "")
            }

            Section {
                Button(viewModel.isLoading ? "Loading..." : "Fetch User") {
                    Task {
                        await viewModel.fetchUser()
                    }
                }
                .disabled(viewModel.isLoading)

                Button("Save to Cache") {
                    viewModel.saveCurrentUserToCache()
                }

                Button("Load from Cache") {
                    viewModel.loadUserFromCache()
                }
            }

            Section("Status") {
                Text(viewModel.statusMessage)
                    .foregroundStyle(.secondary)
            }
        }
        .navigationTitle("API + Cache")
    }
}

#Preview {
    NavigationStack {
        APICacheView()
    }
}
