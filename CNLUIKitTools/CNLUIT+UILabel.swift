//
//  CNLUIT+UILabel.swift
//  CNLUIKitTools
//
//  Created by Igor Smirnov on 11/11/2016.
//  Copyright © 2016 Complex Numbers. All rights reserved.
//

import UIKit

public extension UILabel {
    
    public func calculateHeight(_ width: CGFloat = 0.0) -> CGFloat {
        guard let font = self.font else { return 0.0 }
        let textSize = CGSize(width: bounds.width, height: 10000.0)
        #if swift(>=4.0)
            let attrs: [NSAttributedStringKey: Any] = [.font: font]
        #else
            let attrs: [String: Any] = [NSFontAttributeName: font]
        #endif
        if let text = text {
            return text.boundingRect(with: textSize, options: NSStringDrawingOptions.usesLineFragmentOrigin, attributes: attrs, context: nil).height
        } else {
            return 0.0
        }
    }
    
    public func calculateWidth() -> CGFloat {
        guard let font = self.font else { return 0.0 }
        let textSize = CGSize(width: 10000.0, height: bounds.height)
        #if swift(>=4.0)
            let attrs: [NSAttributedStringKey: Any] = [.font: font]
        #else
            let attrs: [String: Any] = [NSFontAttributeName: font]
        #endif
        if let text = text {
            return text.boundingRect(with: textSize, options: NSStringDrawingOptions.usesLineFragmentOrigin, attributes: attrs, context: nil).width
        } else {
            return 0.0
        }
    }
    
}
