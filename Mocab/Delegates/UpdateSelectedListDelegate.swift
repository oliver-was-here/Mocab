import Foundation

protocol UpdateSelectedListDelegate {
    func display(status: Term.Status, forList listID: String)
}
