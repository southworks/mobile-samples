//
//  SimpleCanvasExampleView.swift
//  canvas_samples
//
//  Created by ec2-user on 5/12/26.
//

import PencilKit
import SwiftUI

struct SimpleCanvasExampleView: View {
    @State private var drawing = PKDrawing()

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Canvas simple")
                .font(.title2.weight(.semibold))

            PencilCanvasView(drawing: $drawing)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
                .overlay {
                    RoundedRectangle(cornerRadius: 20, style: .continuous)
                        .stroke(Color.secondary.opacity(0.2), lineWidth: 1)
                }
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .navigationTitle("Canvas simple")
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    NavigationStack {
        SimpleCanvasExampleView()
    }
}
