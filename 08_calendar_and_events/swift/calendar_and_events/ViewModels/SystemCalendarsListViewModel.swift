import EventKit
import Observation

@MainActor
@Observable
final class SystemCalendarsListViewModel {
    var calendars: [EKCalendar] = []
    var errorMessage: String?

    private let manager: CalendarManager

    init(manager: CalendarManager) {
        self.manager = manager
    }

    func load() {
        do {
            calendars = try manager.calendars()
            errorMessage = nil
        } catch {
            calendars = []
            errorMessage = error.localizedDescription
        }
    }
}
