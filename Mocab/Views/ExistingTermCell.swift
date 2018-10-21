import Foundation
import UIKit
import SwipeCellKit

class ExistingTermCell: SwipeTableViewCell {
    static let ID = "EXISTING_TERM"
    var term: Term?
    
    func configure(term: Term, delegate: SwipeTableViewCellDelegate) {
        textLabel?.text = term.asEntered
        detailTextLabel?.text = term.definition
        detailTextLabel?.numberOfLines = 3
        self.term = term
        self.delegate = delegate
    }
}
