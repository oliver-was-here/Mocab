import Foundation
import UIKit
import SwipeCellKit

class ExistingTermCell: SwipeTableViewCell {
    static let NIB = "ExistingTermCell"
    static let ID = "EXISTING_TERM"
    var modelView: TermModelView?
    
    @IBOutlet weak var termLabel: UILabel!
    @IBOutlet weak var definitionLabel: UILabel!
    
    func configure(modelView: TermModelView, delegate: SwipeTableViewCellDelegate) {
        termLabel?.text = modelView.term
        definitionLabel?.text = modelView.definition
        self.modelView = modelView
        self.delegate = delegate
    }
    
    static func register(tableView: UITableView) {
        tableView.register(
            UINib(nibName: "ExistingTermCell", bundle: Bundle.main),
            forCellReuseIdentifier: ExistingTermCell.ID
        )
    }
}
