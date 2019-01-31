import UIKit

class ListsViewController: UIViewController, ListSelectionDelegate {
    @IBOutlet weak var lists: UIStackView!
    
    var delegate: UpdateSelectedListDelegate?
    private var viewModel: ListsViewModel?
    private var tagToListID: [Int: String] = [:]
    
    override func viewDidAppear(_ animated: Bool) {
        viewModel = ListsViewModel(
            receivedNewLists: { listViewModel in
                listViewModel.forEach {
                    let tag = self.tagToListID.count
                    self.tagToListID[tag] = $0.id
                    self.lists.addArrangedSubview(
                        ListView.instantiate(
                            tag: tag,
                            listName: $0.name,
                            delegate: self
                        )
                    )
                }
            }
        )
    }
    // todo fix bug of appending the same list
    
    // MARK: ListSelectionDelegate
    func snoozedTapped(_ sender: UIButton) {
        selectStatus(.snoozed, tag: sender.tag)
    }
    
    func masteredTapped(_ sender: UIButton) {
        selectStatus(.mastered, tag: sender.tag)
    }
    
    func inProgressTapped(_ sender: UIButton) {
        selectStatus(.inProgress, tag: sender.tag)
    }
    
    // MARK: private
    
    private func selectStatus(_ status: Term.Status, tag: Int) {
        let listID: String = tagToListID[tag]
            ?? ServiceInjector.termsService.getDefaultListID()
            ?? ""
        
        delegate?.display(status: status, forList: listID)
        self.dismiss(animated: true)
    }
}
