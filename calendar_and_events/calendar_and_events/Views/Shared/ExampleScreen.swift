import SwiftUI

struct ExampleScreen<Content: View>: View {
    let title: String
    let description: String
    @ViewBuilder var content: Content

    var body: some View {
        List {
            Section {
                VStack(alignment: .leading, spacing: 8) {
                    Text(title)
                        .font(.title2.weight(.semibold))

                    Text(description)
                        .foregroundStyle(.secondary)
                }
                .padding(.vertical, 4)
            }

            content
        }
        .navigationTitle(title)
        .navigationBarTitleDisplayMode(.inline)
    }
}
