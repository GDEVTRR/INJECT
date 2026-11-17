
import Foundation

enum PlistChangeType: String, CaseIterable, Identifiable {

    case added
    case modified
    case removed

    var id: String {
        rawValue
    }

    var displayName: String {
        switch self {
        case .added:
            return "Added"
        case .modified:
            return "Modified"
        case .removed:
            return "Removed"
        }
    }
}

struct PlistChange: Identifiable {

    let id = UUID()
    let path: PlistPath
    let type: PlistChangeType
    let oldValue: String?
    let newValue: String?
}
