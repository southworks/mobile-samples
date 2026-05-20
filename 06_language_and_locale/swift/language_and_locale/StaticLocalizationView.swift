//
//  StaticLocalizationView.swift
//  language_and_locale
//
//  Created by ec2-user on 5/19/26.
//

import SwiftUI

struct StaticLocalizationView: View {
    @Environment(LocalizationStore.self) private var localizationStore

    private var localizedDate: String {
        Date.now.formatted(
            Date.FormatStyle(date: .complete, time: .shortened)
                .locale(localizationStore.locale)
        )
    }

    private var localizedPrice: String {
        9.99.formatted(.currency(code: "USD").locale(localizationStore.locale))
    }

    var body: some View {
        List {
            LabeledContent(
                localizationStore.text("static.example.date", defaultValue: "Date"),
                value: localizedDate
            )

            LabeledContent(
                localizationStore.text("static.example.price", defaultValue: "Price"),
                value: localizedPrice
            )

            LabeledContent(
                localizationStore.text("static.example.identifier", defaultValue: "Code"),
                value: localizationStore.selectedLanguage.rawValue
            )

            LabeledContent(
                localizationStore.text("static.fallbackLabel", defaultValue: "Fallback"),
                value: localizationStore.text("static.fallbackExample", defaultValue: "English fallback")
            )
        }
        .navigationTitle(localizationStore.text("static.title", defaultValue: "Static Localization"))
    }
}
