//
//  CNUIT+UINavigationController.swift
//  CNUIKitTools
//
//  Created by Igor Smirnov on 11/11/2016.
//  Copyright © 2016 Complex Numbers. All rights reserved.
//

import UIKit

public extension UINavigationController {
    
    public func customPush(_ viewController: UIViewController, flowView: UIView? = nil, flowImage: UIImage? = nil, baseView: UIView? = nil, transitionType: String = kCATransitionPush, subtype: String = kCATransitionFromRight) {
        
        let transition: () -> Void = {
            let transition = CATransition()
            transition.duration = 0.3
            transition.type = transitionType
            transition.subtype = subtype
            
            self.view.layer.add(transition, forKey: kCATransition)
            self.pushViewController(viewController, animated: false)
        }
        
        if let flowView = flowView, let baseView = baseView {
            let frame = flowView.convert(flowView.bounds, to: baseView) // cell.frame
            
            let imageView = UIImageView(frame: frame)
            imageView.image = flowImage ?? flowView.snapshot()
            baseView.addSubview(imageView)
            UIView.animate(withDuration: 0.5, delay: 0.0, options: UIViewAnimationOptions.curveEaseOut,
                           animations: {
                            imageView.layer.transform = CATransform3DMakeScale(2.0, 2.0, 1.0)
                            imageView.alpha = 0.1
                            imageView.center = baseView.bounds.center
            },
                           completion: { completed in
                            imageView.removeFromSuperview()
                            /*
                             UIView.beginAnimations("Showinfo", context: nil)
                             UIView.setAnimationCurve(UIViewAnimationCurve.EaseInOut)
                             UIView.setAnimationDuration(0.75)
                             parentViewController?.navigationController?.pushViewController(viewController, animated: false)
                             UIView.setAnimationTransition(UIViewAnimationTransition.CurlUp, forView: parentViewController!.navigationController!.view, cache: false)
                             UIView.commitAnimations()
                             */
                            transition()
            }
            )
        } else {
            transition()
        }
        
    }
}