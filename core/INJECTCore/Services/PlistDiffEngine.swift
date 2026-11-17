
import Foundation
import CoreFoundation

enum PlistDiffEngine {

    static func compare(
        original: PlistDocument,
        updated: PlistDocument
    ) throws -> [PlistChange] {

        var changes: [PlistChange] = []

        compareValues(
            original.root,
            updated.root,
            path: PlistPath(),
            changes: &changes
        )

        return changes
    }

    private static func compareValues(
        _ old: Any,
        _ new: Any,
        path: PlistPath,
        changes: inout [PlistChange]
    ) {

        if let oldDict = old as? [String: Any],
           let newDict = new as? [String: Any] {

            let keys = Set(oldDict.keys).union(newDict.keys)

            for key in keys.sorted() {

                let childPath = path.appending(key: key)

                switch (oldDict[key], newDict[key]) {

                case (nil, let newValue?):
                    changes.append(
                        PlistChange(
                            path: childPath,
                            type: .added,
                            oldValue: nil,
                            newValue: describe(newValue)
                        )
                    )

                case (let oldValue?, nil):
                    changes.append(
                        PlistChange(
                            path: childPath,
                            type: .removed,
                            oldValue: describe(oldValue),
                            newValue: nil
                        )
                    )

                case (let oldValue?, let newValue?):
                    compareValues(
                        oldValue,
                        newValue,
                        path: childPath,
                        changes: &changes
                    )

                default:
                    break
                }
            }

            return
        }

        if let oldArray = old as? [Any],
           let newArray = new as? [Any] {

            let count = max(oldArray.count, newArray.count)

            for index in 0..<count {

                let childPath = path.appending(index: index)

                if index >= oldArray.count {

                    changes.append(
                        PlistChange(
                            path: childPath,
                            type: .added,
                            oldValue: nil,
                            newValue: describe(newArray[index])
                        )
                    )

                } else if index >= newArray.count {

                    changes.append(
                        PlistChange(
                            path: childPath,
                            type: .removed,
                            oldValue: describe(oldArray[index]),
                            newValue: nil
                        )
                    )

                } else {

                    compareValues(
                        oldArray[index],
                        newArray[index],
                        path: childPath,
                        changes: &changes
                    )
                }
            }

            return
        }

        if !equal(old, new) {

            changes.append(
                PlistChange(
                    path: path,
                    type: .modified,
                    oldValue: describe(old),
                    newValue: describe(new)
                )
            )
        }
    }

    private static func equal(
        _ lhs: Any,
        _ rhs: Any
    ) -> Bool {

        if let left = lhs as? NSNumber,
           let right = rhs as? NSNumber {

            let leftIsBoolean =
                CFGetTypeID(left) == CFBooleanGetTypeID()

            let rightIsBoolean =
                CFGetTypeID(right) == CFBooleanGetTypeID()

            guard leftIsBoolean == rightIsBoolean else {
                return false
            }

            return left == right
        }

        if let left = lhs as? String,
           let right = rhs as? String {
            return left == right
        }

        if let left = lhs as? Data,
           let right = rhs as? Data {
            return left == right
        }

        if let left = lhs as? Date,
           let right = rhs as? Date {
            return left == right
        }

        return false
    }

    private static func describe(_ value: Any) -> String {

        if let text = try? PlistValueParser.text(
            from: value,
            as: PlistValueKind.detect(value)
        ) {
            return text
        }

        return String(describing: value)
    }
}
