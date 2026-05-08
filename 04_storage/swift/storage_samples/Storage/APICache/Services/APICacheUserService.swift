import Foundation

struct APICacheUserService {
    enum UserSource {
        case live
        case cache
    }

    enum ServiceError: LocalizedError {
        case invalidResponse
        case noCachedUser

        var errorDescription: String? {
            switch self {
            case .invalidResponse:
                return "The server returned an unexpected response."
            case .noCachedUser:
                return "No cached user is available."
            }
        }
    }

    private let endpoint = URL(string: "https://jsonplaceholder.typicode.com/users/1")!
    private let fileName = "cached-user.json"

    private var cacheURL: URL {
        let cacheDirectory = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first!
        return cacheDirectory.appendingPathComponent(fileName)
    }

    func fetchUser() async throws -> (RemoteUser, UserSource) {
        do {
            let (data, response) = try await URLSession.shared.data(from: endpoint)
            guard let httpResponse = response as? HTTPURLResponse, 200..<300 ~= httpResponse.statusCode else {
                throw ServiceError.invalidResponse
            }

            let user = try JSONDecoder().decode(RemoteUser.self, from: data)
            try data.write(to: cacheURL, options: .atomic)
            return (user, .live)
        } catch {
            let cachedUser = try loadCachedUser()
            return (cachedUser, .cache)
        }
    }

    private func loadCachedUser() throws -> RemoteUser {
        guard FileManager.default.fileExists(atPath: cacheURL.path) else {
            throw ServiceError.noCachedUser
        }

        let data = try Data(contentsOf: cacheURL)
        return try JSONDecoder().decode(RemoteUser.self, from: data)
    }
}
