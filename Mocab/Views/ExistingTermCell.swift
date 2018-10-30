import Foundation
import UIKit
import SwipeCellKit

class ExistingTermCell: SwipeTableViewCell {
    static let ID = "EXISTING_TERM"
    var modelView: TermModelView?
    
    func configure(modelView: TermModelView, delegate: SwipeTableViewCellDelegate) {
        
        textLabel?.text = modelView.term
        detailTextLabel?.text = modelView.definition
        self.modelView = modelView
        self.delegate = delegate
    }
}
