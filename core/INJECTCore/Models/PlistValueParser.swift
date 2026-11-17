
import Foundation
import CoreFoundation

enum PlistValueParser {

    static func parse(
        _ text: String,
        as kind: PlistValueKind
    ) throws -> Any {

        let trimmed = text.trimmingCharacters(
            in: .whitespacesAndNewlines
        )

        switch kind {

        case .string:
            return text

        case .integer:
            guard let value = Int64(trimmed) else {
                throw PlistValueError.invalidInteger
            }

            return NSNumber(value: value)

        case .real:
            guard let value = Double(trimmed),
                  value.isFinite else {
                throw PlistValueError.invalidReal
            }

            return NSNumber(value: value)

        case .boolean:
            switch trimmed.lowercased() {
            case "true", "1":
                return NSNumber(value: true)

            case "false", "0":
                return NSNumber(value: false)

            default:
                throw PlistValueError.invalidBoolean
            }

        case .date:
            let formatter = ISO8601DateFormatter()

            guard let date = formatter.date(from: trimmed) else {
                throw PlistValueError.invalidDate
            }

            return date

        case .data:
            guard let data = Data(base64Encoded: trimmed),
                  data.base64EncodedString() == trimmed else {
                throw PlistValueError.invalidData
            }

            return data

        case .array, .dictionary:
            guard let data = text.data(using: .utf8),
                  let value = try? PropertyListSerialization.propertyList(
                    from: data,
                    options: [],
                    format: nil
                  ),
                  PropertyListSerialization.propertyList(
                    value,
                    isValidFor: .binary
                  ) else {
                throw PlistValueError.invalidPropertyList
            }

            switch kind {
            case .array:
                guard let array = value as? [Any] else {
                    throw PlistValueError.invalidPropertyList
                }

                return array

            case .dictionary:
                guard let dictionary = value as? [String: Any] else {
                    throw PlistValueError.invalidPropertyList
                }

                return dictionary

            default:
                throw PlistValueError.invalidPropertyList
            }
        }
    }

    static func text(
        from value: Any,
        as kind: PlistValueKind
    ) throws -> String {

        switch kind {

        case .string:
            guard let string = value as? String else {
                throw PlistValueError.unsupportedType
            }

            return string

        case .integer, .real:
            guard let number = value as? NSNumber,
                  CFGetTypeID(number) != CFBooleanGetTypeID() else {
                throw PlistValueError.unsupportedType
            }

            return number.stringValue

        case .boolean:
            guard let number = value as? NSNumber,
                  CFGetTypeID(number) == CFBooleanGetTypeID() else {
                throw PlistValueError.unsupportedType
            }

            return number.boolValue ? "true" : "false"

        case .date:
            guard let date = value as? Date else {
                throw PlistValueError.unsupportedType
            }

            return ISO8601DateFormatter().string(from: date)

        case .data:
            guard let data = value as? Data else {
                throw PlistValueError.unsupportedType
            }

            return data.base64EncodedString()

        case .array, .dictionary:
            guard PropertyListSerialization.propertyList(
                value,
                isValidFor: .xml
            ) else {
                throw PlistValueError.invalidPropertyList
            }

            let data = try PropertyListSerialization.data(
                fromPropertyList: value,
                format: .xml,
                options: 0
            )

            return String(decoding: data, as: UTF8.self)
        }
    }
}
