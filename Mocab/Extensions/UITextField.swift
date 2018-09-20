import Foundation
import UIKit

extension UITextField {
    @IBInspectable var doneAccessory: Bool {
        get {
            return self.doneAccessory
        }
        set (hasDone) {
            if hasDone {
                addDoneButtonOnKeyboard()
            }
        }
    }
    
    private func addDoneButtonOnKeyboard() {
        let doneToolbar: UIToolbar = UIToolbar(
            frame: CGRect.init(
                x: 0,
                y: 0,
                width: UIScreen.main.bounds.width,
                height: 50
            )
        )
        doneToolbar.barStyle = .default
        
        let flexSpace = UIBarButtonItem(
            barButtonSystemItem: .flexibleSpace,
            target: nil,
            action: nil
        )
        let done = UIBarButtonItem(
            title: "Done",
            style: .done,
            target: self,
            action: #selector(self.doneButtonAction)
        )
        
        doneToolbar.items = [flexSpace, done]
        doneToolbar.sizeToFit()
        
        self.inputAccessoryView = doneToolbar
    }
    
    @objc private func doneButtonAction() { self.resignFirstResponder() }
}
