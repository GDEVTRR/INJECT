
import SwiftUI

struct PlistValueEditorView: View {

    @ObservedObject var engine: INJECTEngine

    let key: String
    let path: PlistPath
    let originalValue: Any

    @Environment(\.dismiss) private var dismiss

    @State private var textValue = ""
    @State private var booleanValue = false
    @State private var errorMessage: String?

    private var valueKind: PlistValueKind {
        PlistValueKind.detect(originalValue)
    }

    var body: some View {
        Form {

            Section("Field Information") {
                LabeledContent("Name", value: key)
                LabeledContent("Type", value: valueKind.displayName)
            }

            Section("Value") {

                switch valueKind {

                case .boolean:
                    Toggle("Enabled", isOn: $booleanValue)

                case .string, .integer, .real, .date, .data:
                    TextField("Value", text: $textValue)
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled()

                default:
                    Text("This value type is not editable yet.")
                        .foregroundStyle(.secondary)
                }
            }

            if let errorMessage {
                Section("Error") {
                    Text(errorMessage)
                        .foregroundStyle(.red)
                        .textSelection(.enabled)
                }
            }

            Section {
                Button("Save Changes") {
                    saveValue()
                }
                .disabled(!isEditable)
            }
        }
        .navigationTitle("Edit Value")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            loadValue()
        }
    }

    private var isEditable: Bool {

        switch valueKind {
        case .string, .integer, .real, .boolean, .date, .data:
            return true

        case .array, .dictionary:
            return false
        }
    }

    private func loadValue() {

        do {
            switch valueKind {

            case .boolean:
                booleanValue = try PlistValueParser.text(
                    from: originalValue,
                    as: .boolean
                ) == "true"

            case .string, .integer, .real, .date, .data:
                textValue = try PlistValueParser.text(
                    from: originalValue,
                    as: valueKind
                )

            case .array, .dictionary:
                break
            }

            errorMessage = nil

        } catch {
            errorMessage = error.localizedDescription
        }
    }

    private func saveValue() {

        do {
            let newValue: Any

            switch valueKind {

            case .boolean:
                newValue = booleanValue

            case .string, .integer, .real, .date, .data:
                newValue = try PlistValueParser.parse(
                    textValue,
                    as: valueKind
                )

            case .array, .dictionary:
                return
            }

            try engine.set(
                newValue,
                at: path
            )

            dismiss()

        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
