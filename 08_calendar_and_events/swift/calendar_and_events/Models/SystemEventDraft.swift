import Foundation

struct SystemEventDraft {
    var title: String = ""
    var startDate: Date = .now
    var endDate: Date = Calendar.current.date(byAdding: .hour, value: 1, to: .now) ?? .now
    var notes: String = ""
    var isAllDay: Bool = false

    mutating func normalizeAllDayDates(using calendar: Calendar = .current) {
        guard isAllDay else { return }

        startDate = calendar.startOfDay(for: startDate)
        endDate = calendar.startOfDay(for: endDate)

        if endDate <= startDate {
            endDate = calendar.date(byAdding: .day, value: 1, to: startDate) ?? startDate
        }
    }

    func validate() throws {
        if title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            throw CalendarSampleError.emptyTitle
        }

        if endDate <= startDate {
            throw CalendarSampleError.invalidDateRange
        }
    }
}
