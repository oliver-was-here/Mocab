import RealmSwift
import Foundation

class RealmTermList: Object {
    @objc dynamic var id = NSUUID().uuidString
    @objc dynamic var name = ""
    @objc dynamic var createdAt = Date()
    let terms = List<RealmTerm>()
    var isDefinitionList: Bool = false
    
    override static func primaryKey() -> String? {
        return "id"
    }
}
