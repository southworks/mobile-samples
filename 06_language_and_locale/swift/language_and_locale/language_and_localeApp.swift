//
//  language_and_localeApp.swift
//  language_and_locale
//
//  Created by ec2-user on 5/19/26.
//

import SwiftUI

@main
struct language_and_localeApp: App {
    @State private var languageStore = AppLanguageStore()
    @State private var remoteLocalizationStore = RemoteLocalizationStore()

    var body: some Scene {
        WindowGroup {
            RootView()
                .id(languageStore.selectedLanguage.rawValue)
                .environment(languageStore)
                .environment(remoteLocalizationStore)
                .environment(\.locale, languageStore.locale)
                .environment(\.layoutDirection, languageStore.layoutDirection)
        }
    }
}
