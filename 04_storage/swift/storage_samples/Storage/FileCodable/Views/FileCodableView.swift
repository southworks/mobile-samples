import SwiftUI

struct FileCodableView: View {
    @StateObject private var viewModel = FileCodableViewModel()

    var body: some View {
        Form {
            Section {
                InfoBoxView(
                    title: "File + Codable",
                    storageLocation: "Stored as JSON in the app's Documents directory with FileManager.",
                    persistence: "Persists across launches until the file is deleted or the app is removed."
                )
            }

            Section("Write Note") {
                TextField("Enter a note", text: $viewModel.draftText, axis: .vertical)
                    .lineLimit(3...6)

                Button("Save Note") {
                    viewModel.saveNote()
                }
            }

            Section("Read Note") {
                Text(viewModel.savedText)
                Button("Load Note") {
                    viewModel.loadNote()
                }
                Button("Delete Note", role: .destructive) {
                    viewModel.deleteNote()
                }
            }

            Section("Status") {
                Text(viewModel.statusMessage)
                    .foregroundStyle(.secondary)
            }
        }
        .navigationTitle("File/Codable")
    }
}

#Preview {
    NavigationStack {
        FileCodableView()
    }
}
