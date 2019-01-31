import UIKit

class ListView: UIView {
    @IBOutlet weak var listName: UILabel!
    @IBOutlet weak var progressButton: UIButton!
    @IBOutlet weak var snoozedButton: UIButton!
    @IBOutlet weak var masteredButton: UIButton!
    
    static func instantiate(
        tag: Int,
        listName: String,
        delegate: ListSelectionDelegate
        ) -> ListView {
        let view = UINib(nibName: "ListView", bundle: Bundle.main)
            .instantiate(withOwner: nil, options: nil)[0] as! ListView
        view.listName.text = listName
        
        view.progressButton.tag = tag
        view.snoozedButton.tag = tag
        view.masteredButton.tag = tag
        
        view.progressButton.addTarget(
            delegate,
            action: #selector(delegate.inProgressTapped(_:)),
            for: .touchUpInside
        )
        view.snoozedButton.addTarget(
            delegate,
            action: #selector(delegate.snoozedTapped(_:)),
            for: .touchUpInside
        )
        view.masteredButton.addTarget(
            delegate,
            action: #selector(delegate.masteredTapped(_:)),
            for: .touchUpInside
        )
        
        return view
    }
}
