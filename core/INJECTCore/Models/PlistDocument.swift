
import Foundation

struct PlistDocument {
    private(set) var root: Any
    let sourceURL: URL?

    init(root: Any, sourceURL: URL? = nil) throws {
        guard PropertyListSerialization.propertyList(
            root,
            isValidFor: .binary
        ) else {
            throw PlistValueError.invalidPropertyList
        }

        self.root = root
        self.sourceURL = sourceURL
    }

    init(data: Data, sourceURL: URL? = nil) throws {
        let value = try PropertyListSerialization.propertyList(
            from: data,
            options: [],
            format: nil
        )

        try self.init(
            root: value,
            sourceURL: sourceURL
        )
    }

    func encoded(
        format: PropertyListSerialization.PropertyListFormat = .binary
    ) throws -> Data {

        guard PropertyListSerialization.propertyList(
            root,
            isValidFor: format
        ) else {
            throw PlistValueError.invalidPropertyList
        }

        return try PropertyListSerialization.data(
            fromPropertyList: root,
            format: format,
            options: 0
        )
    }

    var isDictionary: Bool {
        root is [String: Any]
    }

    var isArray: Bool {
        root is [Any]
    }
}
