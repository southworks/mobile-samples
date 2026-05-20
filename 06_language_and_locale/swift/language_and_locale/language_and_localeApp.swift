//
//  language_and_localeApp.swift
//  language_and_locale
//
//  Created by ec2-user on 5/19/26.
//

import SwiftUI

@main
struct language_and_localeApp: App {
    @State private var localizationStore = LocalizationStore()
    @State private var remoteLocalizationStore = RemoteLocalizationStore()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(localizationStore)
                .environment(remoteLocalizationStore)
                .environment(\.locale, localizationStore.locale)
                .environment(\.layoutDirection, localizationStore.layoutDirection)
        }
    }
}
