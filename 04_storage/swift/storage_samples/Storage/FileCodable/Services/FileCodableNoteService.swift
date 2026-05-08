import Foundation

struct FileCodableNoteService {
    private let fileName = "file-codable-note.json"

    private var fileURL: URL {
        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        return documentsDirectory.appendingPathComponent(fileName)
    }

    func save(note: FileCodableNote) throws {
        let data = try JSONEncoder().encode(note)
        try data.write(to: fileURL, options: .atomic)
    }

    func load() throws -> FileCodableNote {
        let data = try Data(contentsOf: fileURL)
        return try JSONDecoder().decode(FileCodableNote.self, from: data)
    }

    func delete() throws {
        guard FileManager.default.fileExists(atPath: fileURL.path) else { return }
        try FileManager.default.removeItem(at: fileURL)
    }
}
