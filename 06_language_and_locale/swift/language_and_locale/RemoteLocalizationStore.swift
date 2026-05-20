//
//  RemoteLocalizationStore.swift
//  language_and_locale
//
//  Created by ec2-user on 5/19/26.
//

import Foundation
import Observation

struct FakerPersonResponse: Decodable {
    let data: [RemoteClientPayload]
}

struct RemoteClientPayload: Decodable {
    let id: Int
    let firstname: String
    let lastname: String
    let email: String
}

struct RemoteClient {
    let fullName: String
    let email: String
    let imageURL: URL?
    let requestedLanguage: AppLanguage
    let resolvedLanguage: AppLanguage

    var usedFallbackLanguage: Bool {
        requestedLanguage != resolvedLanguage
    }
}

enum RemoteClientResolver {
    static func localeCode(for language: AppLanguage) -> String {
        switch language {
        case .english:
            "en_US"
        case .japanese:
            "ja_JP"
        case .spanish:
            "es_AR"
        case .arabic:
            "ar_SA"
        }
    }

    static func resolvedLanguage(for language: AppLanguage) -> AppLanguage {
        language
    }

    static func resolve(_ payload: RemoteClientPayload, requestedLanguage: AppLanguage) -> RemoteClient {
        let resolvedLanguage = resolvedLanguage(for: requestedLanguage)
        let fullName = "\(payload.firstname) \(payload.lastname)"
        return RemoteClient(
            fullName: fullName,
            email: payload.email,
            imageURL: URL(string: "https://picsum.photos/300")!,
            requestedLanguage: requestedLanguage,
            resolvedLanguage: resolvedLanguage
        )
    }
}

@MainActor
@Observable
final class RemoteLocalizationStore {
    private(set) var client: RemoteClient?
    private(set) var lastLoadedLanguage: AppLanguage?
    var isLoading = false
    var errorMessage: String?

    func loadIfNeeded(for language: AppLanguage) async {
        guard client == nil || lastLoadedLanguage != language else {
            return
        }

        await reload(for: language)
    }

    func reload(for language: AppLanguage) async {
        isLoading = true
        errorMessage = nil

        do {
            client = try await fetchClient(for: language)
            lastLoadedLanguage = language
        } catch {
            errorMessage = error.localizedDescription
            client = nil
        }

        isLoading = false
    }

    private func fetchClient(for language: AppLanguage) async throws -> RemoteClient {
        let locale = RemoteClientResolver.localeCode(for: language)
        let url = URL(string: "https://fakerapi.it/api/v2/persons?_quantity=1&_locale=\(locale)")!
        let (data, _) = try await URLSession.shared.data(from: url)
        let response = try JSONDecoder().decode(FakerPersonResponse.self, from: data)

        guard let payload = response.data.first else {
            throw RemoteLocalizationError.emptyResponse
        }

        return RemoteClientResolver.resolve(payload, requestedLanguage: language)
    }
}

enum RemoteLocalizationError: LocalizedError {
    case emptyResponse

    var errorDescription: String? {
        switch self {
        case .emptyResponse:
            "The remote client endpoint returned no records."
        }
    }
}
