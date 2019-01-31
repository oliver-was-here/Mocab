import Foundation
import RealmSwift

class RealmListService: ListService {
    private static let realm = try? Realm()
    
    static func getAll() -> [(id: String, name: String)] {
        guard let lists = realm?.objects(RealmTermListFoo.self)
            else { return [(id: String, name: String)]() }
        
        return Array(lists.map { (id: $0.id, name: $0.name) } )
    }
    
    static func create(name: String) {
        let list = RealmTermListFoo()
        list.name = name
        do {
            try realm!.write {
                realm?.add(list)
            }
        } catch {
            log(.error, "failed to save list: \(name). \(error)")
        } 
    }
}
