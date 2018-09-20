import UIKit

class LearningTermsController: UIViewController {
    @IBOutlet weak var termsTable: UITableView!
    private var learningTerms: [Term] {
        return ServiceInjector.termsService.getAll()
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
        switch (Section.init(rawValue: section)) {
        case .learning?:
            return learningTerms.count + 1
        default:
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch (Section.init(rawValue: indexPath.section)) {
        case .learning?:
            let isInputCell: Bool = indexPath.row > learningTerms.count - 1
            return isInputCell
                ? createNewTermCell(forTable: tableView)
                : LearningTermsController.createTermCell(term: learningTerms[indexPath.row], tableView)
        default:
            return UITableViewCell()
        }
    }
    
    enum Section: Int {
        case learning = 0
    }
    
    // Mark: Private
    
    static private func createTermCell(term: Term, _ tableView: UITableView) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: ExistingTermCell.ID) as? ExistingTermCell
            else {
                return UITableViewCell()
            }
        
        cell.configure(term: term)
        
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
        let term = Term.init(asEntered: receivedTerm, definition: definition)
        ServiceInjector.termsService.save(term)
    }
}
