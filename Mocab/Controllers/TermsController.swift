import UIKit

class TermsController: UIViewController {
    @IBOutlet weak var termsTable: UITableView!
    @IBOutlet weak var screenTitle: UILabel!
    @IBOutlet weak var newTermButton: UIButton!
    
    private var isAddingNewTerm = false // state variable used to determine view state of ExistingTermCell
    
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
    
    @IBAction func newTermButtonTapped(_ sender: Any) {
        /*
         todo look into tidying up architecture
         
         logic in method is confused by isAddingNewTerm state variable.
         used in DataSource to determine cell count. called methods therefore
         reference the value indirectly. implication being must clean up old
         state before updating state variable.
         */
        let newAddingTermState = !isAddingNewTerm
        
        newAddingTermState ? configureAddingTermState() : configureReviewTermsState()
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
    
    func reloadTermsTable() {
        learningTerms = initModelViews(for: statusType)
        termsTable.reloadData()
    }
    
    // MARK: Private
    private func configureAddingTermState() {
        let firstCellIndexPath = IndexPath.init(row: 0, section: 0)
        
        if let oldSelected = termsTable.indexPathForSelectedRow {
            tableDelegate.tableView(termsTable, didDeselectRowAt: oldSelected)
        }
        
        isAddingNewTerm = true
        
        termsTable.insertRows(at: [firstCellIndexPath], with: .automatic)
        if let newCell = termsTable.cellForRow(at: firstCellIndexPath) as? NewTermCell {
            newCell.newTerm.becomeFirstResponder()
            newCell.newTerm.delegate = self
        }
        
        newTermButton.setTitle("-", for: .normal)
    }
    
    fileprivate func configureReviewTermsState() {
        let firstCellIndexPath = IndexPath.init(row: 0, section: 0)
        
        isAddingNewTerm = false
        termsTable.deleteRows(at: [firstCellIndexPath], with: .automatic)
        newTermButton.setTitle("+", for: .normal)
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
                    self.updateCellHeight(existingRowCell, viewModel)
                }
            }
        }
        
        return terms
    }
    
    private func updateCellHeight(_ existingRowCell: ExistingTermCell, _ viewModel: TermModelView) {
        existingRowCell.definitionTextView.textContainer.maximumNumberOfLines = viewModel.numLines
        existingRowCell.definitionTextView.invalidateIntrinsicContentSize()
        
        self.termsTable.beginUpdates()
        self.termsTable.endUpdates()
    }
}

// MARK: UITableViewDataSource
extension TermsController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return isAddingNewTerm ? learningTerms.count + 1 : learningTerms.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if isAddingNewTerm && IndexPath(row: 0, section: 0) == indexPath {
            return createNewTermCell(forTable: termsTable)
        } else {
            return createTermCell(term: getTerm(at: indexPath), tableView)
        }
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
        if isAddingNewTerm {
            configureReviewTermsState()
            
            guard let receivedTerm = textField.text
                else { return }
            
            ServiceInjector.definer
                .getDefinitions(forTerm: receivedTerm)
                .done { definitions in
                    try TermsController.saveTerm(forTerm: receivedTerm, andDefinitions: definitions)
                    textField.text = nil
                    self.reloadTermsTable()
                }.catch { error in
                    self.handleNoDefinition(textField: textField)
                }
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
    
    private func handleNoDefinition(textField: UITextField) {
        let alert: UIAlertController = AlertProvider.errorAlert(
            title: "Unable to find definition",
            message: "Would you like to provide a custom definition?",
            actions: [
                UIAlertAction(title: "Yes", style: UIAlertAction.Style.default) { _ in
                    guard let receivedTerm = textField.text else { return }
                    textField.text = nil
                    do {
                        try self.requestCustomDefinition(receivedTerm)
                    } catch {
                        print("ERROR: Unable to get definitions: \(error)")
                    }
                },
                UIAlertAction(title: "No", style: UIAlertAction.Style.cancel, handler: nil)
            ]
        )
        self.present(alert, animated: true)
    }
    
    private func requestCustomDefinition(_ receivedTerm: String) throws {
        try TermsController.saveTerm(forTerm: receivedTerm, andDefinitions: [""])
        self.reloadTermsTable()
        
        let termsSection = self.termsTable.numberOfSections - 1
        let lastRow = self.termsTable.numberOfRows(inSection: termsSection) - 1
        let indexPath: IndexPath = IndexPath(row: lastRow, section: termsSection)
        self.termsTable.scrollToRow(at: indexPath, at: .top, animated: true)
        if let cell = self.termsTable.cellForRow(at: indexPath) as? ExistingTermCell {
            cell.definitionTextView.becomeFirstResponder()
        }
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
