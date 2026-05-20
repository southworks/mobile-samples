//
//  StaticLocalizationView.swift
//  language_and_locale
//
//  Created by ec2-user on 5/19/26.
//

import SwiftUI

struct StaticLocalizationView: View {
    @Environment(AppLanguageStore.self) private var languageStore

    private var localizedDate: String {
        Date.now.formatted(
            Date.FormatStyle(date: .complete, time: .shortened)
                .locale(languageStore.locale)
        )
    }

    private var localizedPrice: String {
        9.99.formatted(.currency(code: "USD").locale(languageStore.locale))
    }

    var body: some View {
        List {
            LabeledContent(
                "static.example.date",
                value: localizedDate
            )

            LabeledContent(
                "static.example.price",
                value: localizedPrice
            )

            LabeledContent(
                "static.example.identifier",
                value: languageStore.selectedLanguage.rawValue
            )

            LabeledContent("static.fallbackLabel") {
                Text("static.fallbackExample")
            }
        }
        .navigationTitle("static.title")
    }
}
