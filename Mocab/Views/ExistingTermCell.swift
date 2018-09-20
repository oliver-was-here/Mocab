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
