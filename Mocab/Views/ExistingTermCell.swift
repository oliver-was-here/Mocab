import Foundation
import UIKit
import SwipeCellKit

class ExistingTermCell: SwipeTableViewCell {
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
}
