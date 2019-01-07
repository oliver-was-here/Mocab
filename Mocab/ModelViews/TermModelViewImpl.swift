import Foundation

class TermModelViewImpl: TermModelView {
    static let COLLAPSED_LINE_LIMIT = 1
    static let EXPANDED_LINE_LIMIT = 0
    private let termsService = ServiceInjector.termsService
    private var termEntity: Term
    
    var numLines = COLLAPSED_LINE_LIMIT
    
    private let statusUpdated: ((TermModelView) -> Void)
    private let numLinesUpdated: ((TermModelView, IndexPath) -> ())
    
    required init(
        term: Term,
        statusUpdated: @escaping (TermModelView) -> (),
        numLinesUpdated: @escaping (TermModelView, IndexPath) -> ()
    ) {
        self.termEntity = term
        self.statusUpdated = statusUpdated
        self.numLinesUpdated = numLinesUpdated
    }
    
    var definition: String { return termEntity.definition }
    
    var term: String { return termEntity.asEntered }
    
    func selectedNewStatus(_ status: Term.Status) {
        termEntity.status = status
        termsService.save(termEntity)
        
        statusUpdated(self)
    }
    
    func updateDefinition(newDefinition: String) {
        if newDefinition != termEntity.definition {
            termEntity.definition = newDefinition
            termsService.save(termEntity)
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
        self.numLinesUpdated(self, indexPath)
    }
}
