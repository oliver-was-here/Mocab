import Foundation
import PromiseKit

class NewTermModelViewImpl: NewTermModelView {
    private let definitionsAdded: (inout [DefinitionModelView]) -> ()
    private var definitions: [DefinitionModelView] = []
    private var definitionViewModels: [DefinitionModelView] = []
    
    required init(definitionsAdded: @escaping (inout [DefinitionModelView]) -> ()) {
        self.definitionsAdded = definitionsAdded
    }
    
    func newTermReceived(_ term: String) -> Promise<Void> {
        return ServiceInjector.definer
            .getDefinitions(forTerm: term)
            .done { definitions in
                if definitions.isEmpty {
                    throw UnexpectedPayloadError(message: "empty definition list")
                }
                
                self.definitionsReceived(definitions: definitions)
        }
    }
    
    func definitionsReceived(definitions: [String], areSelected: Bool = false) {
        var viewModels = definitions.map {
            DefinitionModelView(definition: $0, isSelected: areSelected)
        }
        self.definitionsAdded(&viewModels)
        self.definitionViewModels.append(contentsOf: viewModels)
    }
    
    func saveEntry(term: String, chosenDefinition: String) {
        let term = Term(
            asEntered: term,
            definition: chosenDefinition,
            status: Term.Status.inProgress
        )
        
        ServiceInjector.termsService.save(term, retainOrder: false)
    }
    
    func selectedDefinitions() -> [String] {
        return definitionViewModels.filter { $0.isSelected }.map { $0.definition }
    }
}
