import UIKit

class TermsController: UIViewController, UpdateSelectedListDelegate {
    @IBOutlet weak var termsTable: UITableView!
    @IBOutlet weak var screenTitle: UILabel!
    
    private var swipeDelegate = SwipeTermStatusDelegate(forTermType: .inProgress)
    private var terms: [TermModelView] {
        return reviewTermsViewModel?.displayedTerms ?? []
    }
    
    private let tableDelegate = TermTableViewDelegate()
    
    private var reviewTermsViewModel: ReviewTermsViewModel?
    
    override func viewDidAppear(_ animated: Bool) {
        termsTable.reloadData()
    }
    
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
            statusUpdated: { self.reviewTermsViewModel?.removeTerm(term: $0) },
            numLinesUpdated: {[unowned self] viewModel, indexPath in
                if let existingRowCell = self.termsTable.cellForRow(at: indexPath) as? ExistingTermCell {
                    self.updateCellHeight(existingRowCell, viewModel)
                }
            }
        )
        
        termsTable.delegate = tableDelegate
        termsTable.dataSource = self
    }
    
    // MARK: UpdateSelectedListDelegate
    func display(status: Term.Status) {
        reviewTermsViewModel?.updateDisplayedTerms(to: status)
    }
    
    // MARK: Private
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
        return terms.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return createExistingTermCell(term: getTerm(at: indexPath), tableView)
    }
    
    // Mark: Private
    
    private func getTerm(at indexPath: IndexPath) -> TermModelView {
        return terms[indexPath.row]
    }
    
    private func createExistingTermCell(term: TermModelView, _ tableView: UITableView) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: ExistingTermCell.ID) as? ExistingTermCell
            else {
                return UITableViewCell()
            }
        
        cell.configure(modelView: term, swipeDelegate: swipeDelegate, textViewDelegate: self)
        return cell
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
