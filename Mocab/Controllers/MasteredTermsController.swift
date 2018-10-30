import UIKit
import Foundation
import SwipeCellKit

class MasteredTermsController: UIViewController {
    @IBOutlet weak var termsTable: UITableView!
    
    private var masteredTerms: [TermModelView] {
        let terms = TermModelViewImplFactory.getViewModels(for: Term.Status.mastered)
        
        terms.forEach {
            $0.statusUpdated = {
                self.termsTable.reloadData()
            }
        }
        return terms
    }
    private let swipeDelegate = SwipeTermStatusDelegateFactory.init(forTermType: Term.Status.mastered)
    private let tableDelegate = TermTableViewDelegate()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        ExistingTermCell.register(tableView: termsTable)
        termsTable.delegate = tableDelegate
        termsTable.dataSource = self
    }
}

extension MasteredTermsController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return masteredTerms.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: ExistingTermCell.ID) as? ExistingTermCell
            else {
                return UITableViewCell()
        }
        
        cell.configure(modelView: masteredTerms[indexPath.row], delegate: swipeDelegate)
        return cell
    }
}
