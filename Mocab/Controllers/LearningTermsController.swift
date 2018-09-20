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
        return (section == 0) ? learningTerms.count : (0)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        
        if indexPath.section == 0 { // todo make enum for learning words
            cell.textLabel?.text = learningTerms[indexPath.row].asEntered
        }
        
        return cell
    }
}
