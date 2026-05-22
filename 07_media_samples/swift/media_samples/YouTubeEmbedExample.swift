import SwiftUI
import WebKit

struct YouTubeEmbedExample: View {
    let videoID: String

    var body: some View {
        YouTubeWebView(videoID: videoID)
            .navigationTitle("YouTube Embed")
            .navigationBarTitleDisplayMode(.inline)
    }
}

private struct YouTubeWebView: UIViewRepresentable {
    let videoID: String

    func makeUIView(context: Context) -> WKWebView {
        let configuration = WKWebViewConfiguration()
        configuration.allowsInlineMediaPlayback = true
        configuration.mediaTypesRequiringUserActionForPlayback = []

        let webView = WKWebView(frame: .zero, configuration: configuration)
        webView.scrollView.isScrollEnabled = false
        webView.loadHTMLString(html(for: videoID), baseURL: nil)
        return webView
    }

    func updateUIView(_ uiView: WKWebView, context: Context) {}

    private func html(for videoID: String) -> String {
        """
        <!DOCTYPE html>
        <html>
        <head>
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <style>
        body { margin: 0; background: #000; }
        iframe { width: 100vw; height: 100vh; border: 0; }
        </style>
        </head>
        <body>
        <iframe
          src="https://www.youtube.com/embed/\(videoID)?playsinline=1"
          allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture"
          allowfullscreen>
        </iframe>
        </body>
        </html>
        """
    }
}

#Preview {
    NavigationStack {
        YouTubeEmbedExample(videoID: "dQw4w9WgXcQ")
    }
}
