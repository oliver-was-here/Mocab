import UIKit
import SwipeCellKit

class LearningTermsController: UIViewController {
    @IBOutlet weak var termsTable: UITableView!
    private var learningTerms: [Term] {
        return ServiceInjector.termsService
            .getAll()
            .filter { $0.status == Term.Status.inProgress }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        termsTable.dataSource = self
    }
}

extension LearningTermsController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return learningTerms.count + 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let isInputCell: Bool = indexPath.row > learningTerms.count - 1
        return isInputCell
            ? createNewTermCell(forTable: tableView)
            : createTermCell(term: getTerm(at: indexPath), tableView)
    }
    
    // Mark: Private
    
    fileprivate func getTerm(at indexPath: IndexPath) -> Term {
        return learningTerms[indexPath.row]
    }
    
    private func createTermCell(term: Term, _ tableView: UITableView) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: ExistingTermCell.ID) as? ExistingTermCell
            else {
                return UITableViewCell()
            }
        
        cell.configure(term: term, delegate: self)
        return cell
    }
    
    private func createNewTermCell(forTable tableView: UITableView) -> UITableViewCell {
        guard let inputCell = tableView.dequeueReusableCell(withIdentifier: NewWordCell.ID) as? NewWordCell
            else {
                return UITableViewCell()
            }
        
        inputCell.newWord.delegate = self
        return inputCell
    }
}

extension LearningTermsController: UITextFieldDelegate {
    func textFieldDidEndEditing(_ textField: UITextField) {
        guard let receivedTerm = textField.text
            else { return }
        
        ServiceInjector.definer
            .getDefinitions(forWord: receivedTerm)
            .done { definitions in
                try LearningTermsController.saveTerm(forTerm: receivedTerm, andDefinitions: definitions)
                textField.text = nil
                self.termsTable.reloadData()
            }.catch { error in
                print("ERROR: Unable to get definitions: \(error)")
            }
    }
    
    // MARK: Private
    
    static private func saveTerm(
        forTerm receivedTerm: String,
        andDefinitions definitions: [String]) throws
    {
        guard let definition = definitions.first
            else {
                throw UnexpectedPayloadError(message: "empty definition list")
            }
        let term = Term(
            asEntered: receivedTerm,
            definition: definition,
            status: Term.Status.inProgress
        )
        ServiceInjector.termsService.save(term)
    }
}

extension LearningTermsController: SwipeTableViewCellDelegate {
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> [SwipeAction]? {
        guard orientation == .right else { return nil }
        
        let snoozeTerm = SwipeAction(style: .default, title: "Snooze") { action, indexPath in
            guard let cell = tableView.cellForRow(at: indexPath) as? ExistingTermCell,
            var term = cell.term
                else {
                    return
                }
            
            term.status = Term.Status.snoozed
            ServiceInjector.termsService.save(term)
            
            tableView.reloadData()
        }
        
        return [snoozeTerm]
    }
}
