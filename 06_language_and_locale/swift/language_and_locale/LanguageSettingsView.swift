//
//  LanguageSettingsView.swift
//  language_and_locale
//
//  Created by ec2-user on 5/19/26.
//

import SwiftUI

struct LanguageSettingsView: View {
    @Environment(LocalizationStore.self) private var localizationStore

    var body: some View {
        List {
            LabeledContent(
                Text("settings.selectedLanguage"),
                value: localizationStore.selectedLanguage.displayName
            )

            LabeledContent(
                Text("settings.systemLanguage"),
                value: localizationStore.defaultLanguageEnglishName
            )

            LabeledContent(
                Text("settings.layoutDirection"),
                value: localizationStore.englishLayoutDescription
            )
        }
        .navigationTitle(localizationStore.text("settings.title", defaultValue: "Language Settings"))
    }
}
