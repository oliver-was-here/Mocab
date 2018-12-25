import Foundation

protocol TermModelView: class {
    var term: String { get }
    var definition: String { get }
    var numLines: Int { get }
    
    init(
        term: Term,
        statusUpdated: @escaping (TermModelView) -> (),
        numLinesUpdated: @escaping (TermModelView, IndexPath) -> ()
    )

    
    func updateDefinition(newDefinition: String)
    func selectedNewStatus(_ status: Term.Status)
    func selectedTerm(at indexPath: IndexPath)
    func deselectedTerm(at indexPath: IndexPath)
}
