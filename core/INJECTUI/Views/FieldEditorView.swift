
import SwiftUI

struct FieldEditorView: View {

    @ObservedObject var engine: INJECTEngine

    private var fields: [(String, Any)] {

        guard let dictionary = engine.document?.root as? [String: Any] else {
            return []
        }

        return dictionary.keys.sorted().compactMap { key in
            guard let value = dictionary[key] else {
                return nil
            }

            return (key, value)
        }
    }

    var body: some View {
        NavigationStack {
            Group {

                if !engine.hasDocument {

                    ContentUnavailableView(
                        "No PLIST Loaded",
                        systemImage: "doc.text",
                        description: Text(
                            "Open a plist file from File Manager first."
                        )
                    )

                } else if fields.isEmpty {

                    ContentUnavailableView(
                        "No Fields Found",
                        systemImage: "list.bullet",
                        description: Text(
                            "This document has no root dictionary fields."
                        )
                    )

                } else {

                    List {
                        Section("Available Fields") {

                            ForEach(fields, id: \.0) { field in

                                NavigationLink {
                                    PlistValueEditorView(
                                        engine: engine,
                                        key: field.0,
                                        path: PlistPath().appending(
                                            key: field.0
                                        ),
                                        originalValue: field.1
                                    )
                                } label: {

                                    VStack(
                                        alignment: .leading,
                                        spacing: 5
                                    ) {

                                        Text(field.0)
                                            .font(.headline)

                                        Text(
                                            PlistValueKind.detect(
                                                field.1
                                            ).displayName
                                        )
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                    }
                                }
                            }
                        }
                    }
                }
            }
            .navigationTitle("Field Editor")
        }
    }
}
