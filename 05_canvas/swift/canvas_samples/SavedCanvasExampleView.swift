//
//  SavedCanvasExampleView.swift
//  canvas_samples
//
//  Created by ec2-user on 5/12/26.
//

import PencilKit
import SwiftData
import SwiftUI

struct SavedCanvasExampleView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.scenePhase) private var scenePhase
    @Query(sort: \SavedDrawing.updatedAt, order: .reverse) private var savedDrawings: [SavedDrawing]

    @State private var drawing = PKDrawing()
    @State private var recordID: PersistentIdentifier?
    @State private var hasLoadedRecord = false
    @State private var lastSavedAt: Date?

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Canvas + SwiftData")
                .font(.title2.weight(.semibold))
            
            HStack {
                Button("Guardar", systemImage: "square.and.arrow.down") {
                    saveDrawing()
                }
                .buttonStyle(.borderedProminent)

                Button("Limpiar", systemImage: "trash") {
                    drawing = PKDrawing()
                    saveDrawing()
                }
                .buttonStyle(.bordered)

                Spacer()

                if let lastSavedAt {
                    Text("Ultimo guardado: \(lastSavedAt, format: .dateTime.hour().minute().second())")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                }
            }

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
        .navigationTitle("Canvas + SwiftData")
        .navigationBarTitleDisplayMode(.inline)
        .task {
            loadOrCreateRecordIfNeeded()
        }
        .onDisappear {
            saveDrawing()
        }
        .onChange(of: scenePhase) { _, newPhase in
            if newPhase != .active {
                saveDrawing()
            }
        }
    }

    private func loadOrCreateRecordIfNeeded() {
        guard !hasLoadedRecord else { return }

        if let existingRecord = savedDrawings.first {
            recordID = existingRecord.persistentModelID
            drawing = existingRecord.drawing
            lastSavedAt = existingRecord.updatedAt
        } else {
            let newRecord = SavedDrawing()
            modelContext.insert(newRecord)
            try? modelContext.save()
            recordID = newRecord.persistentModelID
            lastSavedAt = newRecord.updatedAt
        }

        hasLoadedRecord = true
    }

    private func saveDrawing() {
        guard hasLoadedRecord else { return }
        guard let record = activeRecord else { return }

        record.drawingData = drawing.dataRepresentation()
        record.updatedAt = .now

        do {
            try modelContext.save()
            lastSavedAt = record.updatedAt
        } catch {
            assertionFailure("Could not save drawing: \(error)")
        }
    }

    private var activeRecord: SavedDrawing? {
        guard let recordID else { return savedDrawings.first }
        return savedDrawings.first(where: { $0.persistentModelID == recordID })
    }
}

#Preview {
    NavigationStack {
        SavedCanvasExampleView()
            .modelContainer(for: SavedDrawing.self, inMemory: true)
    }
}
