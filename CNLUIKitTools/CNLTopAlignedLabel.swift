//
//  CNLTopAlignedLabel.swift
//  CNLUIKitTools
//
//  Created by Igor Smirnov on 12/11/2016.
//  Copyright © 2016 Complex Numbers. All rights reserved.
//

import UIKit

class CNLTopAlignedLabel: UILabel{
    
    override func drawText(in rect: CGRect) {
        if let stringText = text {
            let stringTextAsNSString = stringText as NSString
            #if swift(>=4.0)
                let attrs: [NSAttributedStringKey: Any] = [.font: font]
            #else
                let attrs: [String: Any] = [NSFontAttributeName: font]
            #endif
            let labelStringSize = stringTextAsNSString.boundingRect(
                with: CGSize(width: self.frame.width, height: CGFloat.greatestFiniteMagnitude),
                options: NSStringDrawingOptions.usesLineFragmentOrigin,
                attributes: attrs,
                context: nil
            ).size
            super.drawText(in: CGRect(x: 0, y: 0, width: self.frame.width, height: ceil(labelStringSize.height)))
        } else {
            super.drawText(in: rect)
        }
    }
    
}
