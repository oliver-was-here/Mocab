import Foundation
import UIKit

class AlertProvider {
    static func errorAlert(
        title: String = "Hmm...",
        message: String = "Something went wrong. Please try again later.",
        actions: [UIAlertAction]
    ) -> UIAlertController {
        let alert = UIAlertController(
            title: title,
            message: message,
            preferredStyle: UIAlertController.Style.alert
        )
        
        actions.forEach {
            alert.addAction($0)
        }
        return alert
    }
}
