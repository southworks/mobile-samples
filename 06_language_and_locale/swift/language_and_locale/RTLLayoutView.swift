//
//  RTLLayoutView.swift
//  language_and_locale
//
//  Created by ec2-user on 5/19/26.
//

import SwiftUI

struct RTLLayoutView: View {
    @Environment(LocalizationStore.self) private var localizationStore

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                HStack(spacing: 12) {
                    Image(systemName: "globe")
                        .font(.system(size: 28))
                        .frame(width: 52, height: 52)
                        .background(Color.accentColor.opacity(0.15), in: RoundedRectangle(cornerRadius: 14))

                    VStack(alignment: .leading, spacing: 6) {
                        Text(localizationStore.text("rtl.cardTitle", defaultValue: "Adaptive row"))
                            .font(.headline)

                        Text(localizationStore.text("rtl.cardBody", defaultValue: "No left or right constraints are hard-coded in this sample."))
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }

                    Spacer(minLength: 0)

                    Image(systemName: "chevron.forward")
                        .foregroundStyle(.secondary)
                }
                .padding()
                .background(Color(.secondarySystemBackground), in: RoundedRectangle(cornerRadius: 18))

                LabeledContent(
                    localizationStore.text("rtl.currentDirection", defaultValue: "Current direction"),
                    value: localizationStore.layoutDescription
                )
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding()
        }
        .navigationTitle(localizationStore.text("rtl.title", defaultValue: "RTL Layout"))
    }
}
