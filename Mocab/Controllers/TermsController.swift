import UIKit

class TermsController: UIViewController {
    @IBOutlet weak var termsTable: UITableView!
    @IBOutlet weak var screenTitle: UILabel!
    @IBOutlet weak var newTermButton: UIButton!
    
    private var isAddingNewTerm = false // state variable used to determine view state of ExistingTermCell
    
    private var swipeDelegate = SwipeTermStatusDelegate(forTermType: .inProgress)
    private var terms: [TermModelView] {
        return reviewTermsViewModel?.displayedTerms ?? []
    }
    
    private let tableDelegate = TermTableViewDelegate()
    
    private var reviewTermsViewModel: ReviewTermsViewModel?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        reviewTermsViewModel = ReviewTermsViewModelImpl(
            updatedStatusDisplayed: { newStatus in
                // todo see about performing the swipe delegate on a per-cell basis (e.g. conflating this with the statusUpdated item. called per cell not for entire table)
                self.swipeDelegate = SwipeTermStatusDelegate(forTermType: newStatus)
            },
            updatedDisplayedTerms: { newTerms in
                self.termsTable.reloadData()
            },
            didUpdateScreenTitle: { newTitle in
                self.screenTitle.text = newTitle
            },
            statusUpdated: { self.termsTable.reloadData() },
            numLinesUpdated: {[unowned self] viewModel, indexPath in
                if let existingRowCell = self.termsTable.cellForRow(at: indexPath) as? ExistingTermCell {
                    self.updateCellHeight(existingRowCell, viewModel)
                }
            }
        )
        
        termsTable.delegate = tableDelegate
        termsTable.dataSource = self
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
        bindChangeStatusTapped(forStatus: .snoozed)
    }
    
    @IBAction func masteredTapped(_ sender: Any) {
        bindChangeStatusTapped(forStatus: .mastered)
    }
    
    @IBAction func inProgressTapped(_ sender: Any) {
        bindChangeStatusTapped(forStatus: .inProgress)
    }
    
    // MARK: Private
    private func bindChangeStatusTapped(forStatus status: Term.Status) {
        reviewTermsViewModel?.updateDisplayedTerms(to: status)
    }
    
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
    
    private func configureReviewTermsState() {
        let firstCellIndexPath = IndexPath.init(row: 0, section: 0)
        
        isAddingNewTerm = false
        termsTable.deleteRows(at: [firstCellIndexPath], with: .automatic)
        newTermButton.setTitle("+", for: .normal)
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
        return isAddingNewTerm ? terms.count + 1 : terms.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if isAddingNewTerm && IndexPath(row: 0, section: 0) == indexPath {
            return createNewTermCell(forTable: termsTable)
        } else {
            return createTermCell(term: getTerm(at: indexPath), tableView)
        }
    }
    
    // Mark: Private
    
    private func getTerm(at indexPath: IndexPath) -> TermModelView {
        return terms[indexPath.row]
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
            textField.text = nil
            
            reviewTermsViewModel?
                .addTerm(receivedTerm)
                .done { _ in
                    self.isAddingNewTerm = false
                    self.termsTable.reloadData()
                }.catch { error in
                    self.handleNoDefinition(receivedTerm: receivedTerm)
                }
        }
    }
    
    // MARK: private
    private func handleNoDefinition(receivedTerm: String) {
        let alert: UIAlertController = AlertProvider.errorAlert(
            title: "Unable to find definition",
            message: "Would you like to provide a custom definition?",
            actions: [
                UIAlertAction(title: "Yes", style: UIAlertAction.Style.default) { _ in
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
        reviewTermsViewModel?.addTerm(receivedTerm, "")
        termsTable.reloadData()
        
        // todo this logic assumes addTerm adds the cell to end of list. a "request definition" w/ IndexPath binding would be more sensible
        let termsSection = self.termsTable.numberOfSections - 1
        let lastRow = self.termsTable.numberOfRows(inSection: termsSection) - 1
        let indexPath: IndexPath = IndexPath(row: lastRow, section: termsSection)
        self.termsTable.scrollToRow(at: indexPath, at: .top, animated: true)
        if let cell = self.termsTable.cellForRow(at: indexPath) as? ExistingTermCell {
            cell.definitionTextView.becomeFirstResponder() // todo broken, does not open keyboard. looking at moving this to popover so putting off the fix for now
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
