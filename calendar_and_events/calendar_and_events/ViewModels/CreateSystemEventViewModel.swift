import Foundation
import Observation

@MainActor
@Observable
final class CreateSystemEventViewModel {
    var draft = SystemEventDraft()
    var isSaving = false
    var resultMessage: String?
    var errorMessage: String?

    private let manager: CalendarManager

    init(manager: CalendarManager) {
        self.manager = manager
    }

    func save() async {
        isSaving = true
        defer { isSaving = false }

        do {
            var workingDraft = draft
            workingDraft.normalizeAllDayDates()
            let event = try manager.createEvent(from: workingDraft)
            resultMessage = "Evento guardado en el calendario del sistema: \(event.displayTitle)."
            errorMessage = nil
            draft = SystemEventDraft()
        } catch {
            errorMessage = error.localizedDescription
            resultMessage = nil
        }
    }
}
