import Foundation

protocol TermService {
    static var inProgressTerm: Term? { get }
    
    static func getDefaultListID() -> String?
    static func getAll(_ status: Term.Status, for listId: String?) -> [Term]
    static func save(_ newTerm: Term, for listId: String?)
}
