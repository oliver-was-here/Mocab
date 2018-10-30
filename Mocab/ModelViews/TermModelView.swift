import Foundation

protocol TermModelView: class {
    var statusUpdated: (() -> Void)? { get set }
    var numLinesUpdated: ((TermModelView) -> ())? { get set }
    var term: String { get }
    var definition: String { get }
    
    init(term: Term)
    
    func selectedNewStatus(_ status: Term.Status)
    func selectedTerm()
    func deselectedTerm()
}
