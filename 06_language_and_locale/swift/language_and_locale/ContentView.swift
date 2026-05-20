//
//  ContentView.swift
//  language_and_locale
//
//  Created by ec2-user on 5/19/26.
//

import SwiftUI

struct ContentView: View {
    @Environment(LocalizationStore.self) private var localizationStore

    var body: some View {
        NavigationStack {
            List {
                LabeledContent(
                    localizationStore.text("home.currentLanguage", defaultValue: "App"),
                    value: localizationStore.selectedLanguage.rawValue
                )

                LabeledContent(
                    localizationStore.text("home.defaultLanguage", defaultValue: "Bundle"),
                    value: localizationStore.defaultLanguageCode
                )

                NavigationLink(value: Route.languageSettings) {
                    SampleRow(title: localizationStore.text("settings.title", defaultValue: "Language Settings"))
                }

                NavigationLink(value: Route.staticLocalization) {
                    SampleRow(title: localizationStore.text("static.title", defaultValue: "Static Localization"))
                }

                NavigationLink(value: Route.remoteLocalization) {
                    SampleRow(title: localizationStore.text("remote.title", defaultValue: "Remote Localization"))
                }

                NavigationLink(value: Route.rtlLayout) {
                    SampleRow(title: localizationStore.text("rtl.title", defaultValue: "RTL Layout"))
                }
            }
            .navigationTitle(localizationStore.text("home.title", defaultValue: "Localization Samples"))
            .navigationDestination(for: Route.self) { route in
                switch route {
                case .languageSettings:
                    LanguageSettingsView()
                case .staticLocalization:
                    StaticLocalizationView()
                case .remoteLocalization:
                    RemoteLocalizationView()
                case .rtlLayout:
                    RTLLayoutView()
                }
            }
        }
    }
}

enum Route: Hashable {
    case languageSettings
    case staticLocalization
    case remoteLocalization
    case rtlLayout
}

#Preview {
    ContentView()
        .environment(LocalizationStore())
        .environment(RemoteLocalizationStore())
}
