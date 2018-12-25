import Foundation
import PromiseKit

protocol ReviewTermsViewModel {
    var displayedTerms: [TermModelView] { get }
    
    init(
        updatedStatusDisplayed: @escaping (Term.Status) -> (),
        updatedDisplayedTerms: @escaping ([TermModelView]) -> (),
        didUpdateScreenTitle: @escaping (String) -> (),
        statusUpdated: @escaping (TermModelView) -> (),
        numLinesUpdated: @escaping (TermModelView, IndexPath) -> (),
        forStatus status: Term.Status
    )
    
    func updateDisplayedTerms(to status: Term.Status)
    
    func removeTerm(term: TermModelView)
}
