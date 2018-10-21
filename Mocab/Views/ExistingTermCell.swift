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

class SnoozedTermCell: UITableViewCell {
    // separate class from ExistingTermCell for the time being until a natural structuring presents itself
    static let ID = "SNOOZED_TERM"
    
    func configure(term: Term) {
        textLabel?.text = term.asEntered
        detailTextLabel?.text = term.definition
        detailTextLabel?.numberOfLines = 3
    }
}
