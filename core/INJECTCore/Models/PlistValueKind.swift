
import Foundation
import CoreFoundation

enum PlistValueKind: String, CaseIterable, Identifiable, Equatable {

    case string
    case integer
    case real
    case boolean
    case data
    case array
    case dictionary
    case date

    var id: String {
        rawValue
    }

    var displayName: String {
        switch self {
        case .string: return "String"
        case .integer: return "Integer"
        case .real: return "Real"
        case .boolean: return "Boolean"
        case .data: return "Data"
        case .array: return "Array"
        case .dictionary: return "Dictionary"
        case .date: return "Date"
        }
    }

    static func detect(_ value: Any) -> PlistValueKind {

        if let number = value as? NSNumber {

            if CFGetTypeID(number) == CFBooleanGetTypeID() {
                return .boolean
            }

            let type = String(cString: number.objCType)

            switch type {
            case "f", "d":
                return .real

            default:
                return .integer
            }
        }

        if value is String {
            return .string
        }

        if value is Date {
            return .date
        }

        if value is Data {
            return .data
        }

        if value is [Any] {
            return .array
        }

        if value is [String: Any] {
            return .dictionary
        }

        return .string
    }
}
