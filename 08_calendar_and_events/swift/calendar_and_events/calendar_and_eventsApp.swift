//
//  calendar_and_eventsApp.swift
//  calendar_and_events
//
//  Created by ec2-user on 5/22/26.
//

import SwiftData
import SwiftUI

@main
struct calendar_and_eventsApp: App {
    @State private var calendarManager = CalendarManager()

    var body: some Scene {
        WindowGroup {
            RootView()
                .environment(calendarManager)
        }
        .modelContainer(for: AppCalendarEvent.self)
    }
}
