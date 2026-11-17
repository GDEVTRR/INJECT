
import Foundation

enum PlistPathComponent: Hashable {
    case key(String)
    case index(Int)
}

struct PlistPath: Hashable {

    private(set) var components: [PlistPathComponent]

    init(_ components: [PlistPathComponent] = []) {
        self.components = components
    }

    func appending(key: String) -> PlistPath {
        PlistPath(components + [.key(key)])
    }

    func appending(index: Int) -> PlistPath {
        PlistPath(components + [.index(index)])
    }

    var isRoot: Bool {
        components.isEmpty
    }

    var description: String {
        components.reduce(into: "") { result, component in

            switch component {

            case .key(let key):
                if !result.isEmpty {
                    result += "."
                }

                result += key

            case .index(let index):
                result += "[\(index)]"
            }
        }
    }
}
