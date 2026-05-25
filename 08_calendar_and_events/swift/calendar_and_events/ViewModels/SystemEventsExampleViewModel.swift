import EventKit
import Foundation
import Observation

@MainActor
@Observable
final class SystemEventsExampleViewModel {
    var events: [EKEvent] = []
    var isLoading = false
    var errorMessage: String?
    var lastLoadedAt: Date?

    private let manager: CalendarManager

    init(manager: CalendarManager) {
        self.manager = manager
    }

    func load(interval: DateInterval) async {
        isLoading = true
        defer { isLoading = false }

        do {
            events = try manager.events(in: interval)
            errorMessage = nil
            lastLoadedAt = .now
        } catch {
            events = []
            errorMessage = error.localizedDescription
        }
    }
}
