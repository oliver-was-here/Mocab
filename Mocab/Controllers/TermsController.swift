import UIKit

class TermsController: UIViewController {
    @IBOutlet weak var termsTable: UITableView!
    @IBOutlet weak var screenTitle: UILabel!
    
    private static let INIT_STATUS = Term.Status.inProgress
    private var statusType: Term.Status = TermsController.INIT_STATUS {
        didSet {
            termsTable.reloadData()
            swipeDelegate = SwipeTermStatusDelegate(forTermType: statusType)
            
            switch(statusType) {
            case .inProgress: screenTitle?.text = "in progress"
            case .mastered: screenTitle?.text = "mastered"
            case .snoozed: screenTitle?.text = "snoozed"
            }
        }
    }
    private var swipeDelegate = SwipeTermStatusDelegate(forTermType: TermsController.INIT_STATUS)
    private var learningTerms: [TermModelView] {
        let terms = TermModelViewImplFactory.getViewModels(for: statusType)
        
        terms.forEach {
            $0.statusUpdated = {
                self.termsTable.reloadData()
            }
            $0.numLinesUpdated = {[unowned self] viewModel, indexPath in
                guard let existingTerm = self.termsTable.cellForRow(at: indexPath) as? ExistingTermCell
                    else {
                        return
                    }
                
                existingTerm.detailTextLabel?.numberOfLines = viewModel.numLines
                self.termsTable.reloadData()
            }
        }
        return terms
    }
    private let tableDelegate = TermTableViewDelegate()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        termsTable.delegate = tableDelegate
        termsTable.dataSource = self
    }
    
    @IBAction func snoozedTapped(_ sender: Any) {
        self.statusType = Term.Status.snoozed
    }
    
    @IBAction func masteredTapped(_ sender: Any) {
        self.statusType = Term.Status.mastered
    }
    
    @IBAction func inProgressTapped(_ sender: Any) {
        self.statusType = Term.Status.inProgress
    }
}

// MARK: UITableViewDataSource
extension TermsController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch(statusType) {
        case .inProgress: return learningTerms.count + 1
        default: return learningTerms.count
        }
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let isInputCell: Bool = (statusType == Term.Status.inProgress) && (indexPath.row > learningTerms.count - 1)
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
        guard let inputCell = tableView.dequeueReusableCell(withIdentifier: NewTermCell.ID) as? NewTermCell
            else {
                return UITableViewCell()
            }
        
        inputCell.newTerm.delegate = self
        return inputCell
    }
}

// MARK: UITextFieldDelegate
extension TermsController: UITextFieldDelegate {
    func textFieldDidEndEditing(_ textField: UITextField) {
        guard let receivedTerm = textField.text
            else { return }
        
        ServiceInjector.definer
            .getDefinitions(forTerm: receivedTerm)
            .done { definitions in
                try TermsController.saveTerm(forTerm: receivedTerm, andDefinitions: definitions)
                textField.text = nil
                self.termsTable.reloadData()
            }.catch { error in
                let alert: UIAlertController = AlertProvider.errorAlert(message: "We were unable to find a definition for that term.")
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
