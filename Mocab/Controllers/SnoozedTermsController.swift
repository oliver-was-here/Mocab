import UIKit
import Foundation

class SnoozedTermsController: UIViewController {    
    @IBOutlet weak var termsTable: UITableView!

    private let swipeDelegate = SwipeTermStatusDelegateFactory.init(forTermType: Term.Status.snoozed)
    private var snoozedTerms: [Term] {
        return ServiceInjector.termsService
            .getAll()
            .filter { $0.status == Term.Status.snoozed }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        termsTable.dataSource = self
    }
}

extension SnoozedTermsController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return snoozedTerms.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: ExistingTermCell.ID) as? ExistingTermCell
            else {
                return UITableViewCell()
            }
   
        cell.configure(term: snoozedTerms[indexPath.row], delegate: swipeDelegate)
        return cell
    }
}
