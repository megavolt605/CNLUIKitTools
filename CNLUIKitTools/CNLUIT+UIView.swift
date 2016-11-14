//
//  CNLUIT+UIView.swift
//  CNLUIKitTools
//
//  Created by Igor Smirnov on 11/11/2016.
//  Copyright © 2016 Complex Numbers. All rights reserved.
//

import UIKit

public extension UIView {
    
    public func recursiveDescription(prefix: String = "") -> String {
        
        var desc = "\(prefix)\(self) (\(subviews.count) subviews)"
        
        for subview in subviews {
            let sd = subview.recursiveDescription(prefix: prefix + "  ")
            desc += "\r\n\(sd)"
            desc += "Layers: frame = \(subview.layer.frame) \(subview.layer)"
        }
        return desc;
        
    }
    
    public func addSubViews(_ subViews: Array<UIView>) {
        subViews.forEach { self.addSubview($0) }
    }
    
    public func setHidden(_ hidden: Bool, animated: Bool, duration: TimeInterval = 0.0, visibleAlpha: CGFloat = 1.0, completion: ((_ finished: Bool) -> Void)? = nil) {
        //UIView.setAnimationsEnabled(animated)
        if self.isHidden != hidden {
            if hidden {
                if (layer.animationKeys() == nil) || (layer.animationKeys()!.count == 0) {
                    if animated {
                        UIView.animate(
                            withDuration: duration,
                            animations: { self.alpha = 0.0 },
                            completion: { completed in
                                self.isHidden = true
                                completion?(completed)
                        }
                        )
                    } else {
                        self.alpha = 0.0
                        self.isHidden = true
                        completion?(true)
                    }
                }
            } else {
                if animated {
                    alpha = 0.0
                    self.isHidden = false
                    UIView.animate(
                        withDuration: duration,
                        animations: { self.alpha = visibleAlpha },
                        completion: completion
                    )
                } else {
                    self.alpha = visibleAlpha
                    completion?(true)
                }
            }
        }
    }
    
    public func snapshot() -> UIImage? {
        UIGraphicsBeginImageContextWithOptions(frame.size, false, UIScreen.main.scale)
        if let ctx = UIGraphicsGetCurrentContext() {
            layer.render(in: ctx)
            let image = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            return image
        }
        return nil
    }
    
    public func alignRight(_ view: UIView, frame: CGRect) {
        var r = frame
        r.origin.x = frame.origin.x + bounds.size.width - frame.size.width
        view.frame = r
    }
    
    public func addParallax(_ amount: Double = 100.0, keyPathX: String = "center.x", keyPathY: String = "center.y") {
        let horizontal = UIInterpolatingMotionEffect(keyPath: keyPathX, type: .tiltAlongHorizontalAxis)
        horizontal.minimumRelativeValue = -amount
        horizontal.maximumRelativeValue = amount
        
        let vertical = UIInterpolatingMotionEffect(keyPath: keyPathY, type: .tiltAlongVerticalAxis)
        vertical.minimumRelativeValue = -amount
        vertical.maximumRelativeValue = amount
        
        let group = UIMotionEffectGroup()
        group.motionEffects = [horizontal, vertical]
        addMotionEffect(group)
    }
    
    public var parentViewController: UIViewController? {
        var parentResponder: UIResponder? = self
        while parentResponder != nil {
            parentResponder = parentResponder!.next
            if let viewController = parentResponder as? UIViewController {
                return viewController
            }
        }
        return nil
    }
    
    public func startQuiveringAnimation() {
        let quiverAnim = CABasicAnimation(keyPath: "transform.rotation")
        let startAngle: Float = -1.0 *  Float(M_PI) / 180.0
        let stopAngle: Float = -startAngle
        quiverAnim.fromValue = startAngle
        quiverAnim.toValue = stopAngle * 3.0
        quiverAnim.autoreverses = true
        quiverAnim.duration = 0.15
        quiverAnim.repeatCount = Float.infinity
        let r = Int(arc4random() % 100) - 50
        let timeOffset: CFTimeInterval = Double(r) / 100.0
        quiverAnim.timeOffset = timeOffset
        layer.add(quiverAnim, forKey: "quivering")
    }
    
    public func stopQuiveringAnimation() {
        layer.removeAnimation(forKey: "quivering")
    }

    public func startBounceAnimation() {
        let bounceAnimation = CAKeyframeAnimation(keyPath: "transform.scale")
        bounceAnimation.values = [0.05, 1.3, 0.9, 1.0]
        
        bounceAnimation.duration = 0.6
        var timingFunctions: [CAMediaTimingFunction] = []
        if let values = bounceAnimation.values {
            for _ in 0..<values.count {
                timingFunctions.append(CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut))
            }
        }
        bounceAnimation.timingFunctions = timingFunctions
        bounceAnimation.isRemovedOnCompletion = false
        
        layer.add(bounceAnimation, forKey: "bounce")
    }
    
    
    public func stopBounceAnimation() {
        layer.removeAnimation(forKey: "bounce")
    }
    
    
}
