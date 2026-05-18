//
//  AppEnvironment.swift
//  canvas_samples
//
//  Created by Codex on 5/18/26.
//

import Foundation

enum AppEnvironment {
    private static let variables = ProcessInfo.processInfo.environment

    static var canvasURL: URL {
        url(forKey: "CANVAS_URL", fallback: "http://localhost:3000")
    }

    static func url(forKey key: String, fallback: String) -> URL {
        if let value = variables[key],
           let url = URL(string: value),
           !value.isEmpty {
            return url
        }

        return URL(string: fallback)!
    }
}
