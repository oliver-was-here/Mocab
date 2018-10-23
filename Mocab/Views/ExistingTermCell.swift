import Foundation
import UIKit
import SwipeCellKit

class ExistingTermCell: SwipeTableViewCell {
    static let ID = "EXISTING_TERM"
    static let COLLAPSED_LINE_LIMIT = 3
    var term: Term?
    
    @IBOutlet weak var input: UITextField!
    func configure(term: Term, delegate: SwipeTableViewCellDelegate) {
        textLabel?.text = term.asEntered
        detailTextLabel?.text = term.definition
        collapseDescription()
        self.term = term
        self.delegate = delegate
    }
    
    func expandDescription() {
        detailTextLabel?.numberOfLines = Int.max
    }
    
    func collapseDescription() {
        detailTextLabel?.numberOfLines = ExistingTermCell.COLLAPSED_LINE_LIMIT
    }
}
