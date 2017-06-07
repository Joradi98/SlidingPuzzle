import UIKit

extension UIView {
    
    ///Adds constraints to position the view in the conter of the parent view. Used e.g. in the LearnToCode Playground by Apple
    func constrainToCenterOfParent(withAspectRatio aspectRatio: CGFloat) {
        guard let parent = superview else {return}
        
        let centerX = self.centerXAnchor.constraint(equalTo: parent.centerXAnchor)
        centerX.priority = UILayoutPriorityRequired
        let centerY = self.centerYAnchor.constraint(equalTo: parent.centerYAnchor)
        centerY.priority = UILayoutPriorityRequired
        let aspectRatio = self.widthAnchor.constraint(equalTo: self.heightAnchor, multiplier: aspectRatio)
        aspectRatio.priority = UILayoutPriorityRequired
        let lessThanOrEqualWidth = self.widthAnchor.constraint(lessThanOrEqualTo: parent.widthAnchor)
        lessThanOrEqualWidth.priority = UILayoutPriorityRequired
        let lessThanOrEqualHeight = self.widthAnchor.constraint(lessThanOrEqualTo: parent.heightAnchor)
        lessThanOrEqualHeight.priority = UILayoutPriorityRequired
        
        let equalWidth = self.widthAnchor.constraint(equalTo: parent.widthAnchor)
        equalWidth.priority = UILayoutPriorityDefaultHigh
        let equalHeight = self.heightAnchor.constraint(equalTo: parent.heightAnchor)
        equalHeight.priority = UILayoutPriorityDefaultHigh
        
        NSLayoutConstraint.activate([
            centerX,
            centerY,
            aspectRatio,
            lessThanOrEqualWidth,
            lessThanOrEqualHeight,
            equalWidth,
            equalHeight
        ])
    }
}
