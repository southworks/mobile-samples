import AVFoundation
import SwiftUI

struct AudioPlayerExample: View {
    @State private var player: AVPlayer?
    @State private var errorMessage: String?

    var body: some View {
        VStack(spacing: 20) {
            if let errorMessage {
                Text(errorMessage)
                    .foregroundStyle(.secondary)
            }

            HStack(spacing: 16) {
                Button("Play") {
                    player?.play()
                }
                .buttonStyle(.borderedProminent)

                Button("Pause") {
                    player?.pause()
                }
                .buttonStyle(.bordered)

                Button("Stop") {
                    player?.pause()
                    player?.seek(to: .zero)
                }
                .buttonStyle(.bordered)
            }
        }
        .padding()
        .navigationTitle("Audio Player")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            configureAudio()
            preparePlayer()
        }
        .onDisappear {
            player?.pause()
        }
    }

    private func configureAudio() {
        do {
            let session = AVAudioSession.sharedInstance()
            try session.setCategory(.playback, mode: .default)
            try session.setActive(true)
        } catch {
            errorMessage = "Unable to configure audio session."
        }
    }

    private func preparePlayer() {
        guard let url = URL(string: SampleMediaURLs.audio) else {
            errorMessage = "Invalid audio URL."
            player = nil
            return
        }

        player = AVPlayer(url: url)
        if errorMessage == "Invalid audio URL." {
            errorMessage = nil
        }
    }
}

#Preview {
    NavigationStack {
        AudioPlayerExample()
    }
}
