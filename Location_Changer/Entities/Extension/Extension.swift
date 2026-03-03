
import UIKit

// MARK: - UIView
extension UIView {
    func findFirstResponder() -> UIView? {
        if self.isFirstResponder { return self }
        for subview in subviews {
            if let responder = subview.findFirstResponder() {
                return responder
            }
        }
        return nil
    }
    func superview<T: UIView>(of type: T.Type) -> T? {
        if let view = superview as? T { return view }
        return superview?.superview(of: T.self)
    }
}
