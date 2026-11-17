
import SwiftUI
import UniformTypeIdentifiers

struct FileManagerView: View {

    @ObservedObject var engine: INJECTEngine

    @State private var showImporter = false
    @State private var showExporter = false
    @State private var errorMessage: String?

    @State private var exportDocument = ExportedPlistDocument(data: Data())

    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {

                Image(systemName: "doc.text.magnifyingglass")
                    .font(.system(size: 54))
                    .foregroundStyle(INJECTTheme.accent)

                Text("Plist File Manager")
                    .font(.title2.bold())

                Text("Open and inspect property list files.")
                    .multilineTextAlignment(.center)
                    .foregroundStyle(.secondary)

                Button {
                    showImporter = true
                } label: {
                    Label("Open PLIST File", systemImage: "doc.badge.plus")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)

                if let document = engine.document {

                    GlassCard {
                        VStack(alignment: .leading, spacing: 10) {

                            Label("Loaded File", systemImage: "doc.text")

                            Text(
                                document.sourceURL?.lastPathComponent
                                ?? "Imported PLIST"
                            )
                            .font(.headline)

                            Text(
                                engine.hasChanges
                                ? "Unsaved changes"
                                : "No pending changes"
                            )
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        }
                    }

                    Button {
                        prepareExport()
                    } label: {
                        Label(
                            "Export PLIST",
                            systemImage: "square.and.arrow.up"
                        )
                        .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.bordered)
                }

                if let errorMessage {
                    Text(errorMessage)
                        .font(.caption)
                        .foregroundStyle(.red)
                        .textSelection(.enabled)
                }

                Spacer()
            }
            .padding()
            .navigationTitle("File Manager")
            .fileImporter(
                isPresented: $showImporter,
                allowedContentTypes: [.propertyList],
                allowsMultipleSelection: false
            ) { result in

                switch result {

                case .success(let urls):
                    guard let url = urls.first else {
                        return
                    }

                    do {
                        try engine.open(url)
                        errorMessage = nil
                    } catch {
                        errorMessage = error.localizedDescription
                    }

                case .failure(let error):
                    errorMessage = error.localizedDescription
                }
            }
            .fileExporter(
                isPresented: $showExporter,
                document: exportDocument,
                contentType: .propertyList,
                defaultFilename: "INJECT-Export"
            ) { result in

                switch result {

                case .success:
                    errorMessage = nil

                case .failure(let error):
                    errorMessage = error.localizedDescription
                }
            }
        }
    }

    private func prepareExport() {

        guard let document = engine.document else {
            errorMessage = "No PLIST document is loaded."
            return
        }

        do {
            let data = try document.encoded(format: .xml)

            exportDocument = ExportedPlistDocument(data: data)
            errorMessage = nil
            showExporter = true

        } catch {
            errorMessage = error.localizedDescription
        }
    }
}

struct ExportedPlistDocument: FileDocument {

    static var readableContentTypes: [UTType] {
        [.propertyList]
    }

    let data: Data

    init(data: Data) {
        self.data = data
    }

    init(configuration: ReadConfiguration) throws {

        guard let contents = configuration.file.regularFileContents else {
            throw PlistValueError.invalidPropertyList
        }

        data = contents
    }

    func fileWrapper(
        configuration: WriteConfiguration
    ) throws -> FileWrapper {

        FileWrapper(
            regularFileWithContents: data
        )
    }
}
