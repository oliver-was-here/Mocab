import Foundation

class DefinitionModelView {
    // no protocol used due to issue with prtotocols passed as inout mutable parameters passed to closures
    var definition: String
    var isSelected: Bool {
        didSet {
            guard let didUpdateSelectState = didUpdateSelectState else { return }
            didUpdateSelectState(isSelected)
        }
    }

    init(definition: String, isSelected: Bool = false) {
        self.definition = definition
        self.isSelected = isSelected
    }

    var didUpdateSelectState: ((Bool) -> ())?
    
    func toggleSelectState() {
        isSelected = !isSelected
    }
}
