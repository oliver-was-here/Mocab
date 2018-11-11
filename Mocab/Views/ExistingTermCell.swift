import Foundation
import UIKit
import SwipeCellKit

class ExistingTermCell: SwipeTableViewCell {
    static let ID = "EXISTING_TERM"
    var modelView: TermModelView?
    
    @IBOutlet weak var definitionTextView: UITextView!
    @IBOutlet weak var termLabel: UILabel!
    func configure(modelView: TermModelView, delegate: SwipeTableViewCellDelegate) {
        termLabel?.text = modelView.term
        definitionTextView?.text = modelView.definition
        definitionTextView.textContainer.maximumNumberOfLines = modelView.numLines
        definitionTextView.textContainer.lineBreakMode = NSLineBreakMode.byTruncatingTail

        self.modelView = modelView
        self.delegate = delegate
    }
}
