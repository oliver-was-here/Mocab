import UIKit

class LearningTermsController: UIViewController {
    @IBOutlet weak var termsTable: UITableView!
    private var learningTerms: [Term] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        termsTable.dataSource = self
        
        setupDataSource()
    }
}

extension LearningTermsController: UITableViewDataSource {
    static let LEARNING_TERMS_KEY = "learningWords"
    
    func setupDataSource() {
        if let learningTermsJson = UserDefaults
            .standard
            .object(forKey: LearningTermsController.LEARNING_TERMS_KEY) as? Data,
            let learningTerms = try? SerializationMapper
                .decoder
                .decode([Term].self, from: learningTermsJson)
        {
            self.learningTerms.append(contentsOf: learningTerms)
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return (section == 0) ? learningTerms.count : (0)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        
        if indexPath.section == 0 { // todo make enum for learning words
            cell.textLabel?.text = learningTerms[indexPath.row].term
        }
        
        return cell
    }
}
