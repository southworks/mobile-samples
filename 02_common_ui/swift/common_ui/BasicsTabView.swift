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
            Text("Text with title font.")
                .font(.title2)

            Text("Text with secondary style.")
                .foregroundStyle(.secondary)

            Text("Text with bold, italic and underline styles.")
                .bold()
                .italic()
                .underline()

            Divider()

            sectionTitle("Label")
            Label("Star label", systemImage: "star.fill")
            Label("Down arrow label", systemImage: "arrow.down.circle")
                .foregroundStyle(.blue)
            Label("Person crop label", systemImage: "person.crop.circle")
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

            Button("Increase") {
                progress = min(progress + 0.1, 1.0)
            }
            .buttonStyle(.borderedProminent)
            Button("Decrease") {
                progress = max(progress - 0.1, 0.0)
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
