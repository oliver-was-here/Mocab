import Foundation

struct Term: Codable {
    let asEntered: String
    let definition: String
}

extension Term {
    var id: String { return asEntered.lowercased() }
}
