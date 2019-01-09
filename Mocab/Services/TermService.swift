import Foundation

protocol TermService {
    static var inProgressTerm: Term? { get }
    
    static func getAll(_ status: Term.Status) -> [Term]
    static func save(_ newTerm: Term)
}
