import Foundation
import UIKit

func createDoneToolbarItem(target: UITextInput, action: Selector) -> UIToolbar {
    let doneToolbar: UIToolbar = UIToolbar(
        frame: CGRect.init(
            x: 0,
            y: 0,
            width: UIScreen.main.bounds.width,
            height: 50
        )
    )
    doneToolbar.barStyle = .default
    
    let flexSpace = UIBarButtonItem(
        barButtonSystemItem: .flexibleSpace,
        target: nil,
        action: nil
    )
    let done = UIBarButtonItem(
        title: "Done",
        style: .done,
        target: target,
        action: action
    )
    
    doneToolbar.items = [flexSpace, done]
    doneToolbar.sizeToFit()
    
    return doneToolbar
}
