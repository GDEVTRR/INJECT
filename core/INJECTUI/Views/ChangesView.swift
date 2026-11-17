
import SwiftUI

struct ChangesView: View {

    @ObservedObject var engine: INJECTEngine

    @State private var changes: [PlistChange] = []
    @State private var errorMessage: String?

    var body: some View {
        NavigationStack {
            Group {
                if !engine.hasDocument {
                    ContentUnavailableView(
                        "No PLIST Loaded",
                        systemImage: "doc.text",
                        description: Text("Open a plist file first.")
                    )

                } else if let errorMessage {
                    ContentUnavailableView(
                        "Could Not Load Changes",
                        systemImage: "exclamationmark.triangle",
                        description: Text(errorMessage)
                    )

                } else if changes.isEmpty {
                    ContentUnavailableView(
                        "No Changes",
                        systemImage: "checkmark.circle",
                        description: Text("There are no pending changes.")
                    )

                } else {
                    List {
                        ForEach(changes) { change in
                            VStack(alignment: .leading, spacing: 8) {

                                HStack {
                                    Text(change.path.description)
                                        .font(.headline)
                                        .lineLimit(2)

                                    Spacer()

                                    Text(changeTypeName(change.type))
                                        .font(.caption.bold())
                                        .foregroundStyle(changeColor(change.type))
                                }

                                if let oldValue = change.oldValue {
                                    VStack(alignment: .leading, spacing: 3) {
                                        Text("OLD")
                                            .font(.caption2.bold())
                                            .foregroundStyle(.secondary)

                                        Text(oldValue)
                                            .font(.caption)
                                            .textSelection(.enabled)
                                    }
                                }

                                if let newValue = change.newValue {
                                    VStack(alignment: .leading, spacing: 3) {
                                        Text("NEW")
                                            .font(.caption2.bold())
                                            .foregroundStyle(.secondary)

                                        Text(newValue)
                                            .font(.caption)
                                            .textSelection(.enabled)
                                    }
                                }
                            }
                            .padding(.vertical, 5)
                        }
                    }
                }
            }
            .navigationTitle("Changes")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        refreshChanges()
                    } label: {
                        Image(systemName: "arrow.clockwise")
                    }
                    .disabled(!engine.hasDocument)
                }
            }
            .onAppear {
                refreshChanges()
            }
            .onChange(of: engine.hasDocument) { _, _ in
                refreshChanges()
            }
            .onReceive(engine.objectWillChange) { _ in
                DispatchQueue.main.async {
                    refreshChanges()
                }
            }
        }
    }

    private func refreshChanges() {
        do {
            changes = try engine.changes()
            errorMessage = nil
        } catch {
            changes = []
            errorMessage = error.localizedDescription
        }
    }

    private func changeTypeName(_ type: PlistChangeType) -> String {
        switch type {
        case .added:
            return "ADDED"
        case .modified:
            return "MODIFIED"
        case .removed:
            return "REMOVED"
        }
    }

    private func changeColor(_ type: PlistChangeType) -> Color {
        switch type {
        case .added:
            return .green
        case .modified:
            return .orange
        case .removed:
            return .red
        }
    }
}
