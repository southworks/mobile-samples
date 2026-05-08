import Foundation

struct APICacheUserService {
    enum UserSource {
        case live
        case cache
    }
    private let fileName = "cached-user.json"

    private var cacheURL: URL {
        let cacheDirectory = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first!
        return cacheDirectory.appendingPathComponent(fileName)
    }

    func fetchUser() async throws -> (RemoteUser, UserSource) {
        do {
            let endpoint = URL(string: "https://jsonplaceholder.typicode.com/users/\(Int.random(in: 1...10))")!
            let (data, response) = try await URLSession.shared.data(from: endpoint)
            guard let httpResponse = response as? HTTPURLResponse, 200..<300 ~= httpResponse.statusCode else {
                throw URLError(.badServerResponse)
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
            throw CocoaError(.fileNoSuchFile)
        }

        let data = try Data(contentsOf: cacheURL)
        return try JSONDecoder().decode(RemoteUser.self, from: data)
    }
}
