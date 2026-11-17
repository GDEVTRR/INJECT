
import Foundation

enum PlistFileService {

    static func open(from url: URL) throws -> PlistDocument {

        let hasAccess = url.startAccessingSecurityScopedResource()

        defer {
            if hasAccess {
                url.stopAccessingSecurityScopedResource()
            }
        }

        var coordinatedData: Data?
        var coordinationError: NSError?
        var readError: Error?

        let coordinator = NSFileCoordinator()

        coordinator.coordinate(
            readingItemAt: url,
            options: [],
            error: &coordinationError
        ) { coordinatedURL in
            do {
                coordinatedData = try Data(contentsOf: coordinatedURL)
            } catch {
                readError = error
            }
        }

        if let coordinationError {
            throw coordinationError
        }

        if let readError {
            throw readError
        }

        guard let data = coordinatedData else {
            throw PlistValueError.invalidPropertyList
        }

        return try PlistDocument(
            data: data,
            sourceURL: url
        )
    }

    static func save(
        _ document: PlistDocument,
        to url: URL,
        format: PropertyListSerialization.PropertyListFormat = .binary
    ) throws {

        let hasAccess = url.startAccessingSecurityScopedResource()

        defer {
            if hasAccess {
                url.stopAccessingSecurityScopedResource()
            }
        }

        let data = try document.encoded(format: format)

        var coordinationError: NSError?
        var writeError: Error?

        let coordinator = NSFileCoordinator()

        coordinator.coordinate(
            writingItemAt: url,
            options: .forReplacing,
            error: &coordinationError
        ) { coordinatedURL in
            do {
                try data.write(
                    to: coordinatedURL,
                    options: .atomic
                )
            } catch {
                writeError = error
            }
        }

        if let coordinationError {
            throw coordinationError
        }

        if let writeError {
            throw writeError
        }
    }
}
