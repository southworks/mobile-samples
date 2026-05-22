import AVKit
import SwiftUI

struct LiveStreamingExample: View {
    private let player: AVPlayer? = {
        guard let url = URL(string: SampleMediaURLs.liveStream) else {
            return nil
        }
        return AVPlayer(url: url)
    }()

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("This example uses a public live HLS test stream.")
                .font(.subheadline)
                .foregroundStyle(.secondary)

            if let player {
                VideoPlayer(player: player)
                    .aspectRatio(16 / 9, contentMode: .fit)
                    .onAppear {
                        player.play()
                    }
                    .onDisappear {
                        player.pause()
                    }
            } else {
                Text("Invalid live stream URL.")
            }
        }
        .padding()
        .navigationTitle("Live Streaming")
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    NavigationStack {
        LiveStreamingExample()
    }
}
