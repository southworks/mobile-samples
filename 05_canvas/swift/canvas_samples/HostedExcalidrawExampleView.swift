//
//  HostedExcalidrawExampleView.swift
//  canvas_samples
//
//  Created by Codex on 5/18/26.
//

import SwiftUI
import WebKit
internal import os

struct HostedExcalidrawExampleView: View {
    @State private var pageTitle = "Loading..."
    @State private var isLoading = false

    private let siteURL = AppEnvironment.canvasURL

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 12) {
                Label(isLoading ? "Loading" : "Ready", systemImage: isLoading ? "arrow.triangle.2.circlepath" : "checkmark.circle")
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

            Text("Current URL: \(siteURL.absoluteString). The value comes from the CANVAS_URL environment variable in the scheme.")
                .font(.footnote)
                .foregroundStyle(.secondary)
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .navigationTitle("Hosted Excalidraw")
        .navigationBarTitleDisplayMode(.inline)
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
        HostedWebViewConsoleHelper.install(on: configuration.userContentController, handler: context.coordinator)

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

    final class Coordinator: NSObject, WKNavigationDelegate, WKScriptMessageHandler, HostedWebViewConsoleHandling {
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
            parent.pageTitle = "Failed to Load"
            AppLogger.webView.error("didFail error=\(error.localizedDescription, privacy: .public)")
            AppLogger.webView.error("didFail details=\(String(describing: error), privacy: .public)")
        }

        func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
            parent.isLoading = false
            parent.pageTitle = "Failed to Load"
            AppLogger.webView.error("didFailProvisionalNavigation error=\(error.localizedDescription, privacy: .public)")
            AppLogger.webView.error("didFailProvisionalNavigation details=\(String(describing: error), privacy: .public)")
        }

        func handleConsoleMessage(level: String, values: [String]) {
            let message = values.joined(separator: " ")
            switch level {
            case "error":
                AppLogger.webView.error("console.error \(message, privacy: .public)")
            case "warn":
                AppLogger.webView.error("console.warn \(message, privacy: .public)")
            default:
                break
            }
        }

        func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
            guard message.name == HostedWebViewConsoleHelper.handlerName else { return }
            if let body = message.body as? [String: Any] {
                let level = body["level"] as? String ?? "log"
                let values = body["values"] as? [String] ?? []
                handleConsoleMessage(level: level, values: values)
            } else {
                handleConsoleMessage(level: "log", values: [String(describing: message.body)])
            }
        }
    }
}

private protocol HostedWebViewConsoleHandling: AnyObject {
    func handleConsoleMessage(level: String, values: [String])
}

private enum HostedWebViewConsoleHelper {
    static let handlerName = "canvasConsole"

    static func install(on controller: WKUserContentController, handler: any HostedWebViewConsoleHandling & WKScriptMessageHandler) {
        controller.add(handler, name: handlerName)
        controller.addUserScript(WKUserScript(
            source: """
            (function() {
              const levels = ['log', 'info', 'warn', 'error'];
              levels.forEach(function(level) {
                const original = console[level];
                console[level] = function() {
                  try {
                    window.webkit.messageHandlers.\(handlerName).postMessage({
                      level: level,
                      values: Array.from(arguments).map(function(value) {
                        if (typeof value === 'string') return value;
                        try { return JSON.stringify(value); } catch (_) { return String(value); }
                      })
                    });
                  } catch (_) {}
                  original.apply(console, arguments);
                };
              });
            })();
            """,
            injectionTime: .atDocumentStart,
            forMainFrameOnly: false
        ))
    }
}

#Preview {
    NavigationStack {
        HostedExcalidrawExampleView()
    }
}
