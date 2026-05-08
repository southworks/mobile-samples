import Foundation

@MainActor
final class FileCodableViewModel: ObservableObject {
    @Published var draftText = ""
    @Published var savedText = "No note loaded"
    @Published var statusMessage = "Ready"

    private let service = FileCodableNoteService()

    func saveNote() {
        let trimmed = draftText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else {
            statusMessage = "Enter a note before saving."
            return
        }

        do {
            try service.save(note: FileCodableNote(text: trimmed))
            savedText = trimmed
            statusMessage = "Saved note to a JSON file in Documents."
        } catch {
            statusMessage = "Save failed: \(error.localizedDescription)"
        }
    }

    func loadNote() {
        do {
            let note = try service.load()
            draftText = note.text
            savedText = note.text
            statusMessage = "Loaded note from the JSON file."
        } catch {
            savedText = "No note loaded"
            statusMessage = "Load failed: \(error.localizedDescription)"
        }
    }

    func deleteNote() {
        do {
            try service.delete()
            draftText = ""
            savedText = "No note loaded"
            statusMessage = "Deleted the JSON file from Documents."
        } catch {
            statusMessage = "Delete failed: \(error.localizedDescription)"
        }
    }
}
