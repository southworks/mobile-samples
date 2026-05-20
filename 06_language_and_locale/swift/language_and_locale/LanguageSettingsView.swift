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
                localizationStore.text("settings.selectedLanguage", defaultValue: "Language"),
                value: localizationStore.selectedLanguage.rawValue
            )

            LabeledContent(
                localizationStore.text("settings.systemLanguage", defaultValue: "Bundle"),
                value: localizationStore.defaultLanguageCode
            )

            LabeledContent(
                localizationStore.text("settings.layoutDirection", defaultValue: "Direction"),
                value: localizationStore.layoutDescription
            )

            ForEach(AppLanguage.allCases) { language in
                Button {
                    localizationStore.selectedLanguage = language
                } label: {
                    HStack {
                        Text(language.displayName)

                        Spacer()

                        if language == localizationStore.selectedLanguage {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundStyle(.tint)
                        }
                    }
                }
                .buttonStyle(.plain)
            }
        }
        .navigationTitle(localizationStore.text("settings.title", defaultValue: "Language Settings"))
    }
}
