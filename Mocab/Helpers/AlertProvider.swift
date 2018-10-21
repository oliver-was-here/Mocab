import Foundation
import UIKit

class AlertProvider {
    static func errorAlert(
        title: String = "Hmm...",
        message: String = "Something went wrong. Please try again later."
        ) -> UIAlertController {
        let alert = UIAlertController(
            title: title,
            message: message,
            preferredStyle: UIAlertController.Style.alert
        )
        
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
        return alert
    }
}
