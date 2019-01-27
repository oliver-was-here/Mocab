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
        let listID = ServiceInjector.termsService.getDefaultListID() ?? ""
        delegate?.display(status: status, forList: listID)
        self.dismiss(animated: true)
    }
    
    @IBAction func dismissTapped(_ sender: Any) {
        self.dismiss(animated: true)
    }
}
