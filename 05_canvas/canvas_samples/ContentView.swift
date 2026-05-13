//
//  ContentView.swift
//  canvas_samples
//
//  Created by ec2-user on 5/12/26.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        NavigationStack {
            List {
                Section("Ejemplos") {
                    NavigationLink {
                        SimpleCanvasExampleView()
                    } label: {
                        ExampleRow(
                            title: "Canvas simple",
                            subtitle: "Dibujo libre con PencilKit integrado en SwiftUI.",
                            systemImage: "pencil.and.scribble"
                        )
                    }

                    NavigationLink {
                        SavedCanvasExampleView()
                    } label: {
                        ExampleRow(
                            title: "Canvas + SwiftData",
                            subtitle: "Carga y guarda el dibujo usando SwiftData.",
                            systemImage: "externaldrive.badge.checkmark"
                        )
                    }

                    NavigationLink {
                        InfiniteCanvasExampleView()
                    } label: {
                        ExampleRow(
                            title: "Canvas infinito",
                            subtitle: "Un lienzo enorme centrado en el medio para pan y zoom.",
                            systemImage: "arrow.up.left.and.arrow.down.right"
                        )
                    }
                }

                Section("Notas") {
                    Text("Los tres ejemplos usan PencilKit. El segundo persiste `PKDrawing.dataRepresentation()` y el tercero crea un lienzo gigante inspirado en la idea de ubicar al usuario en el centro del area de dibujo.")
                        .font(.callout)
                        .foregroundStyle(.secondary)
                }
            }
            .navigationTitle("Canvas Samples")
        }
    }
}

private struct ExampleRow: View {
    let title: String
    let subtitle: String
    let systemImage: String

    var body: some View {
        HStack(alignment: .top, spacing: 14) {
            Image(systemName: systemImage)
                .font(.title2)
                .frame(width: 28)
                .foregroundStyle(.accent)

            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.headline)

                Text(subtitle)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            .padding(.vertical, 2)
        }
        .padding(.vertical, 4)
    }
}

#Preview {
    ContentView()
        .modelContainer(for: SavedDrawing.self, inMemory: true)
}
