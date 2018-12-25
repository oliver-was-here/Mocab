import Foundation

struct Term: Codable {
    let asEntered: String
    var definition: String
    var status: Status {
        didSet {
            lastStatusUpdate = Date()
        }
    }
    var lastStatusUpdate: Date = Date()
    
    func changeValues(asEntered: String? = nil, definition: String? = nil, status: Status? = nil) -> Term {
        return Term(
            asEntered: asEntered ?? self.asEntered,
            definition: definition ?? self.definition,
            status: status ?? self.status,
            lastStatusUpdate: status != self.status ? Date() : self.lastStatusUpdate
        )
    }
    
    enum Status: String, Codable {
        case inProgress
        case snoozed
        case mastered
    }
}

extension Term {
    var id: String { return asEntered.lowercased() }
}
