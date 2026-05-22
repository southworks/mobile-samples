import AVKit
import SwiftUI

struct PictureInPictureExample: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Enable Background Modes > Audio, AirPlay, and Picture in Picture in Xcode.")
                .font(.subheadline)
                .foregroundStyle(.secondary)

            if let url = URL(string: SampleMediaURLs.vod) {
                PictureInPicturePlayerView(url: url)
                    .frame(height: 240)
            } else {
                Text("Invalid Picture in Picture URL.")
            }
        }
        .padding()
        .navigationTitle("Picture in Picture")
        .navigationBarTitleDisplayMode(.inline)
    }
}

private struct PictureInPicturePlayerView: UIViewControllerRepresentable {
    let url: URL

    func makeUIViewController(context: Context) -> AVPlayerViewController {
        let controller = AVPlayerViewController()
        controller.allowsPictureInPicturePlayback = true
        controller.canStartPictureInPictureAutomaticallyFromInline = true

        let player = AVPlayer(url: url)
        controller.player = player
        player.play()

        return controller
    }

    func updateUIViewController(_ uiViewController: AVPlayerViewController, context: Context) {}

    static func dismantleUIViewController(_ uiViewController: AVPlayerViewController, coordinator: ()) {
        uiViewController.player?.pause()
    }
}

#Preview {
    NavigationStack {
        PictureInPictureExample()
    }
}
