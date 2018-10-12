import Foundation
import UIKit

class ExistingTermCell: UITableViewCell {
    static let ID = "EXISTING_TERM"
    
    func configure(term: Term) {
        textLabel?.text = term.asEntered
        detailTextLabel?.text = term.definition
        detailTextLabel?.numberOfLines = 3
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
