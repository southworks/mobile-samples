import AVKit
import SwiftUI

struct VODPlayerExample: View {
    private let player: AVPlayer? = {
        guard let url = URL(string: SampleMediaURLs.vod) else {
            return nil
        }
        return AVPlayer(url: url)
    }()

    var body: some View {
        Group {
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
                Text("Invalid VOD URL.")
            }
        }
        .padding()
        .navigationTitle("VOD Player")
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    NavigationStack {
        VODPlayerExample()
    }
}
