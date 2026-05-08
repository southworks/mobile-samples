import SwiftUI

struct FileCodableView: View {
    @StateObject private var viewModel = FileCodableViewModel()

    var body: some View {
        Form {
            Section("Write Note") {
                TextField("Enter a note", text: $viewModel.draftText, axis: .vertical)
                    .lineLimit(3...6)

                Button("Save Note") {
                    viewModel.saveNote()
                }

                Button("Clear Input", role: .destructive) {
                    viewModel.draftText = ""
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
