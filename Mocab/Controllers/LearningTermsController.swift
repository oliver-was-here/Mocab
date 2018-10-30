import UIKit

class LearningTermsController: UIViewController {
    @IBOutlet weak var termsTable: UITableView!
    
    private var learningTerms: [TermModelView] {
        let terms = TermModelViewImplFactory.getViewModels(for: Term.Status.inProgress)
        
        terms.forEach {
            $0.statusUpdated = {
                self.termsTable.reloadData()
            }
        }
        return terms
    }
    private let swipeDelegate = SwipeTermStatusDelegateFactory.init(forTermType: Term.Status.inProgress)
    private let tableDelegate = TermTableViewDelegate()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        ExistingTermCell.register(tableView: termsTable)
        termsTable.delegate = tableDelegate
        termsTable.dataSource = self
    }
}

// MARK: UITableViewDataSource
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
    
    fileprivate func getTerm(at indexPath: IndexPath) -> TermModelView {
        return learningTerms[indexPath.row]
    }
    
    private func createTermCell(term: TermModelView, _ tableView: UITableView) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: ExistingTermCell.ID) as? ExistingTermCell
            else {
                return UITableViewCell()
            }
        
        cell.configure(modelView: term, delegate: swipeDelegate)
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

// MARK: UITextFieldDelegate
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
                let alert: UIAlertController = AlertProvider.errorAlert(message: "We were unable to find a definition for that word.")
                self.present(alert, animated: true)
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
