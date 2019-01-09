import UIKit

class ListsViewController: UIViewController {
    var delegate: UpdateSelectedListDelegate?
    
    @IBAction func snoozedTapped(_ sender: Any) {
        selectStatus(.snoozed)
    }
    
    @IBAction func masteredTapped(_ sender: Any) {
        selectStatus(.mastered)
    }
    
    @IBAction func inProgressTapped(_ sender: Any) {
        selectStatus(.inProgress)
    }
    
    private func selectStatus(_ status: Term.Status) {
        delegate?.display(status: status)
        self.dismiss(animated: true)
    }
    
    @IBAction func dismissTapped(_ sender: Any) {
        self.dismiss(animated: true)
    }
}
