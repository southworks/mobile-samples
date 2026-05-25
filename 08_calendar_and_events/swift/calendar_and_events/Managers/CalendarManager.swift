import EventKit
import Foundation
import Observation

@MainActor
@Observable
final class CalendarManager {
    private let eventStore = EKEventStore()
    private(set) var authorizationState: CalendarAuthorizationState

    init() {
        authorizationState = CalendarAuthorizationState(status: EKEventStore.authorizationStatus(for: .event))
    }

    @discardableResult
    func refreshAuthorizationState() -> CalendarAuthorizationState {
        authorizationState = CalendarAuthorizationState(status: EKEventStore.authorizationStatus(for: .event))
        return authorizationState
    }

    func requestFullAccess() async throws -> CalendarAuthorizationState {
        do {
            try await withCheckedThrowingContinuation { continuation in
                eventStore.requestFullAccessToEvents { granted, error in
                    if let error {
                        continuation.resume(throwing: error)
                    } else if granted {
                        continuation.resume(returning: ())
                    } else {
                        continuation.resume(throwing: CalendarSampleError.eventKitFailure("El sistema no otorgó acceso completo al calendario."))
                    }
                }
            }
        } catch {
            refreshAuthorizationState()
            throw error
        }

        return refreshAuthorizationState()
    }

    func events(in interval: DateInterval, calendars: [EKCalendar]? = nil) throws -> [EKEvent] {
        try ensureReadableAccess()

        let predicate = eventStore.predicateForEvents(withStart: interval.start, end: interval.end, calendars: calendars)
        return eventStore
            .events(matching: predicate)
            .sorted { $0.startDate < $1.startDate }
    }

    func upcomingEvents(limit: Int = 10) throws -> [EKEvent] {
        let start = Date()
        let end = Calendar.current.date(byAdding: .day, value: 30, to: start) ?? start
        return Array(try events(in: DateInterval(start: start, end: end)).prefix(limit))
    }

    func createEvent(from draft: SystemEventDraft) throws -> EKEvent {
        try ensureWritableAccess()

        var normalizedDraft = draft
        normalizedDraft.normalizeAllDayDates()
        try normalizedDraft.validate()

        guard let calendar = eventStore.defaultCalendarForNewEvents else {
            throw CalendarSampleError.missingDefaultCalendar
        }

        let event = EKEvent(eventStore: eventStore)
        event.calendar = calendar
        event.title = normalizedDraft.title.trimmingCharacters(in: .whitespacesAndNewlines)
        event.startDate = normalizedDraft.startDate
        event.endDate = normalizedDraft.endDate
        event.notes = normalizedDraft.notes.trimmingCharacters(in: .whitespacesAndNewlines)
        event.isAllDay = normalizedDraft.isAllDay

        do {
            try eventStore.save(event, span: .thisEvent)
            return event
        } catch {
            throw CalendarSampleError.eventKitFailure(error.localizedDescription)
        }
    }

    func newEvent() -> EKEvent {
        EKEvent(eventStore: eventStore)
    }

    func editorEventStore() -> EKEventStore {
        eventStore
    }

    func editableUpcomingEvent() throws -> EKEvent {
        try ensureReadableAccess()

        guard let event = try upcomingEvents(limit: 20).first(where: { $0.calendar.allowsContentModifications }) else {
            throw CalendarSampleError.missingEditableEvent
        }

        return event
    }

    func calendars() throws -> [EKCalendar] {
        try ensureReadableAccess()
        return eventStore.calendars(for: .event).sorted { $0.title.localizedCaseInsensitiveCompare($1.title) == .orderedAscending }
    }

    func changeStream() -> AsyncStream<Date> {
        AsyncStream { continuation in
            let token = NotificationCenter.default.addObserver(
                forName: .EKEventStoreChanged,
                object: eventStore,
                queue: .main
            ) { _ in
                continuation.yield(.now)
            }

            continuation.onTermination = { _ in
                NotificationCenter.default.removeObserver(token)
            }
        }
    }

    private func ensureReadableAccess() throws {
        let state = refreshAuthorizationState()
        guard state.canReadEvents else {
            throw CalendarSampleError.missingReadPermission(state)
        }
    }

    private func ensureWritableAccess() throws {
        let state = refreshAuthorizationState()
        guard state.canWriteEvents else {
            throw CalendarSampleError.missingWritePermission(state)
        }
    }
}
