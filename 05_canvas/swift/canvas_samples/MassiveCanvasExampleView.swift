//
//  MassiveCanvasExampleView.swift
//  canvas_samples
//
//  Created by ec2-user on 5/12/26.
//

import PencilKit
import SwiftUI

struct MassiveCanvasExampleView: View {
    @State private var drawing = PKDrawing()
    @StateObject private var controller = MassiveCanvasController()
    @State private var exportURL: URL?

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Button("Rectangulo", systemImage: "rectangle") {
                    controller.insertRectangle()
                }
                .buttonStyle(.bordered)

                Button("Elipse", systemImage: "oval") {
                    controller.insertEllipse()
                }
                .buttonStyle(.bordered)

                Button("Flecha", systemImage: "arrow.right") {
                    controller.insertArrow()
                }
                .buttonStyle(.bordered)

                Spacer()

                Menu("Exportar") {
                    Button("PNG", systemImage: "photo") {
                        exportURL = controller.exportPNG()
                    }

                    Button("PDF", systemImage: "doc.richtext") {
                        exportURL = controller.exportPDF()
                    }
                }
                .buttonStyle(.borderedProminent)
            }

            MassivePencilCanvasView(drawing: $drawing, controller: controller)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
                .overlay {
                    RoundedRectangle(cornerRadius: 20, style: .continuous)
                        .stroke(Color.secondary.opacity(0.2), lineWidth: 1)
                }
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .navigationTitle("Massive Canvas")
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: Binding(
            get: { exportURL != nil },
            set: { if !$0 { exportURL = nil } }
        )) {
            if let exportURL {
                ShareSheet(items: [exportURL])
            }
        }
    }
}

private struct ShareSheet: UIViewControllerRepresentable {
    let items: [Any]

    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: items, applicationActivities: nil)
    }

    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}

#Preview {
    NavigationStack {
        MassiveCanvasExampleView()
    }
}
