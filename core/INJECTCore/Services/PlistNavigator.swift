
import Foundation

enum PlistNavigator {

    static func value(
        at path: PlistPath,
        in document: PlistDocument
    ) throws -> Any {

        var current: Any = document.root

        for component in path.components {
            switch component {
            case .key(let key):
                guard let dictionary = current as? [String: Any],
                      let next = dictionary[key] else {
                    throw PlistValueError.invalidPropertyList
                }

                current = next

            case .index(let index):
                guard let array = current as? [Any],
                      array.indices.contains(index) else {
                    throw PlistValueError.invalidPropertyList
                }

                current = array[index]
            }
        }

        return current
    }

    static func setting(
        _ value: Any,
        at path: PlistPath,
        in document: PlistDocument
    ) throws -> PlistDocument {

        guard PropertyListSerialization.propertyList(
            value,
            isValidFor: .binary
        ) else {
            throw PlistValueError.invalidPropertyList
        }

        let updated = try replace(
            document.root,
            components: path.components,
            offset: 0,
            with: value
        )

        return try PlistDocument(
            root: updated,
            sourceURL: document.sourceURL
        )
    }

    static func removing(
        at path: PlistPath,
        in document: PlistDocument
    ) throws -> PlistDocument {

        guard let last = path.components.last else {
            throw PlistValueError.invalidPropertyList
        }

        let parentPath = PlistPath(
            Array(path.components.dropLast())
        )

        let parent = try value(
            at: parentPath,
            in: document
        )

        let updatedParent: Any

        switch last {
        case .key(let key):
            guard var dictionary = parent as? [String: Any],
                  dictionary[key] != nil else {
                throw PlistValueError.invalidPropertyList
            }

            dictionary.removeValue(forKey: key)
            updatedParent = dictionary

        case .index(let index):
            guard var array = parent as? [Any],
                  array.indices.contains(index) else {
                throw PlistValueError.invalidPropertyList
            }

            array.remove(at: index)
            updatedParent = array
        }

        let updated = try replace(
            document.root,
            components: Array(path.components.dropLast()),
            offset: 0,
            with: updatedParent
        )

        return try PlistDocument(
            root: updated,
            sourceURL: document.sourceURL
        )
    }

    private static func replace(
        _ current: Any,
        components: [PlistPathComponent],
        offset: Int,
        with newValue: Any
    ) throws -> Any {

        if offset == components.count {
            return newValue
        }

        switch components[offset] {
        case .key(let key):
            guard var dictionary = current as? [String: Any] else {
                throw PlistValueError.invalidPropertyList
            }

            if offset == components.count - 1 {
                dictionary[key] = newValue
            } else {
                guard let child = dictionary[key] else {
                    throw PlistValueError.invalidPropertyList
                }

                dictionary[key] = try replace(
                    child,
                    components: components,
                    offset: offset + 1,
                    with: newValue
                )
            }

            return dictionary

        case .index(let index):
            guard var array = current as? [Any],
                  array.indices.contains(index) else {
                throw PlistValueError.invalidPropertyList
            }

            array[index] = try replace(
                array[index],
                components: components,
                offset: offset + 1,
                with: newValue
            )

            return array
        }
    }
}
