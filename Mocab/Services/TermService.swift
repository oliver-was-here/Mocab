import Foundation

protocol TermService {
    static func getAll() -> [Term]
    static func getInProgressTerm() -> Term?
    static func create(_ newTerm: Term)
}
