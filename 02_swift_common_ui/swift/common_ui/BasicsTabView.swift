//
//  BasicsTabView.swift
//  common_ui
//

import SwiftUI

struct BasicsMenuView: View {
    var body: some View {
        NavigationStack {
            List {
                NavigationLink("Text") {
                    TextExampleView()
                }

                NavigationLink("Label") {
                    LabelExampleView()
                }

                NavigationLink("Image") {
                    ImageExampleView()
                }

                NavigationLink("AsyncImage") {
                    AsyncImageExampleView()
                }

                NavigationLink("ProgressView") {
                    ProgressExampleView()
                }

                NavigationLink("Divider") {
                    DividerExampleView()
                }
            }
            .navigationTitle("Basics")
        }
    }
}

private struct TextExampleView: View {
    var body: some View {
        ExampleScreen("Text") {
            Text("SwiftUI makes text styling simple.")
                .font(.title2)

            Text("This line uses a secondary style for supporting information.")
                .foregroundStyle(.secondary)

            Text("Bold, italic and underlined")
                .bold()
                .italic()
                .underline()
        }
    }
}

private struct LabelExampleView: View {
    var body: some View {
        ExampleScreen("Label") {
            Label("Favorites", systemImage: "star.fill")
            Label("Downloads", systemImage: "arrow.down.circle")
                .foregroundStyle(.blue)
            Label("Profile", systemImage: "person.crop.circle")
                .font(.title3)
        }
    }
}

private struct ImageExampleView: View {
    var body: some View {
        ExampleScreen("Image") {
            Image(systemName: "swift")
                .resizable()
                .scaledToFit()
                .frame(width: 100, height: 100)
                .foregroundStyle(.orange)

            Image(systemName: "photo.stack")
                .font(.system(size: 48))
                .foregroundStyle(.purple)
        }
    }
}

private struct AsyncImageExampleView: View {
    var body: some View {
        ExampleScreen("AsyncImage") {
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
        }
    }
}

private struct ProgressExampleView: View {
    @State private var progress = 0.55

    var body: some View {
        ExampleScreen("ProgressView") {
            ProgressView(value: progress)
            ProgressView("Uploading files...", value: progress)

            Button("Increase Progress") {
                progress = min(progress + 0.1, 1.0)
            }
            .buttonStyle(.borderedProminent)
        }
    }
}

private struct DividerExampleView: View {
    var body: some View {
        ExampleScreen("Divider") {
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
}
