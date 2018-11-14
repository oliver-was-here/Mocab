import Foundation
import UIKit

extension UITextView {
    /*
     note: any changes made may also need to be replicated in UITedtView extension
     */
    @IBInspectable var doneAccessory: Bool {
        get {
            return self.doneAccessory
        }
        set (hasDone) {
            if hasDone {
                inputAccessoryView = createDoneToolbarItem(target: self, action: #selector(doneButtonAction))
            }
        }
    }
    
    @objc private func doneButtonAction() { resignFirstResponder() }
}
