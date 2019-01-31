import UIKit
import Foundation

class NewTermSegue: UIStoryboardSegue {
    override init(identifier: String?, source: UIViewController, destination: UIViewController) {
        super.init(
            identifier: identifier,
            source: source,
            destination: destination
        )
        
        guard let termsVC = source as? TermsController,
            let newTermVC = destination as? NewTermViewController
            else { return }
        
        newTermVC.listID = termsVC.listID
    }
}
