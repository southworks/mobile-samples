import Foundation
import Observation

@MainActor
@Observable
final class CalendarPermissionViewModel {
    var status: CalendarAuthorizationState
    var errorMessage: String?
    var isRequestInFlight = false

    private let manager: CalendarManager

    init(manager: CalendarManager) {
        self.manager = manager
        status = manager.refreshAuthorizationState()
    }

    func refresh() {
        status = manager.refreshAuthorizationState()
    }

    func requestFullAccess() async {
        isRequestInFlight = true
        defer { isRequestInFlight = false }

        do {
            status = try await manager.requestFullAccess()
            errorMessage = nil
        } catch {
            status = manager.refreshAuthorizationState()
            errorMessage = error.localizedDescription
        }
    }
}
