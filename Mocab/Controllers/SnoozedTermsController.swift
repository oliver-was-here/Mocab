import UIKit
import Foundation
import SwipeCellKit

class SnoozedTermsController: UIViewController {    
    @IBOutlet weak var termsTable: UITableView!
    
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
   
        cell.configure(term: snoozedTerms[indexPath.row], delegate: self)
        return cell
    }
}

extension SnoozedTermsController: SwipeTableViewCellDelegate {
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> [SwipeAction]? {
        guard orientation == .right else { return nil }
        
        let snoozeTerm = SwipeAction(style: .default, title: "Unsnooze") { action, indexPath in
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
