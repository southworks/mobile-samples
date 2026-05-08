import Foundation

@MainActor
final class APICacheViewModel: ObservableObject {
    @Published var user: RemoteUser?
    @Published var statusMessage = "Fetch a user from the API or load one from cache."
    @Published var isLoading = false

    private let service = APICacheUserService()

    func fetchUser() async {
        isLoading = true
        defer { isLoading = false }

        do {
            user = try await service.fetchUser()
            statusMessage = "Fetched a user from the API."
        } catch {
            user = nil
            statusMessage = "Fetch failed: \(error.localizedDescription)"
        }
    }

    func saveCurrentUserToCache() {
        guard let user else {
            statusMessage = "Fetch or load a user before saving to cache."
            return
        }

        do {
            try service.saveUserToCache(user)
            statusMessage = "Saved the current user to the cache file."
        } catch {
            statusMessage = "Cache save failed: \(error.localizedDescription)"
        }
    }

    func loadUserFromCache() {
        do {
            user = try service.loadCachedUser()
            statusMessage = "Loaded a user from the cache file."
        } catch {
            user = nil
            statusMessage = "Cache load failed: \(error.localizedDescription)"
        }
    }
}
