import Foundation
import RealmSwift

class RealmTermService: TermService {
    private static let realm = try? Realm()
    private static let termsQuery = realm?.objects(RealmTerm.self)
        .sorted(byKeyPath: "lastStatusUpdate")
    
    // MARK: TermService
    static func getAll(_ status: Term.Status) -> [Term] {
        return termsQuery?
            .filter("status = \(status.rawValue)")
            .map { realmTermToDTO($0) } ?? []
    }
    
    static func save(_ newTerm: Term) {
        do {
            try realm?.write {
                realm?.add(dtoToRealmTerm(newTerm), update: true)
            }
        } catch {
            log(.error, "failed to add term \(newTerm)")
        }
    }
    
    static func getInProgressTerm() -> Term? {
        guard let realmTerm = termsQuery?
            .filter("status = \(Term.Status.inProgress.rawValue)")
            .first
            else { return nil }
        
        return realmTermToDTO(realmTerm)
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
