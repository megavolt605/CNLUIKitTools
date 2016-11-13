//
//  CNLQRCodeGenerator.swift
//  CNLUIKitTools
//
//  Created by Igor Smirnov on 12/11/2016.
//  Copyright © 2016 Complex Numbers. All rights reserved.
//

import UIKit

enum CNLQRCodeCorrectionLevel: String
{
    case percent7 = "L"
    case percent15 = "M"
    case percent25 = "Q"
    case percent30 = "H"
}

struct CNLQRCodeGenerator {
    
    static func generateQRForString(_ qrString: String, width: CGFloat = 200, correctionLevel: CNLQRCodeCorrectionLevel = .percent25) -> UIImage? {
        if let stringData = qrString.data(using: String.Encoding.utf8), let qrFilter = CIFilter(name:"CIQRCodeGenerator") {
            qrFilter.setValue(stringData, forKey: "inputMessage")
            qrFilter.setValue(correctionLevel.rawValue, forKey: "inputCorrectionLevel")
            guard let image = qrFilter.outputImage else { return nil }
            let scale = width / image.extent.width
            let cgImage = CIContext(options: nil).createCGImage(image, from: image.extent)
            UIGraphicsBeginImageContext(CGSize(
                width: image.extent.size.width * scale,
                height: image.extent.size.width * scale
            ))
            
            let context = UIGraphicsGetCurrentContext()
            context!.interpolationQuality = CGInterpolationQuality.none
            context?.draw(cgImage!, in: (context?.boundingBoxOfClipPath)!)
            let qrImage : UIImage = UIGraphicsGetImageFromCurrentImageContext()!
            UIGraphicsEndImageContext()
            return qrImage
        } else {
            return nil
        }
    }
}
