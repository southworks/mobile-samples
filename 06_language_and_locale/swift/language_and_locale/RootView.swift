//
//  RootView.swift
//  language_and_locale
//
//  Created by ec2-user on 5/19/26.
//

import SwiftUI

struct RootView: View {
    @Environment(LocalizationStore.self) private var localizationStore

    var body: some View {
        NavigationStack {
            List {
                LabeledContent(
                    localizationStore.text("home.currentLanguage", defaultValue: "App"),
                    value: localizationStore.selectedLanguage.rawValue
                )

                NavigationLink(
                    localizationStore.text("settings.title", defaultValue: "Language Settings"),
                    value: Route.languageSettings
                )

                NavigationLink(
                    localizationStore.text("static.title", defaultValue: "Static Localization"),
                    value: Route.staticLocalization
                )

                NavigationLink(
                    localizationStore.text("remote.title", defaultValue: "Remote Localization"),
                    value: Route.remoteLocalization
                )

                NavigationLink(
                    localizationStore.text("rtl.title", defaultValue: "RTL Layout"),
                    value: Route.rtlLayout
                )
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
    RootView()
        .environment(LocalizationStore())
        .environment(RemoteLocalizationStore())
}
