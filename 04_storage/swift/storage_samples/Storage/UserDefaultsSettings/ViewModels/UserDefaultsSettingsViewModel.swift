import Foundation

@MainActor
final class UserDefaultsSettingsViewModel: ObservableObject {
    @Published var username = ""
    @Published var isDarkModeEnabled = false

    private let userDefaults: UserDefaults
    private let usernameKey = "settings.username"
    private let darkModeKey = "settings.darkMode"

    init(userDefaults: UserDefaults = .standard) {
        self.userDefaults = userDefaults
        loadValues()
    }

    func saveValues() {
        userDefaults.set(username, forKey: usernameKey)
        userDefaults.set(isDarkModeEnabled, forKey: darkModeKey)
    }

    func loadValues() {
        username = userDefaults.string(forKey: usernameKey) ?? ""
        isDarkModeEnabled = userDefaults.bool(forKey: darkModeKey)
    }

    func resetValues() {
        userDefaults.removeObject(forKey: usernameKey)
        userDefaults.removeObject(forKey: darkModeKey)
        loadValues()
    }
}
