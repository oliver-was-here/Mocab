import Foundation

protocol TermService {
    static func getAll(_ status: Term.Status) -> [Term]
    static func save(_ newTerm: Term)
    
    static func getInProgressTerm() -> Term?
}
