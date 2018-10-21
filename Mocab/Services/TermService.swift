import Foundation

protocol TermService {
    static func getAll() -> [Term]
    static func save(_ newTerm: Term)
    static func delete(_ term: Term)
    
    static func getInProgressTerm() -> Term?
}
