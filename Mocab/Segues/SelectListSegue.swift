import UIKit

class SelectListSegue: UIStoryboardSegue {
    override init(identifier: String?, source: UIViewController, destination: UIViewController) {
        super.init(
            identifier: identifier,
            source: source,
            destination: destination
        )
        
        guard let termsVC = source as? UpdateSelectedListDelegate,
            let listVC = destination as? ListsViewController
            else { return }
        
        listVC.delegate = termsVC
    }
}
