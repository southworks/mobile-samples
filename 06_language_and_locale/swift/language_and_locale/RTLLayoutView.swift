//
//  RTLLayoutView.swift
//  language_and_locale
//
//  Created by ec2-user on 5/19/26.
//

import SwiftUI

struct RTLLayoutView: View {
    @Environment(AppLanguageStore.self) private var languageStore

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                headerRow
                metricsRow
                buttonsColumn

                LabeledContent(
                    "rtl.currentDirection",
                    value: languageStore.layoutDescription
                )
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding()
        }
        .navigationTitle("RTL")
    }

    private var headerRow: some View {
        HStack(spacing: 12) {
            Image(systemName: "globe")
                .font(.system(size: 28))
                .frame(width: 52, height: 52)
                .background(Color.accentColor.opacity(0.15), in: RoundedRectangle(cornerRadius: 14))

            VStack(alignment: .leading, spacing: 6) {
                Text("rtl.cardTitle")
                    .font(.headline)

                Text("rtl.cardBody")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }

            Spacer(minLength: 0)

            Image(systemName: "chevron.forward")
                .foregroundStyle(.secondary)
        }
        .padding()
        .background(Color(.secondarySystemBackground), in: RoundedRectangle(cornerRadius: 18))
    }

    private var metricsRow: some View {
        HStack(spacing: 12) {
            metricCard(
                title: "rtl.balance",
                value: "$128"
            )

            metricCard(
                title: "rtl.orders",
                value: "12"
            )
        }
    }

    private var buttonsColumn: some View {
        VStack(spacing: 12) {
            actionRow(
                title: "rtl.primaryAction",
                icon: "arrow.forward.circle.fill",
                prominent: true
            )

            actionRow(
                title: "rtl.secondaryAction",
                icon: "slider.horizontal.3",
                prominent: false
            )
        }
    }

    private func metricCard(title: LocalizedStringKey, value: String) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title)
                .font(.caption)
                .foregroundStyle(.secondary)

            Text(value)
                .font(.headline)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(Color(.secondarySystemBackground), in: RoundedRectangle(cornerRadius: 16))
    }

    private func actionRow(title: LocalizedStringKey, icon: String, prominent: Bool) -> some View {
        HStack {
            if prominent == false {
                Image(systemName: icon)
            }

            Text(title)
                .frame(maxWidth: .infinity)

            if prominent {
                Image(systemName: icon)
            }
        }
        .font(.headline)
        .padding()
        .foregroundStyle(prominent ? .white : .primary)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(prominent ? Color.accentColor : Color(.secondarySystemBackground))
        )
    }
}
