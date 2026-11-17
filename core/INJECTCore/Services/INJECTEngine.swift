
import Foundation
import Combine

final class INJECTEngine: ObservableObject {

    @Published private(set) var document: PlistDocument?
    @Published private(set) var originalDocument: PlistDocument?

    var hasDocument: Bool {
        document != nil
    }

    var hasChanges: Bool {
        guard let originalDocument,
              let document,
              let changes = try? PlistDiffEngine.compare(
                original: originalDocument,
                updated: document
              ) else {
            return false
        }

        return !changes.isEmpty
    }

    func open(_ url: URL) throws {
        let opened = try PlistFileService.open(from: url)

        originalDocument = opened
        document = opened
    }

    func value(at path: PlistPath) throws -> Any {
        guard let document else {
            throw PlistValueError.invalidPropertyList
        }

        return try PlistNavigator.value(
            at: path,
            in: document
        )
    }

    func set(_ value: Any, at path: PlistPath) throws {
        guard let document else {
            throw PlistValueError.invalidPropertyList
        }

        let updated = try PlistNavigator.setting(
            value,
            at: path,
            in: document
        )

        self.document = updated
    }

    func remove(at path: PlistPath) throws {
        guard let document else {
            throw PlistValueError.invalidPropertyList
        }

        let updated = try PlistNavigator.removing(
            at: path,
            in: document
        )

        self.document = updated
    }

    func changes() throws -> [PlistChange] {
        guard let originalDocument,
              let document else {
            throw PlistValueError.invalidPropertyList
        }

        return try PlistDiffEngine.compare(
            original: originalDocument,
            updated: document
        )
    }

    func save(to url: URL) throws {
        guard let document else {
            throw PlistValueError.invalidPropertyList
        }

        try PlistFileService.save(
            document,
            to: url
        )

        let savedDocument = try PlistDocument(
            root: document.root,
            sourceURL: url
        )

        self.document = savedDocument
        self.originalDocument = savedDocument
    }

    func createBackup(
        ofCurrentChangesAt url: URL
    ) throws {
        guard let document else {
            throw PlistValueError.invalidPropertyList
        }

        try PlistBackupService.createBackup(
            of: document,
            at: url
        )
    }

    func createOriginalBackup(at url: URL) throws {
        guard let originalDocument else {
            throw PlistValueError.invalidPropertyList
        }

        try PlistBackupService.createBackup(
            of: originalDocument,
            at: url
        )
    }

    func rollback() {
        document = originalDocument
    }

    func close() {
        document = nil
        originalDocument = nil
    }
}
