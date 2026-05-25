//
//  calendar_and_eventsTests.swift
//  calendar_and_eventsTests
//
//  Created by ec2-user on 5/22/26.
//

import Testing
@testable import calendar_and_events

struct calendar_and_eventsTests {
    @Test func appDraftValidationRejectsInvalidRange() throws {
        var draft = AppCalendarEventDraft()
        draft.title = "Demo"
        draft.endDate = draft.startDate.addingTimeInterval(-60)

        do {
            try draft.validate()
            Issue.record("Expected invalidDateRange error")
        } catch let error as CalendarSampleError {
            #expect(error == .invalidDateRange)
        } catch {
            Issue.record("Unexpected error: \(error)")
        }
    }

    @Test func allDayNormalizationPushesEndDateForward() throws {
        var draft = SystemEventDraft()
        draft.title = "All day"
        draft.isAllDay = true
        draft.endDate = draft.startDate

        draft.normalizeAllDayDates()

        #expect(draft.endDate > draft.startDate)
    }
}
