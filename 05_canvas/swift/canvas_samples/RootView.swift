//
//  RootView.swift
//  canvas_samples
//
//  Created by ec2-user on 5/12/26.
//

import SwiftUI

struct RootView: View {
    var body: some View {
        NavigationStack {
            List {
                Section("Ejemplos") {
                    NavigationLink {
                        SimpleCanvasExampleView()
                    } label: {
                        Row(
                            title: "Simple Canvas",
                            systemImage: "pencil.and.scribble"
                        )
                    }

                    NavigationLink {
                        SavedCanvasExampleView()
                    } label: {
                        Row(
                            title: "Canvas + SwiftData",
                            systemImage: "externaldrive.badge.checkmark"
                        )
                    }

                    NavigationLink {
                        MassiveCanvasExampleView()
                    } label: {
                        Row(
                            title: "Massive Canvas",
                            systemImage: "arrow.up.left.and.arrow.down.right"
                        )
                    }

                    NavigationLink {
                        HostedExcalidrawExampleView()
                    } label: {
                        Row(
                            title: "Hosted Excalidraw",
                            systemImage: "safari"
                        )
                    }
                }
            }
            .navigationTitle("Canvas Samples")
        }
    }
}

private struct Row: View {
    let title: String
    let systemImage: String

    var body: some View {
        HStack(alignment: .top, spacing: 14) {
            Image(systemName: systemImage)
                .font(.title2)
                .frame(width: 28)
                .foregroundStyle(.orange)

            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.headline)
            }
            .padding(.vertical, 2)
        }
        .padding(.vertical, 4)
    }
}
