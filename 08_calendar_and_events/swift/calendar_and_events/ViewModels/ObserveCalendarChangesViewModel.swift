import EventKit
import Foundation
import Observation

@MainActor
@Observable
final class ObserveCalendarChangesViewModel {
    var events: [EKEvent] = []
    var errorMessage: String?
    var lastRefreshAt: Date?

    private let manager: CalendarManager

    init(manager: CalendarManager) {
        self.manager = manager
    }

    func refresh() {
        do {
            events = try manager.upcomingEvents(limit: 10)
            errorMessage = nil
            lastRefreshAt = .now
        } catch {
            events = []
            errorMessage = error.localizedDescription
        }
    }

    func listenForChanges() -> AsyncStream<Date> {
        manager.changeStream()
    }
}
