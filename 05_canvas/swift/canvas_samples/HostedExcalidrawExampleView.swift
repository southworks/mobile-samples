//
//  HostedExcalidrawExampleView.swift
//  canvas_samples
//
//  Created by Codex on 5/18/26.
//

import SwiftUI
import WebKit

struct HostedExcalidrawExampleView: View {
    @State private var pageTitle = "Cargando..."
    @State private var isLoading = false

    private let siteURL = ExcalidrawEnvironment.siteURL

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 12) {
                Label(isLoading ? "Cargando" : "Listo", systemImage: isLoading ? "arrow.triangle.2.circlepath" : "checkmark.circle")
                    .foregroundStyle(isLoading ? .orange : .green)

                Spacer()

                Text(pageTitle)
                    .font(.footnote)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
            }

            ExcalidrawWebView(url: siteURL, pageTitle: $pageTitle, isLoading: $isLoading)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
                .overlay {
                    RoundedRectangle(cornerRadius: 20, style: .continuous)
                        .stroke(Color.secondary.opacity(0.2), lineWidth: 1)
                }

            Text("URL actual: \(siteURL.absoluteString). El valor se toma de la configuracion del ambiente actual.")
                .font(.footnote)
                .foregroundStyle(.secondary)
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .navigationTitle("Hosted Excalidraw")
        .navigationBarTitleDisplayMode(.inline)
    }
}

private enum ExcalidrawEnvironment {
    static var siteURL: URL {
        if let value = Bundle.main.object(forInfoDictionaryKey: "ExcalidrawBaseURL") as? String,
           let url = URL(string: value),
           !value.isEmpty {
            return url
        }

        return URL(string: "http://localhost:3000")!
    }
}

private struct ExcalidrawWebView: UIViewRepresentable {
    let url: URL
    @Binding var pageTitle: String
    @Binding var isLoading: Bool

    func makeCoordinator() -> Coordinator {
        Coordinator(parent: self)
    }

    func makeUIView(context: Context) -> WKWebView {
        let configuration = WKWebViewConfiguration()
        configuration.allowsInlineMediaPlayback = true
        configuration.defaultWebpagePreferences.allowsContentJavaScript = true

        let webView = WKWebView(frame: .zero, configuration: configuration)
        webView.navigationDelegate = context.coordinator
        webView.allowsBackForwardNavigationGestures = false
        webView.scrollView.contentInsetAdjustmentBehavior = .never
        webView.load(URLRequest(url: url))
        return webView
    }

    func updateUIView(_ uiView: WKWebView, context: Context) {
        guard uiView.url != url else { return }
        uiView.load(URLRequest(url: url))
    }

    final class Coordinator: NSObject, WKNavigationDelegate {
        var parent: ExcalidrawWebView

        init(parent: ExcalidrawWebView) {
            self.parent = parent
        }

        func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
            parent.isLoading = true
        }

        func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
            parent.isLoading = false
            parent.pageTitle = webView.title ?? "Excalidraw"
        }

        func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
            parent.isLoading = false
            parent.pageTitle = "Error al cargar"
        }

        func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
            parent.isLoading = false
            parent.pageTitle = "Error al cargar"
        }
    }
}

#Preview {
    NavigationStack {
        HostedExcalidrawExampleView()
    }
}
