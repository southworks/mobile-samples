import Foundation
import SwiftData

@Model
final class AppCalendarEvent {
    var id: UUID
    var title: String
    var startDate: Date
    var endDate: Date
    var notes: String
    var colorName: String
    var isAllDay: Bool
    var createdAt: Date
    var updatedAt: Date

    init(
        id: UUID = UUID(),
        title: String,
        startDate: Date,
        endDate: Date,
        notes: String = "",
        colorName: String = AppEventColor.sky.rawValue,
        isAllDay: Bool = false,
        createdAt: Date = .now,
        updatedAt: Date = .now
    ) {
        self.id = id
        self.title = title
        self.startDate = startDate
        self.endDate = endDate
        self.notes = notes
        self.colorName = colorName
        self.isAllDay = isAllDay
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }

    func apply(draft: AppCalendarEventDraft) {
        title = draft.title
        startDate = draft.startDate
        endDate = draft.endDate
        notes = draft.notes
        colorName = draft.color.rawValue
        isAllDay = draft.isAllDay
        updatedAt = .now
    }
}
