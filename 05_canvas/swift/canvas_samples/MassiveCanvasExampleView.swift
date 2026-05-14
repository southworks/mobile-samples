//
//  MassiveCanvasExampleView.swift
//  canvas_samples
//
//  Created by ec2-user on 5/12/26.
//

import PencilKit
import SwiftData
import SwiftUI

struct MassiveCanvasExampleView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.scenePhase) private var scenePhase
    @Query(sort: \BoardDocument.updatedAt, order: .reverse) private var documents: [BoardDocument]

    @State private var title = "Untitled board"
    @State private var drawing = PKDrawing()
    @State private var items: [BoardItem] = []
    @State private var mode: BoardInteractionMode = .draw
    @State private var selectedItemID: UUID?
    @State private var pendingArrowSourceID: UUID?
    @State private var recordID: PersistentIdentifier?
    @State private var hasLoadedRecord = false
    @State private var lastSavedAt: Date?
    @State private var editingTextItemID: UUID?
    @State private var editingTextValue = ""
    @State private var exportedFile: ExportedFile?

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            header
            modeStrip

            if mode == .arrow, let pendingArrowSourceID, let source = items.first(where: { $0.id == pendingArrowSourceID }) {
                Text("Selecciona el destino para conectar desde \"\(source.displayText)\".")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }

            if let selectedItem = selectedItem, mode == .select {
                selectionActions(for: selectedItem)
            }

            MassiveBoardView(
                drawing: $drawing,
                items: $items,
                mode: $mode,
                selectedItemID: $selectedItemID,
                pendingArrowSourceID: $pendingArrowSourceID
            ) { itemID in
                beginTextEditing(for: itemID)
            }
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
        .task {
            loadOrCreateRecordIfNeeded()
        }
        .onDisappear {
            saveDocument()
        }
        .onChange(of: scenePhase) { _, newPhase in
            if newPhase != .active {
                saveDocument()
            }
        }
        .sheet(item: $exportedFile) { file in
            ShareSheet(items: [file.url])
        }
        .sheet(isPresented: Binding(
            get: { editingTextItemID != nil },
            set: { if !$0 { editingTextItemID = nil } }
        )) {
            NavigationStack {
                Form {
                    TextField("Texto", text: $editingTextValue, axis: .vertical)
                        .lineLimit(4...8)
                }
                .navigationTitle("Editar label")
                .toolbar {
                    ToolbarItem(placement: .cancellationAction) {
                        Button("Cancelar") {
                            editingTextItemID = nil
                        }
                    }
                    ToolbarItem(placement: .confirmationAction) {
                        Button("Guardar") {
                            if let editingTextItemID {
                                updateText(for: editingTextItemID)
                            }
                        }
                    }
                }
            }
            .presentationDetents([.medium])
        }
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 12) {
                Menu {
                    Button("Nuevo board", systemImage: "plus") {
                        createBoard()
                    }

                    if !documents.isEmpty {
                        Divider()
                    }

                    ForEach(documents) { document in
                        Button(document.title) {
                            switchToDocument(document)
                        }
                    }
                } label: {
                    Label("Boards", systemImage: "square.stack.3d.up")
                }
                .buttonStyle(.bordered)

                TextField("Titulo del board", text: $title)
                    .textFieldStyle(.roundedBorder)

                Button("Guardar", systemImage: "square.and.arrow.down") {
                    saveDocument()
                }
                .buttonStyle(.borderedProminent)

                Button("Limpiar", systemImage: "trash") {
                    drawing = PKDrawing()
                    items = []
                    selectedItemID = nil
                    pendingArrowSourceID = nil
                    saveDocument()
                }
                .buttonStyle(.bordered)
            }

            HStack(spacing: 12) {
                Button("Exportar PNG", systemImage: "photo") {
                    exportBoard(as: "png")
                }
                .buttonStyle(.bordered)

                Button("Exportar PDF", systemImage: "doc.richtext") {
                    exportBoard(as: "pdf")
                }
                .buttonStyle(.bordered)

                Spacer()

                if let lastSavedAt {
                    Text("Ultimo guardado: \(lastSavedAt, format: .dateTime.hour().minute().second())")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                }
            }
        }
    }

    private var modeStrip: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 10) {
                ForEach(BoardInteractionMode.allCases) { candidate in
                    Button {
                        pendingArrowSourceID = nil
                        mode = candidate
                    } label: {
                        Label(candidate.title, systemImage: candidate.systemImage)
                            .frame(maxHeight: .infinity)
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(mode == candidate ? .orange : .gray.opacity(0.4))
                }
            }
        }
        .frame(height: 40)
    }

    @ViewBuilder
    private func selectionActions(for selectedItem: BoardItem) -> some View {
        HStack(spacing: 12) {
            Text("Seleccionado: \(selectedItem.kind.rawValue)")
                .font(.footnote)
                .foregroundStyle(.secondary)

            if selectedItem.isTextEditable {
                Button("Editar texto", systemImage: "text.cursor") {
                    beginTextEditing(for: selectedItem.id)
                }
                .buttonStyle(.bordered)
            }

            Button("Eliminar", systemImage: "minus.circle") {
                items.removeAll { $0.id == selectedItem.id || $0.sourceItemID == selectedItem.id || $0.targetItemID == selectedItem.id }
                selectedItemID = nil
                pendingArrowSourceID = nil
            }
            .buttonStyle(.bordered)

            Spacer()
        }
    }

    private var selectedItem: BoardItem? {
        guard let selectedItemID else { return nil }
        return items.first(where: { $0.id == selectedItemID })
    }

    private func loadOrCreateRecordIfNeeded() {
        guard !hasLoadedRecord else { return }

        if let existingRecord = documents.first {
            load(document: existingRecord)
        } else {
            createBoard()
        }

        hasLoadedRecord = true
    }

    private func switchToDocument(_ document: BoardDocument) {
        saveDocument()
        load(document: document)
    }

    private func load(document: BoardDocument) {
        recordID = document.persistentModelID
        title = document.title
        drawing = document.drawing
        items = document.boardItems
        lastSavedAt = document.updatedAt
        selectedItemID = nil
        pendingArrowSourceID = nil
        mode = .draw
    }

    private func createBoard() {
        saveDocument()
        let document = BoardDocument(title: "Board \(documents.count + 1)")
        modelContext.insert(document)
        do {
            try modelContext.save()
            load(document: document)
            hasLoadedRecord = true
        } catch {
            assertionFailure("Could not create board: \(error)")
        }
    }

    private func saveDocument() {
        guard let document = activeDocument else { return }
        document.update(title: title, drawing: drawing, items: items)

        do {
            try modelContext.save()
            lastSavedAt = document.updatedAt
        } catch {
            assertionFailure("Could not save board: \(error)")
        }
    }

    private var activeDocument: BoardDocument? {
        guard let recordID else { return documents.first }
        return documents.first(where: { $0.persistentModelID == recordID })
    }

    private func beginTextEditing(for itemID: UUID) {
        guard let item = items.first(where: { $0.id == itemID }), item.isTextEditable else { return }
        editingTextValue = item.text ?? item.displayText
        editingTextItemID = itemID
    }

    private func updateText(for itemID: UUID) {
        guard let index = items.firstIndex(where: { $0.id == itemID }) else { return }
        items[index].text = editingTextValue
        editingTextItemID = nil
    }

    private func exportBoard(as fileExtension: String) {
        let data: Data?
        switch fileExtension {
        case "png":
            data = BoardExporter.pngData(drawing: drawing, items: items)
        case "pdf":
            data = BoardExporter.pdfData(drawing: drawing, items: items)
        default:
            data = nil
        }

        guard let data else { return }
        let baseName = title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
            ? "board-export"
            : title.replacingOccurrences(of: " ", with: "-").lowercased()
        let url = FileManager.default.temporaryDirectory
            .appendingPathComponent(baseName)
            .appendingPathExtension(fileExtension)

        do {
            try data.write(to: url, options: .atomic)
            exportedFile = ExportedFile(url: url)
        } catch {
            assertionFailure("Could not export board: \(error)")
        }
    }
}

#Preview {
    NavigationStack {
        MassiveCanvasExampleView()
            .modelContainer(for: BoardDocument.self, inMemory: true)
    }
}
