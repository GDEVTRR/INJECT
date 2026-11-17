
import Foundation

enum PlistBackupService {

    static func createBackup(
        of document: PlistDocument,
        at destination: URL
    ) throws {

        let hasAccess = destination.startAccessingSecurityScopedResource()

        defer {
            if hasAccess {
                destination.stopAccessingSecurityScopedResource()
            }
        }

        let backupData = try document.encoded(format: .binary)

        var coordinationError: NSError?
        var writeError: Error?

        let coordinator = NSFileCoordinator()

        coordinator.coordinate(
            writingItemAt: destination,
            options: .forReplacing,
            error: &coordinationError
        ) { coordinatedURL in
            do {
                try backupData.write(
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

    static func restore(
        from backupURL: URL
    ) throws -> PlistDocument {

        let hasAccess = backupURL.startAccessingSecurityScopedResource()

        defer {
            if hasAccess {
                backupURL.stopAccessingSecurityScopedResource()
            }
        }

        var coordinatedData: Data?
        var coordinationError: NSError?
        var readError: Error?

        let coordinator = NSFileCoordinator()

        coordinator.coordinate(
            readingItemAt: backupURL,
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
            sourceURL: backupURL
        )
    }
}
