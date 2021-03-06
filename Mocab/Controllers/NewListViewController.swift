import Foundation
import UIKit

class NewListViewController: UIViewController {
    @IBOutlet weak var listName: UITextField!
    
    @IBAction func dismissButtonTapped(_ sender: Any) {
        self.dismiss(animated: true)
    }
    
    @IBAction func createListTapped(_ sender: Any) {
        let name = listName.text ?? ""
        
        ServiceInjector.listsService.create(name: name)
        self.dismiss(animated: true)
    }
}
