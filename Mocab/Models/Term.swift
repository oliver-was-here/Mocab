import Foundation

struct Term: Codable {
    let asEntered: String
    let definition: String // todo list of definitions
}

extension Term {
    var id: String { return asEntered.lowercased() }
}
