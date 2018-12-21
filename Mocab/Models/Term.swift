import Foundation

struct Term: Codable {
    let asEntered: String
    var definition: String
    var status: Status
    
    enum Status: String, Codable {
        case inProgress
        case snoozed
        case mastered
    }
}

extension Term {
    var id: String { return asEntered.lowercased() }
}
