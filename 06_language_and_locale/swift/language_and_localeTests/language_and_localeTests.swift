//
//  language_and_localeTests.swift
//  language_and_localeTests
//
//  Created by ec2-user on 5/19/26.
//

import Testing
@testable import language_and_locale

struct language_and_localeTests {
    @Test
    func mapsJapaneseAliasToTheAppLanguage() {
        #expect(AppLanguage.fromPreferredLocalization("ja") == .japanese)
        #expect(AppLanguage.fromPreferredLocalization("jp") == .japanese)
    }

    @Test
    func usesJapaneseEndpointForJapanese() {
        #expect(RemoteClientResolver.localeCode(for: .japanese) == "ja_JP")
        #expect(RemoteClientResolver.resolvedLanguage(for: .japanese) == .japanese)
    }

    @Test
    func resolvesRemoteClientFromPayload() {
        let payload = RemoteClientPayload(
            id: 1,
            firstname: "Julia",
            lastname: "Veliz",
            email: "julia@example.com",
            image: "http://placeimg.com/640/480/people"
        )

        let resolved = RemoteClientResolver.resolve(payload, requestedLanguage: .spanish)

        #expect(resolved.fullName == "Julia Veliz")
        #expect(resolved.email == "julia@example.com")
        #expect(resolved.imageURL?.absoluteString == "http://placeimg.com/640/480/people")
        #expect(resolved.resolvedLanguage == .spanish)
        #expect(resolved.usedFallbackLanguage == false)
    }
}
