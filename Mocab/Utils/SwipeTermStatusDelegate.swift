import Foundation
import SwipeCellKit

class SwipeTermStatusDelegateFactory: SwipeTableViewCellDelegate {
    private let termType: Term.Status
    
    init(forTermType termType: Term.Status) {
        self.termType = termType
    }
    
    // MARK: SwipeTableViewCellDelegate
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> [SwipeAction]? {
        guard orientation == .right else { return nil }
        
        return [
            termType == Term.Status.inProgress ? nil : getInProgressTerm(tableView: tableView),
            termType == Term.Status.snoozed ? nil : getInSnoozeTerm(tableView: tableView),
            termType == Term.Status.mastered ? nil : createMasterTermAction(tableView: tableView),
        ].compactMap { $0 }
    }
    
    // MARK: Private
    
    private func getInProgressTerm(tableView: UITableView) -> SwipeAction {
        return SwipeAction(style: .default, title: "Relearn") { action, indexPath in
            self.updateTerm(tableView: tableView, at: indexPath, newStatus: Term.Status.inProgress)
        }
    }
    
    private func getInSnoozeTerm(tableView: UITableView) -> SwipeAction {
        return SwipeAction(style: .default, title: "Snooze") { action, indexPath in
            self.updateTerm(tableView: tableView, at: indexPath, newStatus: Term.Status.snoozed)
        }
    }
    
    private func createMasterTermAction(tableView: UITableView) -> SwipeAction {
        return SwipeAction(style: .default, title: "Master") { action, indexPath in
            self.updateTerm(tableView: tableView, at: indexPath, newStatus: Term.Status.mastered)
        }
    }
    
    private func updateTerm(tableView: UITableView, at indexPath: IndexPath, newStatus: Term.Status) {
        guard let cell = tableView.cellForRow(at: indexPath) as? ExistingTermCell,
            let modelView = cell.modelView
            else {
                return
            }
        
        modelView.selectedNewStatus(newStatus)
    }
}
