import Foundation

protocol TermModelView: class {
    var statusUpdated: (() -> Void)? { get set }
    var numLinesUpdated: ((TermModelView, IndexPath) -> ())? { get set }
    var term: String { get }
    var definition: String { get }
    var numLines: Int { get }
    
    init(term: Term)
    
    func selectedNewStatus(_ status: Term.Status)
    func selectedTerm(at indexPath: IndexPath)
    func deselectedTerm(at indexPath: IndexPath)
}
