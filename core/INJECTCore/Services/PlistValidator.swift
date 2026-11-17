
import Foundation

enum PlistValidator {

    static func validate(_ document: PlistDocument) -> Bool {
        PropertyListSerialization.propertyList(
            document.root,
            isValidFor: .binary
        )
    }

    static func validate(data: Data) -> Bool {

        guard let value = try? PropertyListSerialization.propertyList(
            from: data,
            options: [],
            format: nil
        ) else {
            return false
        }

        return PropertyListSerialization.propertyList(
            value,
            isValidFor: .binary
        )
    }

    static func validateFile(at url: URL) -> Bool {

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

        guard coordinationError == nil,
              readError == nil,
              let data = coordinatedData else {
            return false
        }

        return validate(data: data)
    }
}
