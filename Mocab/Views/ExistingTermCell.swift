import Foundation
import UIKit
import SwipeCellKit

class ExistingTermCell: SwipeTableViewCell {
    static let NIB = "ExistingTermCell"
    static let ID = "EXISTING_TERM"
    static let COLLAPSED_LINE_LIMIT = 3
    var term: Term?
    
    @IBOutlet weak var termLabel: UILabel!
    @IBOutlet weak var definitionLabel: UILabel!
    
    func expandDescription() {
        detailTextLabel?.numberOfLines = Int.max
    }
    
    func collapseDescription() {
        detailTextLabel?.numberOfLines = ExistingTermCell.COLLAPSED_LINE_LIMIT
    }
}
