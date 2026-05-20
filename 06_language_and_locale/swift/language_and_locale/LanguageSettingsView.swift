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
            Picker(
                localizationStore.text("settings.selectedLanguage", defaultValue: "Language"),
                selection: Binding(
                    get: { localizationStore.selectedLanguage },
                    set: { localizationStore.selectedLanguage = $0 }
                )
            ) {
                ForEach(AppLanguage.allCases) { language in
                    Text(language.displayName)
                        .tag(language)
                }
            }

            LabeledContent(
                localizationStore.text("settings.systemLanguage", defaultValue: "Bundle"),
                value: localizationStore.defaultLanguageCode
            )

            LabeledContent(
                localizationStore.text("settings.layoutDirection", defaultValue: "Direction"),
                value: localizationStore.layoutDescription
            )
        }
        .navigationTitle(localizationStore.text("settings.title", defaultValue: "Language Settings"))
    }
}
