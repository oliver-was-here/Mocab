import UIKit

class TermsController: UIViewController {
    @IBOutlet weak var termsTable: UITableView!
    @IBOutlet weak var screenTitle: UILabel!
    
    private static let INIT_STATUS = Term.Status.inProgress
    private var statusType: Term.Status = TermsController.INIT_STATUS {
        didSet {
            self.learningTerms = initModelViews(for: statusType)
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
    private var learningTerms: [TermModelView] = []
    
    private let tableDelegate = TermTableViewDelegate()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        termsTable.delegate = tableDelegate
        termsTable.dataSource = self
        
        self.learningTerms = initModelViews(for: statusType)
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
    
    private func initModelViews(for statusType: Term.Status) -> [TermModelView] {
        let terms = TermModelViewImplFactory.getViewModels(for: statusType)
        
        terms.forEach {
            $0.statusUpdated = {
                // todo probably delete from views here
                self.termsTable.reloadData()
            }
            $0.numLinesUpdated = {[unowned self] viewModel, indexPath in
                if let existingRowCell = self.termsTable.cellForRow(at: indexPath) as? ExistingTermCell {
                    existingRowCell.definitionTextView.textContainer.maximumNumberOfLines = viewModel.numLines
                    existingRowCell.definitionTextView.invalidateIntrinsicContentSize()
                    
                    self.termsTable.beginUpdates()
                    self.termsTable.endUpdates()
                }
            }
        }
        
        return terms
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
        
        cell.configure(modelView: term, swipeDelegate: swipeDelegate, textViewDelegate: self)
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

// MARK: UITextViewDelegate
extension TermsController: UITextViewDelegate {
    private func updateSelection(selectedIndex indexPath: IndexPath) {
        if let oldSelected = termsTable.indexPathForSelectedRow {
            tableDelegate.tableView(termsTable, didDeselectRowAt: oldSelected)
        }
        tableDelegate.tableView(termsTable, didSelectRowAt: indexPath)
    }
    
    func textViewShouldBeginEditing(_ textView: UITextView) -> Bool {
        guard let rowCell = getExistingTermCell(forTextView: textView),
            !rowCell.isSelected,
            let indexPath = termsTable.indexPath(for: rowCell)
            else { return true }
        
        updateSelection(selectedIndex: indexPath)
        return false
    }
    
    private func getExistingTermCell(forTextView textView: UITextView) -> ExistingTermCell? {
        return termsTable
            .visibleCells
            .first(where: {
                if let cell = $0 as? ExistingTermCell,
                    cell.definitionTextView == textView {
                    return true
                }
                
                return false
            }) as? ExistingTermCell
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        getExistingTermCell(forTextView: textView)?
            .modelView?
            .updateDefinition(newDefinition: textView.text)
    }
}
