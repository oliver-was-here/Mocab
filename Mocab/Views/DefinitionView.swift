import Foundation
import UIKit

class DefinitionView: UIView {
    @IBOutlet weak var definitionLabel: UILabel!
    @IBOutlet weak var selectButton: UIButton!
    private var viewModel: DefinitionModelView?
    
    func setSelectedState(isSelected: Bool) {
        let title: String
        let alpha: CGFloat
        if isSelected {
            title = "-"
            alpha = 1.0
        } else {
            title = "+"
            alpha = 0.5
        }
        
        definitionLabel.alpha = alpha
        selectButton.setTitle(title, for: .normal)
    }
    
    @IBAction func didTapSelectButton(_ sender: Any) {
        viewModel?.toggleSelectState()
    }

    static func instantiate(viewModel: DefinitionModelView) -> DefinitionView {
        let definitionView = UINib(nibName: "DefinitionView", bundle: Bundle.main)
            .instantiate(withOwner: nil, options: nil)[0] as! DefinitionView
        definitionView.viewModel = viewModel
        definitionView.definitionLabel.text = viewModel.definition
        definitionView.setSelectedState(isSelected: viewModel.isSelected)
        return definitionView
    }
}
