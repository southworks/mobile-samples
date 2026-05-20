//
//  RemoteLocalizationView.swift
//  language_and_locale
//
//  Created by ec2-user on 5/19/26.
//

import SwiftUI

struct RemoteLocalizationView: View {
    @Environment(LocalizationStore.self) private var localizationStore
    @Environment(RemoteLocalizationStore.self) private var remoteStore

    var body: some View {
        List {
            if remoteStore.isLoading {
                ProgressView(localizationStore.text("remote.loading", defaultValue: "Loading remote content..."))
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

                LabeledContent(
                    localizationStore.text("remote.requestedLanguage", defaultValue: "Requested"),
                    value: localizationStore.selectedLanguage.rawValue
                )

                LabeledContent(
                    localizationStore.text("remote.resolvedLanguage", defaultValue: "Resolved"),
                    value: client.resolvedLanguage.rawValue
                )
            }
        }
        .navigationTitle(localizationStore.text("remote.title", defaultValue: "Remote Localization"))
        .task(id: localizationStore.selectedLanguage) {
            await remoteStore.loadIfNeeded(for: localizationStore.selectedLanguage)
        }
        .refreshable {
            await remoteStore.reload(for: localizationStore.selectedLanguage)
        }
    }
}
