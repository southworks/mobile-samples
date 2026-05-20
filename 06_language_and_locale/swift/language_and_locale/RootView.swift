//
//  RootView.swift
//  language_and_locale
//
//  Created by ec2-user on 5/19/26.
//

import SwiftUI

struct RootView: View {
    @Environment(AppLanguageStore.self) private var languageStore

    var body: some View {
        NavigationStack {
            List {
                Picker(
                    "home.currentLanguage",
                    selection: Binding(
                        get: { languageStore.selectedLanguage },
                        set: { languageStore.selectedLanguage = $0 }
                    )
                ) {
                    ForEach(AppLanguage.allCases) { language in
                        Text(language.displayName)
                            .tag(language)
                    }
                }

                NavigationLink(
                    "settings.title",
                    value: Route.languageSettings
                )

                NavigationLink(
                    "static.title",
                    value: Route.staticLocalization
                )

                NavigationLink(
                    "remote.title",
                    value: Route.remoteLocalization
                )

                NavigationLink(
                    "RTL",
                    value: Route.rtlLayout
                )
            }
            .navigationTitle("home.title")
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
        .environment(AppLanguageStore())
        .environment(RemoteLocalizationStore())
}
