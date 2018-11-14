import Foundation

class TermModelViewImpl: TermModelView {
    static let COLLAPSED_LINE_LIMIT = 1
    static let EXPANDED_LINE_LIMIT = 0
    private let termsService = ServiceInjector.termsService
    private var termEntity: Term
    
    var numLines = COLLAPSED_LINE_LIMIT
    
    var statusUpdated: (() -> Void)?
    var numLinesUpdated: ((TermModelView, IndexPath) -> ())?
    
    required init(term: Term) {
        self.termEntity = term
    }
    
    var definition: String { return termEntity.definition }
    
    var term: String { return termEntity.asEntered }
    
    func selectedNewStatus(_ status: Term.Status) {
        termEntity.status = status
        termsService.save(termEntity, retainOrder: false)
        
        statusUpdated?()
    }
    
    func updateDefinition(newDefinition: String) {
        if newDefinition != termEntity.definition {
            termEntity.definition = newDefinition
            termsService.save(termEntity, retainOrder: true)
        }
    }
    
    func selectedTerm(at indexPath: IndexPath) {
        updateNumLines(newVal: TermModelViewImpl.EXPANDED_LINE_LIMIT, at: indexPath)
    }
    
    func deselectedTerm(at indexPath: IndexPath) {
        updateNumLines(newVal: TermModelViewImpl.COLLAPSED_LINE_LIMIT, at: indexPath)
    }
    
    private func updateNumLines(newVal: Int, at indexPath: IndexPath) {
        if self.numLines == newVal { return }
        
        self.numLines = newVal
        self.numLinesUpdated?(self, indexPath)
    }
}
