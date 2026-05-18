//
//  AppLogger.swift
//  canvas_samples
//
//  Created by Codex on 5/18/26.
//

import Foundation
import OSLog

enum AppLogger {
    static let webView = Logger(
        subsystem: Bundle.main.bundleIdentifier ?? "canvas_samples",
        category: "WebView"
    )
}
