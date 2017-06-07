import Foundation
import UIKit
///Generic overlayview for use in the liveView as used in the LearnToCode Playground by Apple.
public class OverlayView: UIView {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        let blurEffect = UIBlurEffect(style: .extraLight)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView.layer.cornerRadius = frame.size.width / 2
        blurEffectView.clipsToBounds = true
        blurEffectView.translatesAutoresizingMaskIntoConstraints = true
        blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        
        addSubview(blurEffectView)
        blurEffectView.frame = bounds
        
        let whiteOverBlurView = UIView()
        whiteOverBlurView.translatesAutoresizingMaskIntoConstraints = true
        whiteOverBlurView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        addSubview(whiteOverBlurView)
        whiteOverBlurView.frame = bounds
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}

