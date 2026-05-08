import SwiftUI

struct InfoBoxView: View {
    let title: String
    let storageLocation: String
    let persistence: String

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.headline)

            Text(storageLocation)
                .font(.subheadline)
                .foregroundStyle(.secondary)

            Text(persistence)
                .font(.footnote)
                .foregroundStyle(.secondary)
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(uiColor: .secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 14))
    }
}

#Preview {
    InfoBoxView(
        title: "Stored in the Documents directory",
        storageLocation: "This sample writes JSON with FileManager.",
        persistence: "Persists until the file is deleted or the app is removed."
    )
    .padding()
}
