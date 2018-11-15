import Foundation
import PromiseKit

class ReviewTermsViewModelImpl: ReviewTermsViewModel {
    // cell callbacks piped to child MVs on creation
    private let statusUpdated: () -> () // single term
    private let numLinesUpdated: (TermModelView, IndexPath) -> ()
    
    // table callbacks
    private let updatedDisplayedTerms: ([TermModelView]) -> ()
    var displayedTerms: [TermModelView] {
        didSet {
            updatedDisplayedTerms(displayedTerms)
        }
    }
    private let updatedStatusDisplayed: (Term.Status) -> ()
    private var termsStatus: Term.Status {
        didSet {
            updatedStatusDisplayed(termsStatus)
        }
    }
    private let didUpdateScreenTitle: (String) -> ()
    private var screenTitle: String {
        didSet {
            didUpdateScreenTitle(screenTitle)
        }
    }
    
    // ReviewTermsViewModel
    func updateDisplayedTerms(to status: Term.Status) {
        termsStatus = status
        displayedTerms = initModelViews(for: status)
        
        screenTitle = ReviewTermsViewModelImpl.getTitle(forStatus: status)
    }
    
    required init(
        updatedStatusDisplayed: @escaping (Term.Status) -> (),
        updatedDisplayedTerms: @escaping ([TermModelView]) -> (),
        didUpdateScreenTitle: @escaping (String) -> (),
        statusUpdated: @escaping () -> (),
        numLinesUpdated: @escaping (TermModelView, IndexPath) -> (),
        forStatus status: Term.Status = .inProgress
        ) {
        self.updatedDisplayedTerms = updatedDisplayedTerms
        self.didUpdateScreenTitle = didUpdateScreenTitle
        self.statusUpdated = statusUpdated
        self.numLinesUpdated = numLinesUpdated
        self.updatedStatusDisplayed = updatedStatusDisplayed
        
        termsStatus = status
        updatedStatusDisplayed(termsStatus)
        
        screenTitle = ReviewTermsViewModelImpl.getTitle(forStatus: status)
        didUpdateScreenTitle(screenTitle)
        
        displayedTerms = ReviewTermsViewModelImpl.initModelViews(
            forStatus: status,
            statusUpdated: statusUpdated,
            numLinesUpdated: numLinesUpdated
        )
        updatedDisplayedTerms(displayedTerms)
    }
    
    func addTerm(_ receivedTerm: String) -> Promise<Void> {
        return ServiceInjector.definer
            .getDefinitions(forTerm: receivedTerm)
            .done { definitions in
                if definitions.isEmpty {
                    throw UnexpectedPayloadError(message: "empty definition list")
                }
                
                self.saveTerm(forTerm: receivedTerm, andDefinitions: definitions)
        }
    }
    
    func addTerm(_ receivedTerm: String, _ receivedDefinition: String) {
        saveTerm(forTerm: receivedTerm, andDefinitions: [receivedDefinition])
    }
    
    // MARK: private
    static private func getTitle(forStatus status: Term.Status) -> String {
        switch(status) {
        case .inProgress:
            return "in progress"
        case .snoozed:
            return "snoozed"
        case .mastered:
            return "mastered"
        }
    }
    
    private func saveTerm(
        forTerm receivedTerm: String,
        andDefinitions definitions: [String]
        ) {
        let term = Term(
            asEntered: receivedTerm,
            definition: definitions.first ?? "",
            status: Term.Status.inProgress
        )
        
        if termsStatus == .inProgress {
            displayedTerms.append(createModelView(forTerm: term))
        }
        
        ServiceInjector.termsService.save(term, retainOrder: false)
    }
    
    static private func initModelViews(
        forStatus statusType: Term.Status,
        statusUpdated: @escaping () -> (),
        numLinesUpdated: @escaping (TermModelView, IndexPath) -> ()
        ) -> [TermModelView] {
        let terms = TermModelViewImplFactory.getViewModels(
            for: statusType,
            statusUpdated: statusUpdated,
            numLinesUpdated: numLinesUpdated
        )
        
        return terms
    }
    
    private func createModelView(forTerm term: Term) -> TermModelView {
        return TermModelViewImpl(
            term: term,
            statusUpdated: statusUpdated,
            numLinesUpdated: numLinesUpdated
        )
    }
    
    private func initModelViews(for statusType: Term.Status) -> [TermModelView] {
        return ReviewTermsViewModelImpl.initModelViews(
            forStatus: statusType,
            statusUpdated: statusUpdated,
            numLinesUpdated: numLinesUpdated
        )
    }
}
