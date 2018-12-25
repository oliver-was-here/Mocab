import Foundation

protocol TermService {
    static func getAll() -> [Term]
    static func save(_ newTerm: Term, retainOrder: Bool)
    
    static func getInProgressTerm() -> Term?
}
