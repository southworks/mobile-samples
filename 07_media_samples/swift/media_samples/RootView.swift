import SwiftUI

struct RootView: View {
    var body: some View {
        NavigationStack {
            List {
                NavigationLink("VOD Player") {
                    VODPlayerExample()
                }

                NavigationLink("Live Streaming") {
                    LiveStreamingExample()
                }

                NavigationLink("Audio Player") {
                    AudioPlayerExample()
                }

                NavigationLink("Picture in Picture") {
                    PictureInPictureExample()
                }

                NavigationLink("YouTube Embed") {
                    YouTubeEmbedExample(videoID: "dQw4w9WgXcQ")
                }
            }
            .navigationTitle("Media Examples")
        }
    }
}

#Preview {
    RootView()
}
