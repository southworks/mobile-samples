//
//  canvas_samplesApp.swift
//  canvas_samples
//
//  Created by ec2-user on 5/12/26.
//

import SwiftUI
import SwiftData

@main
struct canvas_samplesApp: App {
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            SavedDrawing.self,
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(sharedModelContainer)
    }
}
