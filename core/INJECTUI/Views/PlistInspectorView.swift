
import SwiftUI

struct PlistInspectorView: View {

    let document: PlistDocument

    var body: some View {
        NavigationStack {
            List {

                Section("Document") {
                    LabeledContent(
                        "Root Type",
                        value: document.isDictionary ? "Dictionary" :
                            document.isArray ? "Array" : "Other"
                    )

                    LabeledContent(
                        "Source",
                        value: document.sourceURL?.lastPathComponent ?? "Imported"
                    )
                }

                Section("Contents") {
                    if let dictionary = document.root as? [String: Any] {

                        ForEach(dictionary.keys.sorted(), id: \.self) { key in
                            if let value = dictionary[key] {

                                NavigationLink {
                                    PlistValueDetailView(
                                        title: key,
                                        value: value
                                    )
                                } label: {
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text(key)
                                            .font(.headline)

                                        Text(PlistValueKind.detect(value).displayName)
                                            .font(.caption)
                                            .foregroundStyle(.secondary)
                                    }
                                }
                            }
                        }

                    } else if let array = document.root as? [Any] {

                        ForEach(array.indices, id: \.self) { index in
                            NavigationLink {
                                PlistValueDetailView(
                                    title: "Item \(index)",
                                    value: array[index]
                                )
                            } label: {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text("Item \(index)")
                                        .font(.headline)

                                    Text(PlistValueKind.detect(array[index]).displayName)
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                }
                            }
                        }

                    } else {
                        Text("Unsupported root type.")
                            .foregroundStyle(.secondary)
                    }
                }
            }
            .navigationTitle("PLIST Inspector")
        }
    }
}

struct PlistValueDetailView: View {

    let title: String
    let value: Any

    private var valueKind: PlistValueKind {
        PlistValueKind.detect(value)
    }

    private var formattedValue: String {
        (try? PlistValueParser.text(
            from: value,
            as: valueKind
        )) ?? String(describing: value)
    }

    var body: some View {
        Form {

            Section("Field") {
                LabeledContent("Name", value: title)
                LabeledContent("Type", value: valueKind.displayName)
            }

            Section("Value") {
                Text(formattedValue)
                    .textSelection(.enabled)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
        .navigationTitle(title)
        .navigationBarTitleDisplayMode(.inline)
    }
}
