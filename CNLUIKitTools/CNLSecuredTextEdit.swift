//
//  CNLSecuredTextEdit.swift
//  CNLUIKitTools
//
//  Created by Igor Smirnov on 12/11/2016.
//  Copyright © 2016 Complex Numbers. All rights reserved.
//

import UIKit

open class CNLSecuredTextField: UITextField {
    
    open var secured = true
    
    let secureActions: [String] = [
        "paste:",
        "copy:",
        "cut:",
        "select:",
        "selectAll:",
        "delete:",
        "_share:",
        "_define:",
        "_promptForReplace:",
        "_transliterateChinese:",
        "_showTextStyleOptions:",
        "_addShortcut:",
        "_accessibilitySpeak:",
        "_accessibilitySpeakLanguageSelection:",
        "_accessibilityPauseSpeaking:",
        "makeTextWritingDirectionRightToLeft:",
        "makeTextWritingDirectionLeftToRight:"
    ]
    
    override open func canPerformAction(_ action: Selector, withSender sender: Any?) -> Bool {
        if secured {
            if secureActions.contains(action.description) {
                return false
            }
        }
        return super.canPerformAction(action, withSender: sender)
    }

}
