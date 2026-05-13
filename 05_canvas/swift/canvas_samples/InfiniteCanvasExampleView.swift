//
//  InfiniteCanvasExampleView.swift
//  canvas_samples
//
//  Created by ec2-user on 5/12/26.
//

import PencilKit
import SwiftUI

struct InfiniteCanvasExampleView: View {
    @State private var drawing = PKDrawing()

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Canvas infinito")
                .font(.title2.weight(.semibold))

            Text("Este ejemplo crea un lienzo muy grande y posiciona la camara en el centro para poder desplazarte en cualquier direccion. La idea sigue el enfoque del proyecto InfiniteCanvas: un canvas gigantesco que, en practica, se siente infinito.")
                .font(.callout)
                .foregroundStyle(.secondary)

            HStack(spacing: 12) {
                Label("Pan con dos dedos", systemImage: "hand.draw")
                Label("Zoom con pinza", systemImage: "plus.magnifyingglass")
                Spacer()
            }
            .font(.footnote)
            .foregroundStyle(.secondary)

            InfinitePencilCanvasView(drawing: $drawing)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
                .overlay {
                    RoundedRectangle(cornerRadius: 20, style: .continuous)
                        .stroke(Color.secondary.opacity(0.2), lineWidth: 1)
                }
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .navigationTitle("Canvas infinito")
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    NavigationStack {
        InfiniteCanvasExampleView()
    }
}
