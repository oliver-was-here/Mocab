import Foundation
import PromiseKit

protocol NewTermModelView {
    init(definitionsAdded: @escaping (inout [DefinitionModelView]) -> ())
    
    func newTermReceived(_ term: String) -> Promise<Void>
    func saveEntry(term: String, chosenDefinition: String)
    func selectedDefinitions() -> [String]
    func definitionsReceived(definitions: [String], areSelected: Bool)
}
