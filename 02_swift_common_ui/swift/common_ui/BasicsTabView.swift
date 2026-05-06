//
//  BasicsTabView.swift
//  common_ui
//

import SwiftUI

struct BasicsMenuView: View {
    var body: some View {
        NavigationStack {
            BasicsExampleView()
        }
    }
}

private struct BasicsExampleView: View {
    @State private var progress = 0.55

    var body: some View {
        ExampleScreen("Basics") {
            sectionTitle("Text")
            Text("SwiftUI makes text styling simple.")
                .font(.title2)

            Text("This line uses a secondary style for supporting information.")
                .foregroundStyle(.secondary)

            Text("Bold, italic and underlined")
                .bold()
                .italic()
                .underline()

            Divider()

            sectionTitle("Label")
            Label("Favorites", systemImage: "star.fill")
            Label("Downloads", systemImage: "arrow.down.circle")
                .foregroundStyle(.blue)
            Label("Profile", systemImage: "person.crop.circle")
                .font(.title3)

            Divider()

            sectionTitle("Image")
            Image(systemName: "swift")
                .resizable()
                .scaledToFit()
                .frame(width: 100, height: 100)
                .foregroundStyle(.orange)

            Image(systemName: "photo.stack")
                .font(.system(size: 48))
                .foregroundStyle(.purple)

            Divider()

            sectionTitle("AsyncImage")
            AsyncImage(url: URL(string: "https://picsum.photos/300")) { phase in
                switch phase {
                case .empty:
                    ProgressView("Loading image...")
                case .success(let image):
                    image
                        .resizable()
                        .scaledToFill()
                        .frame(height: 180)
                        .clipped()
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                case .failure:
                    ContentUnavailableView("Image not available", systemImage: "wifi.slash")
                @unknown default:
                    EmptyView()
                }
            }

            Divider()

            sectionTitle("ProgressView")
            ProgressView(value: progress)
            ProgressView("Uploading files...", value: progress)

            Button("Increase Progress") {
                progress = min(progress + 0.1, 1.0)
            }
            .buttonStyle(.borderedProminent)

            Divider()

            sectionTitle("Divider")
            Text("Section A")
            Divider()
            Text("Section B")
            Divider()
            HStack {
                Text("Left")
                Divider()
                Text("Right")
            }
            .frame(height: 40)
        }
    }

    private func sectionTitle(_ title: String) -> some View {
        Text(title)
            .font(.headline)
    }
}
