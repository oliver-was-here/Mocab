import Foundation

class TermModelViewImpl: TermModelView {
    static let COLLAPSED_LINE_LIMIT = 3
    static let EXPANDED_LINE_LIMIT = Int.max
    
    private var termEntity: Term
    
    var numLines = COLLAPSED_LINE_LIMIT {
        didSet {
            self.numLinesUpdated?(self)
        }
    }
    
    var statusUpdated: (() -> Void)?
    var numLinesUpdated: ((TermModelView) -> ())?
    
    required init(term: Term) {
        self.termEntity = term
    }
    
    var definition: String { return termEntity.definition }
    
    var term: String { return termEntity.asEntered }
    
    func selectedNewStatus(_ status: Term.Status) {
        termEntity.status = status
        ServiceInjector.termsService.save(termEntity)
        
        statusUpdated?()
    }
    
    func selectedTerm() {
        self.numLines = TermModelViewImpl.COLLAPSED_LINE_LIMIT
    }
    
    func deselectedTerm() {
        self.numLines = TermModelViewImpl.EXPANDED_LINE_LIMIT
    }
}
