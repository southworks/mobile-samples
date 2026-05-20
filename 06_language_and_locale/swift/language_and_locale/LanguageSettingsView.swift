//
//  LanguageSettingsView.swift
//  language_and_locale
//
//  Created by ec2-user on 5/19/26.
//

import SwiftUI

struct LanguageSettingsView: View {
    @Environment(AppLanguageStore.self) private var languageStore

    var body: some View {
        List {
            LabeledContent(
                "settings.selectedLanguage",
                value: languageStore.selectedLanguage.displayName
            )

            LabeledContent(
                "settings.systemLanguage",
                value: languageStore.defaultLanguageEnglishName
            )

            LabeledContent(
                "RTL",
                value: languageStore.englishLayoutDescription
            )
        }
        .navigationTitle("settings.title")
    }
}
