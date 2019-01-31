import Foundation
import UIKit

@objc protocol ListSelectionDelegate {
    func snoozedTapped(_ sender: UIButton)
    func masteredTapped(_ sender: UIButton)
    func inProgressTapped(_ sender: UIButton)
}
