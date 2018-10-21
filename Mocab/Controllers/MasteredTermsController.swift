import UIKit
import Foundation
import SwipeCellKit

class MasteredTermsController: UIViewController {
    @IBOutlet weak var termsTable: UITableView!
    
    private var masteredTerms: [Term] {
        return ServiceInjector.termsService
            .getAll()
            .filter { $0.status == Term.Status.mastered }
    }
    private let swipeDelegate = SwipeTermStatusDelegateFactory.init(forTermType: Term.Status.mastered)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
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
        
        cell.configure(term: masteredTerms[indexPath.row], delegate: swipeDelegate)
        return cell
    }
}

extension MasteredTermsController: SwipeTableViewCellDelegate {
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> [SwipeAction]? {
        guard orientation == .right else { return nil }
        
        let snoozeTerm = SwipeAction(style: .default, title: "Relearn") { action, indexPath in
            guard let cell = tableView.cellForRow(at: indexPath) as? ExistingTermCell,
                var term = cell.term
                else {
                    return
            }
            
            term.status = Term.Status.inProgress
            ServiceInjector.termsService.save(term)
            
            tableView.reloadData()
        }
        
        return [snoozeTerm]
    }
}
