import UIKit

class SelectListCell: UITableViewCell {
    static let ID = "SELECT_LIST_ID"

    @IBOutlet weak var listNameLabel: UILabel!
    @IBOutlet weak var progressButton: UIButton!
    @IBOutlet weak var snoozedButton: UIButton!
    @IBOutlet weak var masteredButton: UIButton!

    func configure(
        viewModel: ListViewModel,
        tag: Int,
        delegate: ListSelectionDelegate
    ) {
        listNameLabel.text = viewModel.name

        progressButton.tag = tag
        snoozedButton.tag = tag
        masteredButton.tag = tag

        progressButton.addTarget(
            delegate,
            action: #selector(delegate.inProgressTapped(_:)),
            for: .touchUpInside
        )
        snoozedButton.addTarget(
            delegate,
            action: #selector(delegate.snoozedTapped(_:)),
            for: .touchUpInside
        )
        masteredButton.addTarget(
            delegate,
            action: #selector(delegate.masteredTapped(_:)),
            for: .touchUpInside
        )
    }
}
