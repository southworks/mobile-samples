import Foundation

@MainActor
final class APICacheViewModel: ObservableObject {
    @Published var user: RemoteUser?
    @Published var statusMessage = "Tap fetch to load a user."
    @Published var isLoading = false

    private let service = APICacheUserService()

    func loadUser() async {
        isLoading = true
        defer { isLoading = false }

        do {
            let (user, source) = try await service.fetchUser()
            self.user = user
            switch source {
            case .live:
                statusMessage = "Loaded from the API and updated the cache file."
            case .cache:
                statusMessage = "API failed, so the cached user was loaded from Caches."
            }
        } catch {
            user = nil
            statusMessage = "Fetch failed: \(error.localizedDescription)"
        }
    }
}
