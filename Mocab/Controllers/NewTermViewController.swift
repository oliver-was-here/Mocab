import Foundation
import UIKit

class NewTermViewController: UIViewController {
    @IBOutlet weak var newTermTextField: UITextField!
    @IBOutlet weak var definitionsView: UIStackView!
    @IBOutlet weak var saveTermButton: UIButton!
    @IBOutlet weak var addCustomDefinitionButton: UIButton!
    @IBOutlet weak var customDefinitionTextField: UITextField!
    private let definitionPrefix = "- "
    
    private var viewModel: NewTermModelView?
    private var customDefinitionTextFieldDelegate: UITextFieldDelegate?
    
    @IBAction func dismissButtonTapped(_ sender: Any) {
        self.dismiss()
    }
    
    @IBAction func saveEntryButtonTapped(_ sender: Any) {
        if let term = newTermTextField.text,
            let viewModel = viewModel {
            let definitions = viewModel.selectedDefinitions()
                .map { definitionPrefix + $0 }
                .joined(separator: "\n")
             
            viewModel.saveEntry(
                term: term,
                chosenDefinition: definitions
            )
        }
        
        self.dismiss()
    }
    
    @IBAction func addCustomDefinitionButtonTapped(_ sender: Any) {
        setCustomDefinitionInputState(displayTextField: true)
    }
    
    override func viewDidLoad() {
        newTermTextField.becomeFirstResponder()
        newTermTextField.delegate = self
        
        let viewModel: NewTermModelViewImpl = NewTermModelViewImpl(
            definitionsAdded: { viewModels in
                viewModels.forEach { viewModel in
                    let definitionView = DefinitionView.instantiate(viewModel: viewModel)
                    viewModel.didUpdateSelectState = { newState in
                        definitionView.setSelectedState(isSelected: newState)
                    }
                    
                    self.definitionsView.addArrangedSubview(
                        definitionView
                    )
                }
                self.newTermTextField.isEnabled = false
                self.saveTermButton.isHidden = false
                
                self.setCustomDefinitionInputState(displayTextField: false)
            }
        )
        
        self.viewModel = viewModel
        
        self.customDefinitionTextFieldDelegate = CustomDefinitionTextFieldDelegate(viewModel: viewModel)
        customDefinitionTextField.delegate = customDefinitionTextFieldDelegate
    }
    
    //MARK: private
    private func setCustomDefinitionInputState(displayTextField: Bool) {
        guard let customDefinitionTextField = customDefinitionTextField,
            let addCustomDefinitionButton = addCustomDefinitionButton
            else { return }
        
        if displayTextField {
            customDefinitionTextField.becomeFirstResponder()
            customDefinitionTextField.text = ""
        }
        addCustomDefinitionButton.isHidden = displayTextField
        customDefinitionTextField.isHidden = !displayTextField
        
        let view = displayTextField ? customDefinitionTextField : addCustomDefinitionButton
        self.definitionsView.addArrangedSubview(view)
    }
    
    private func dismiss() {
        dismiss(animated: true)
    }
}

// MARK: UITextFieldDelegate
extension NewTermViewController: UITextFieldDelegate {
    func textFieldDidEndEditing(_ textField: UITextField) {
        guard let receivedTerm = textField.text,
        !self.isBeingDismissed
            else { return }
        
        viewModel?
            .newTermReceived(receivedTerm)
            .catch { error in
                self.handleNoDefinition(receivedTerm: receivedTerm)
            }
    }
    
    // MARK: private
    private func handleNoDefinition(receivedTerm: String) {
        let alert: UIAlertController = AlertProvider.errorAlert(
            title: "Unable to find definition",
            message: "Would you like to provide a custom definition?",
            actions: [
                UIAlertAction(title: "Yes", style: UIAlertAction.Style.default) { _ in
                    do {
                        try self.requestCustomDefinition(receivedTerm)
                    } catch {
                        print("ERROR: Unable to get definitions: \(error)")
                    }
                },
                UIAlertAction(
                    title: "No",
                    style: UIAlertAction.Style.cancel,
                    handler: { _ in self.dismiss() }
                )
            ]
        )
        self.present(alert, animated: true)
    }
    
    private func requestCustomDefinition(_ receivedTerm: String) throws {
        setCustomDefinitionInputState(displayTextField: true)
    }
}
