import Foundation
import RealmSwift

class RealmTermService: TermService {
    private static let realm = try? Realm()
    private static let termsQuery = realm?.objects(RealmTerm.self)
        .sorted(byKeyPath: "lastStatusUpdate")
    
    // MARK: TermService
    static func getDefaultListID() -> String? {
        return realm?.objects(RealmTermListFoo.self).first?.id
    }
    
    static var inProgressTerm: Term? {
        guard let realmTerm = termsQuery?
            .filter("status = \(Term.Status.inProgress.rawValue)")
            .first
            else { return nil }
        
        return realmTermToDTO(realmTerm)
    }
    
    static func getAll(_ status: Term.Status, for listId: String?) -> [Term] {
        return realm?.object(ofType: RealmTermListFoo.self, forPrimaryKey: listId ?? "")?
            .terms
            .filter("status = \(status.rawValue)")
            .map { realmTermToDTO($0) } ?? []
    }
    
    static func save(_ newTerm: Term, for listId: String?) {
        let list = realm?.object(ofType: RealmTermListFoo.self, forPrimaryKey: listId ?? "")
        let newRealmTerm: RealmTerm = dtoToRealmTerm(newTerm)
        let existingTerm = realm?.object(ofType: RealmTerm.self, forPrimaryKey: newRealmTerm.term)
        
        do {
            try realm?.write {
                if existingTerm == nil {
                    list!.terms.append(newRealmTerm)
                } else {
                    realm?.add(newRealmTerm, update: true)
                }
            }
        } catch {
            log(.error, "failed to add term \(newTerm) -- \(error)")
        }
    }
    
    private static func realmTermToDTO(_ realmTerm: RealmTerm) -> Term {
        return Term(
            asEntered: realmTerm.asEntered,
            definition: realmTerm.definition,
            status: realmTerm.status,
            lastStatusUpdate: realmTerm.lastStatusUpdate
        )
    }
    
    private static func dtoToRealmTerm(_ term: Term) -> RealmTerm {
        let realmTerm = RealmTerm()
        realmTerm.term = term.id
        realmTerm.asEntered = term.asEntered
        realmTerm.definition = term.definition
        realmTerm.status = term.status
        realmTerm.lastStatusUpdate = term.lastStatusUpdate
        return realmTerm
    }
}
