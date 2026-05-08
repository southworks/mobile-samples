//
//  storage_samplesApp.swift
//  storage_samples
//
//  Created by ec2-user on 5/8/26.
//

import SwiftUI
import CoreData

@main
struct storage_samplesApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
