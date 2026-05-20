//
//  LocalizationStore.swift
//  language_and_locale
//
//  Created by ec2-user on 5/19/26.
//

import Foundation
import Observation
import SwiftUI

enum AppLanguage: String, CaseIterable, Identifiable {
    case english = "en"
    case spanish = "es"
    case arabic = "ar"
    case japanese = "jp"

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .english:
            "English"
        case .spanish:
            "Spanish"
        case .arabic:
            "Arabic"
        case .japanese:
            "Japanese"
        }
    }

    var bundleLocalizationCode: String {
        switch self {
        case .japanese:
            "ja"
        default:
            rawValue
        }
    }

    var locale: Locale {
        Locale(identifier: bundleLocalizationCode)
    }

    var isRightToLeft: Bool {
        self == .arabic
    }

    static func fromPreferredLocalization(_ localization: String?) -> AppLanguage? {
        guard let localization else {
            return nil
        }

        let normalizedCode = localization.lowercased()

        if normalizedCode.hasPrefix("en") {
            return .english
        }

        if normalizedCode.hasPrefix("es") {
            return .spanish
        }

        if normalizedCode.hasPrefix("ar") {
            return .arabic
        }

        if normalizedCode.hasPrefix("ja") || normalizedCode.hasPrefix("jp") {
            return .japanese
        }

        return nil
    }
}

@MainActor
@Observable
final class LocalizationStore {
    private static let selectedLanguageKey = "selected-language"
    private let userDefaults: UserDefaults

    let defaultLanguageCode: String
    var selectedLanguage: AppLanguage {
        didSet {
            userDefaults.set(selectedLanguage.rawValue, forKey: Self.selectedLanguageKey)
        }
    }

    init(userDefaults: UserDefaults = .standard) {
        self.userDefaults = userDefaults

        let currentAppLanguage = Bundle.main.preferredLocalizations.first
        defaultLanguageCode = currentAppLanguage ?? AppLanguage.english.bundleLocalizationCode

        if
            let storedLanguage = userDefaults.string(forKey: Self.selectedLanguageKey),
            let selectedLanguage = AppLanguage(rawValue: storedLanguage)
        {
            self.selectedLanguage = selectedLanguage
        } else {
            self.selectedLanguage = AppLanguage.fromPreferredLocalization(currentAppLanguage) ?? .english
        }
    }

    var locale: Locale {
        selectedLanguage.locale
    }

    var layoutDirection: LayoutDirection {
        selectedLanguage.isRightToLeft ? .rightToLeft : .leftToRight
    }

    var layoutDescription: String {
        selectedLanguage.isRightToLeft ? "RTL" : "LTR"
    }

    func text(_ key: String, defaultValue: String) -> String {
        let fallbackValue = Bundle.localizedBundle(for: AppLanguage.english.bundleLocalizationCode)?
            .localizedString(forKey: key, value: defaultValue, table: nil) ?? defaultValue

        return localizedBundle.localizedString(forKey: key, value: fallbackValue, table: nil)
    }

    private var localizedBundle: Bundle {
        Bundle.localizedBundle(for: selectedLanguage.bundleLocalizationCode)
            ?? Bundle.localizedBundle(for: AppLanguage.english.bundleLocalizationCode)
            ?? .main
    }
}

private extension Bundle {
    static func localizedBundle(for languageCode: String) -> Bundle? {
        guard let path = Bundle.main.path(forResource: languageCode, ofType: "lproj") else {
            return nil
        }

        return Bundle(path: path)
    }
}
