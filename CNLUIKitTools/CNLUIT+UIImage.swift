//
//  CNLUIT+UIImage.swift
//  CNLUIKitTools
//
//  Created by Igor Smirnov on 11/11/2016.
//  Copyright © 2016 Complex Numbers. All rights reserved.
//

import UIKit

public extension UIImage {
    
    public func adoptToDevice(_ maxSize: CGSize, scale: CGFloat = 2.0) -> UIImage {
        if maxSize.width == 0 || maxSize.height == 0 {
            return self
        }
        UIGraphicsBeginImageContextWithOptions(maxSize, false, scale/*UIScreen.mainScreen().scale*/)
        draw(in: CGRect(x: 0, y: 0, width: maxSize.width, height: maxSize.height))
        let img = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return img!
    }
    
    public func cropInCircleWithRect(_ rect: CGRect, scale: CGFloat) -> UIImage {
        let imageWidth = size.width / scale
        let imageHeight = size.height / scale
        let rectWidth = rect.size.width
        let rectHeight = rect.size.height
        
        UIGraphicsBeginImageContextWithOptions(CGSize(width: rectWidth, height: rectHeight), false, UIScreen.main.scale)
        let context = UIGraphicsGetCurrentContext()
        
        let radius = max(rectWidth, rectHeight) / 2.0
        context?.beginPath()
        context?.addArc(center: CGPoint(x: rectWidth / 2.0, y: rectHeight / 2.0), radius: radius, startAngle: 0, endAngle: CGFloat(2.0 * M_PI), clockwise: false)
        context?.closePath()
        context?.clip()
        
        // Draw the IMAGE
        let myRect = CGRect(x: -rect.origin.x, y: -rect.origin.y, width: imageWidth, height: imageHeight)
        draw(in: myRect)
        
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage!
    }
    
    public func imageWithColor(_ color: UIColor) -> UIImage {
        
        UIGraphicsBeginImageContextWithOptions(size, false, scale)
        
        let context = UIGraphicsGetCurrentContext()
        color.setFill()
        
        context?.translateBy(x: 0, y: size.height)
        context?.scaleBy(x: 1.0, y: -1.0)
        
        context?.setBlendMode(CGBlendMode.copy)
        let rect = CGRect(x: 0, y: 0, width: size.width, height: size.height)
        context?.draw(cgImage!, in: rect)
        
        context?.clip(to: rect, mask: cgImage!)
        context?.addRect(rect)
        context?.drawPath(using: CGPathDrawingMode.fill)//CGPathDrawingMode(kCGPathElementMoveToPoint))
        
        let coloredImg = UIGraphicsGetImageFromCurrentImageContext()
        
        UIGraphicsEndImageContext()
        
        return coloredImg!
    }
    
}

