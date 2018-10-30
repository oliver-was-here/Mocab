import UIKit
import Foundation

class SnoozedTermsController: UIViewController {    
    @IBOutlet weak var termsTable: UITableView!

    private let swipeDelegate = SwipeTermStatusDelegateFactory.init(forTermType: Term.Status.snoozed)
    private var snoozedTerms: [TermModelView] {
        let terms = TermModelViewImplFactory.getViewModels(for: Term.Status.snoozed)
        
        terms.forEach {
            $0.statusUpdated = {
                self.termsTable.reloadData()
            }
        }
        return terms
    }
    private let tableDelegate = TermTableViewDelegate()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        ExistingTermCell.register(tableView: termsTable)
        termsTable.delegate = tableDelegate
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
   
        cell.configure(modelView: snoozedTerms[indexPath.row], delegate: swipeDelegate)
        return cell
    }
}
