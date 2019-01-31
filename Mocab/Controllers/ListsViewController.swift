import UIKit

class ListsViewController: UIViewController, ListSelectionDelegate, UITableViewDataSource {
    
    var delegate: UpdateSelectedListDelegate?
    private let listsService = ServiceInjector.listsService
    private var viewModels: [ListViewModel] = []

    @IBOutlet weak var listsTable: UITableView!
    
    override func viewDidLoad() {
        listsTable.dataSource = self
    }
    
    override func viewDidAppear(_ animated: Bool) {
        viewModels = listsService.getAll().map { ListViewModel(id: $0.id, name: $0.name) }
        listsTable.reloadData()
    }
    
    // MARK: ListSelectionDelegate
    func snoozedTapped(_ sender: UIButton) {
        selectStatus(.snoozed, index: sender.tag)
    }
    
    func masteredTapped(_ sender: UIButton) {
        selectStatus(.mastered, index: sender.tag)
    }
    
    func inProgressTapped(_ sender: UIButton) {
        selectStatus(.inProgress, index: sender.tag)
    }
    
    //MARK: UITableViewDataSource
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModels.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: SelectListCell.ID) as? SelectListCell
            else {
                return UITableViewCell()
            }
        
        cell.configure(
            viewModel: viewModels[indexPath.row],
            tag: indexPath.row,
            delegate: self
        )
        
        return cell
    }

    // MARK: private
    private func selectStatus(_ status: Term.Status, index: Int) {
        let listID: String = viewModels[index].id
        
        delegate?.display(status: status, forList: listID)
        self.dismiss(animated: true)
    }
}
