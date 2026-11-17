
import Foundation

enum PlistValueError: LocalizedError {
    case invalidInteger
    case invalidReal
    case invalidBoolean
    case invalidDate
    case invalidData
    case invalidPropertyList
    case unsupportedType

    var errorDescription: String? {
        switch self {
        case .invalidInteger:
            return "Geçersiz tam sayı."
        case .invalidReal:
            return "Geçersiz ondalık sayı."
        case .invalidBoolean:
            return "Boolean değeri true veya false olmalıdır."
        case .invalidDate:
            return "Geçersiz ISO 8601 tarih formatı."
        case .invalidData:
            return "Geçersiz Base64 verisi."
        case .invalidPropertyList:
            return "Geçersiz Property List içeriği."
        case .unsupportedType:
            return "Desteklenmeyen veri türü."
        }
    }
}
