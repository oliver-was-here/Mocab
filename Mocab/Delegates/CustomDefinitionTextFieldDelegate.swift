import Foundation
import UIKit

class CustomDefinitionTextFieldDelegate: NSObject, UITextFieldDelegate {
    private let viewModel: NewTermModelView
    
    init(viewModel: NewTermModelView) {
        self.viewModel = viewModel
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        guard let receivedTerm = textField.text,
            !receivedTerm.isEmpty
            else { return }
        
        viewModel.definitionsReceived(definitions: [receivedTerm], areSelected: true)
    }
}
