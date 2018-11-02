import Foundation
import UIKit

class TermTableViewDelegate: NSObject, UITableViewDelegate {
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        guard let existingTerm = tableView.cellForRow(at: indexPath) as? ExistingTermCell
            else {
                return
            }

            existingTerm.modelView?.deselectedTerm(at: indexPath)
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let existingTerm = tableView.cellForRow(at: indexPath) as? ExistingTermCell
            else {
                return
            }
        
        existingTerm.modelView?.selectedTerm(at: indexPath)
        tableView.selectRow(at: indexPath, animated: false, scrollPosition: UITableView.ScrollPosition.none)
    }
}
