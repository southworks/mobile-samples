import SwiftUI
import SwiftData

struct SwiftDataNotesView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \SwiftDataNote.title) private var notes: [SwiftDataNote]
    @State private var title = ""

    var body: some View {
        Form {
            Section("Add Note") {
                TextField("Note title", text: $title)
                Button("Save Note") {
                    addNote()
                }
            }

            Section("Saved Notes") {
                if notes.isEmpty {
                    Text("No notes saved yet.")
                        .foregroundStyle(.secondary)
                } else {
                    ForEach(notes) { note in
                        Text(note.title)
                    }
                    .onDelete(perform: deleteNotes)
                }
            }
        }
        .navigationTitle("SwiftData")
    }

    private func addNote() {
        let trimmedTitle = title.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedTitle.isEmpty else { return }

        modelContext.insert(SwiftDataNote(title: trimmedTitle))
        title = ""
    }

    private func deleteNotes(at offsets: IndexSet) {
        for offset in offsets {
            modelContext.delete(notes[offset])
        }
    }
}

#Preview {
    NavigationStack {
        SwiftDataNotesView()
            .modelContainer(for: SwiftDataNote.self, inMemory: true)
    }
}
