import Combine
import Foundation

@MainActor
final class KeychainAuthViewModel: ObservableObject {
    @Published var tokenInput = ""
    @Published var tokenExists = false
    @Published var statusMessage = "No token stored."

    private let service = KeychainTokenService()

    init() {
        refreshState()
    }

    func saveToken() {
        let trimmedToken = tokenInput.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedToken.isEmpty else {
            statusMessage = "Enter a token before saving."
            return
        }

        if service.saveToken(trimmedToken) {
            tokenInput = ""
            refreshState(message: "Token saved securely in Keychain.")
        } else {
            statusMessage = "Could not save the token."
        }
    }

    func deleteToken() {
        if service.deleteToken() {
            refreshState(message: "Token deleted from Keychain.")
        } else {
            statusMessage = "Could not delete the token."
        }
    }

    func refreshState(message: String? = nil) {
        tokenExists = service.tokenExists()
        statusMessage = message ?? (tokenExists ? "A token is stored in Keychain." : "No token stored.")
    }
}
