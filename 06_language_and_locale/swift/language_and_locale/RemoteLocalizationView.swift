//
//  RemoteLocalizationView.swift
//  language_and_locale
//
//  Created by ec2-user on 5/19/26.
//

import SwiftUI

struct RemoteLocalizationView: View {
    @Environment(AppLanguageStore.self) private var languageStore
    @Environment(RemoteLocalizationStore.self) private var remoteStore

    var body: some View {
        List {
            if remoteStore.isLoading {
                ProgressView("remote.loading")
                    .frame(maxWidth: .infinity, alignment: .center)
            } else if let errorMessage = remoteStore.errorMessage {
                Section {
                    Text(errorMessage)
                        .foregroundStyle(.red)
                }
            } else if let client = remoteStore.client {
                AsyncImage(url: client.imageURL) { image in
                    image
                        .resizable()
                        .scaledToFill()
                } placeholder: {
                    ProgressView()
                }
                .frame(height: 220)
                .frame(maxWidth: .infinity)
                .clipShape(RoundedRectangle(cornerRadius: 18))

                Text(client.fullName)
                    .font(.title3.bold())

                Text(client.email)
                    .foregroundStyle(.secondary)
            }
        }
        .navigationTitle("remote.title")
        .task(id: languageStore.selectedLanguage) {
            await remoteStore.loadIfNeeded(for: languageStore.selectedLanguage)
        }
        .refreshable {
            await remoteStore.reload(for: languageStore.selectedLanguage)
        }
    }
}
