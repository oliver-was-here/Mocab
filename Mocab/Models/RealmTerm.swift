import Foundation
import RealmSwift

class RealmTerm: Object {
    @objc dynamic var term = ""
    @objc dynamic var asEntered = ""
    @objc dynamic var definition = ""
    @objc dynamic var status: Term.Status = .inProgress
    @objc dynamic var lastStatusUpdate: Date = Date()
    
    override static func primaryKey() -> String? {
        return "term"
    }
}
