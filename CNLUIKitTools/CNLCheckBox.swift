//
//  CNLCheckBox.swift
//  CNLUIKitTools
//
//  Created by Igor Smirnov on 24/11/2016.
//  Copyright © 2016 Complex Numbers. All rights reserved.
//

import UIKit

import CNLFoundationTools

public enum CNLCheckBoxState {
    case empty, tick, cross
}

public class CNLCheckBox: UIView {
    
    public var lineWidth: [CNLCheckBoxState: CGFloat] = [.empty: 2.0, .tick: 4.0, .cross: 4.0]
    private var currentLineWidth: CGFloat { return lineWidth[state] ?? 0.0 }
    
    public var lineColor: [CNLCheckBoxState: UIColor] = [.empty: UIColor.white, .tick: UIColor.white, .cross: UIColor.white]
    private var currentLineColor: UIColor { return lineColor[state] ?? UIColor.white }
    
    public var fillColor: UIColor = UIColor.white
    //private var currentFillColor: UIColor { return fillColor[state] ?? UIColor.gray }

    public var borderLineWidth: [CNLCheckBoxState: CGFloat] = [.empty: 2.0, .tick: 0.0, .cross: 0.0] {
        didSet {
            updateLayers()
        }
    }
    private var currentBorderLineWidth: CGFloat { return borderLineWidth[state] ?? 0.0 }
    
    public var borderColor: [CNLCheckBoxState: UIColor] = [.empty: UIColor.black, .tick: UIColor.green, .cross: UIColor.red] {
        didSet {
            updateLayers()
        }
    }
    private var currentBorderColor: UIColor { return borderColor[state] ?? UIColor.white }
    
    public var stateSequence: [CNLCheckBoxState] = [.empty, .tick] {
        didSet {
            stateSequenceIndex = 0
            setState(stateSequence[stateSequenceIndex], animated: false)
        }
    }
    public var stateSequenceIndex: Int = 0
    
    private var _state: CNLCheckBoxState = .empty
    public var state: CNLCheckBoxState {
        get { return _state }
        set { setState(newValue, animated: false) }
    }
    
    //public var style: [CNLCheckBoxState: CNLCheckBoxStyle] = [.unchecked: .empty, .checked: .tick]
    
    public var animationDuration: Double = 0.5
    
    public var borderCircle: CAShapeLayer!
    public var centerCircle: CAShapeLayer!
    
    private var tapGestureRecognizer: UITapGestureRecognizer!
    private var sideWidth: CGFloat = 0.0
    private var doublePi: CGFloat = CGFloat(M_PI) * 2.0
    
    override required public init(frame: CGRect) {
        super.init(frame: frame)
        initializeUI()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initializeUI()
    }
    
    func initializeUI() {
        sideWidth = min(frame.size.width, frame.size.height)
        backgroundColor = UIColor.white
        addSubLayer()
        tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(tapGestureRecognizerAction))
        addGestureRecognizer(tapGestureRecognizer)
    }
    
    public func setState(_ state: CNLCheckBoxState, animated: Bool) {
        if (self.state != state) || !animated {
            _state = state
            
            if let subLayers = borderCircle.sublayers {
                for subLayer in subLayers {
                    subLayer.removeFromSuperlayer()
                }
            }

            //updateLayers()
            startBorderLayerAnimation(animated: animated)
            startScaleBorderLayerAnimaiton(animated: animated)

            addSublayers(animated: animated)
        }
    }
    
    func addSubLayer() {
        borderCircle = CAShapeLayer()
        layer.addSublayer(borderCircle)
        
        centerCircle = CAShapeLayer()
        layer.addSublayer(centerCircle)
        
        updateLayers()
    }
    
    public func updateLayers() {
        let centerPoint = CGPoint(x: sideWidth / 2.0, y: sideWidth / 2.0)
        
        let borderCirclePath = UIBezierPath(
            arcCenter: centerPoint,
            radius: sideWidth / 2.0,
            startAngle: 0.0,
            endAngle: doublePi,
            clockwise: true
        )
        borderCircle.path = borderCirclePath.cgPath
        borderCircle.fillColor = currentBorderColor.cgColor
        
        let centerCirclePath = UIBezierPath(
            arcCenter: centerPoint,
            radius: sideWidth / 2.0 - currentBorderLineWidth,
            startAngle: 0.0,
            endAngle: doublePi,
            clockwise: true
        )
        centerCircle.path = centerCirclePath.cgPath
        centerCircle.fillColor = fillColor.cgColor
    }
    
    @objc public func tapGestureRecognizerAction() {
        if isUserInteractionEnabled {
            if stateSequenceIndex == (stateSequence.count - 1) {
                stateSequenceIndex = 0
            } else {
                stateSequenceIndex = stateSequenceIndex + 1
            }
            setState(stateSequence[stateSequenceIndex], animated: true)
        }
    }
    
    func startBorderLayerAnimation(animated: Bool) {
        if state == .empty {
            let finalPath = UIBezierPath(
                arcCenter: CGPoint(x: sideWidth / 2.0, y: sideWidth / 2.0),
                radius: sideWidth / 2.0 - currentBorderLineWidth,
                startAngle: 0.0,
                endAngle: doublePi,
                clockwise: true
                ).cgPath
            if animated {
                with(CABasicAnimation(keyPath: "path")) {
                    $0.fromValue = UIBezierPath(
                        arcCenter: CGPoint(x: sideWidth / 2.0, y: sideWidth / 2.0),
                        radius: 0.1,
                        startAngle: 0.0,
                        endAngle: doublePi,
                        clockwise: true
                        ).cgPath
                    $0.toValue = finalPath
                    $0.duration = animationDuration / 3.0 * 2.0
                    $0.isRemovedOnCompletion = false
                    $0.fillMode = kCAFillModeForwards
                    centerCircle.add($0, forKey: nil)
                }
            } else {
                centerCircle.path = finalPath
            }
        } else {
            let finalPath = UIBezierPath(
                arcCenter: CGPoint(x: sideWidth / 2.0, y: sideWidth / 2.0),
                radius: 0.1,
                startAngle: 0.0,
                endAngle: doublePi,
                clockwise: true
            ).cgPath
            if animated {
                with(CABasicAnimation(keyPath: "path")) {
                    $0.fromValue = UIBezierPath(
                        arcCenter: CGPoint(x: sideWidth / 2.0, y: sideWidth / 2.0),
                        radius: sideWidth / 2.0 - currentBorderLineWidth,
                        startAngle: 0.0,
                        endAngle: doublePi,
                        clockwise:true
                        ).cgPath
                    $0.toValue = finalPath
                    $0.duration = animationDuration / 3.0 * 2.0
                    $0.isRemovedOnCompletion = false
                    $0.fillMode = kCAFillModeForwards
                    centerCircle.add($0, forKey: nil)
                }
            } else {
                centerCircle.path = finalPath
            }
        }
        
        if animated {
            with(CABasicAnimation(keyPath: "fillColor")) {
                $0.toValue = currentBorderColor.cgColor
                $0.duration = animationDuration / 3.0 * 2.0
                $0.isRemovedOnCompletion = false
                $0.fillMode = kCAFillModeForwards
                borderCircle.add($0, forKey: nil)
            }
        } else {
            borderCircle.fillColor = currentBorderColor.cgColor
        }
    }
    
    func startScaleBorderLayerAnimaiton(animated: Bool) {
        
        var toValue = CATransform3DIdentity
        toValue = CATransform3DTranslate(toValue, bounds.size.width / 2.0, bounds.size.height / 2.0, 0.0)
        toValue = CATransform3DScale(toValue, 1.0, 1.0, 1.0)
        toValue = CATransform3DTranslate(toValue, -bounds.size.width/2, -bounds.size.height / 2.0, 0.0)
        
        if animated {
            var byValue = CATransform3DIdentity
            byValue = CATransform3DTranslate(byValue, bounds.size.width / 2.0, bounds.size.height / 2.0, 0.0)
            byValue = CATransform3DScale(byValue, 0.8, 0.8, 1.0)
            byValue = CATransform3DTranslate(byValue, -bounds.size.width / 2.0, -bounds.size.height / 2.0, 0.0)
            
            let firstScaleAnimation = with(CABasicAnimation(keyPath: "transform")) {
                $0.toValue = NSValue(caTransform3D: byValue)
                $0.duration = animationDuration / 2.0
                $0.isRemovedOnCompletion = false
                $0.fillMode = kCAFillModeForwards
            }
            
            let secondScaleAnimation = with(CABasicAnimation(keyPath: "transform")) {
                $0.toValue = NSValue(caTransform3D: toValue)
                $0.beginTime = animationDuration / 2.0
                $0.duration = animationDuration / 2.0
                $0.isRemovedOnCompletion = false
                $0.fillMode = kCAFillModeForwards
            }
            
            let scaleAnimationGroup = with(CAAnimationGroup()) {
                $0.animations = [firstScaleAnimation, secondScaleAnimation]
                $0.duration = animationDuration
            }
            borderCircle.add(scaleAnimationGroup, forKey: nil)
            centerCircle.add(scaleAnimationGroup, forKey: nil)
        } else {
            borderCircle.transform = toValue
            centerCircle.transform = toValue
        }
    }
    
    func addSublayers(animated: Bool) {
        switch state {
        case .tick:
            let unitLength = sideWidth / 30.0
            let beginPoint = CGPoint(x: unitLength * 7.0, y: unitLength * 14.0)
            let transitionPoint = CGPoint(x: unitLength * 13.0, y: unitLength * 20.0)
            let endPoint = CGPoint(x: unitLength * 22.0, y: unitLength * 10.0)
            
            let tickPath = with(UIBezierPath()) {
                $0.move(to: beginPoint)
                $0.addLine(to: transitionPoint)
                $0.addLine(to: endPoint)
            }
            
            let tickLayer = with(CAShapeLayer()) {
                $0.path = tickPath.cgPath
                $0.lineWidth = currentLineWidth
                $0.lineCap = kCALineCapRound
                $0.lineJoin = kCALineJoinRound
                $0.fillColor = UIColor.clear.cgColor
                $0.strokeColor = currentLineColor.cgColor
                $0.strokeEnd = 0.0
                borderCircle.addSublayer($0)
            }
            
            if animated {
                with(CABasicAnimation(keyPath: "strokeEnd")) {
                    $0.toValue = 1.0
                    $0.duration = animationDuration
                    $0.isRemovedOnCompletion = false
                    $0.fillMode = kCAFillModeForwards
                    tickLayer.add($0, forKey: nil)
                }
            } else {
                tickLayer.strokeEnd = 1.0
            }
            
        case .cross:
            let datumPoint = sideWidth / 3.0
            let point_TopLeft = CGPoint(x: datumPoint, y: datumPoint)
            let point_TopRight = CGPoint(x: 2.0 * datumPoint, y: datumPoint)
            let point_BottomLeft = CGPoint(x: datumPoint, y: 2.0 * datumPoint)
            let point_BottomRight = CGPoint(x: 2.0 * datumPoint, y: 2.0 * datumPoint)
            
            let tickLayer = with(CAShapeLayer()) {
                $0.path = with(UIBezierPath()) {
                    $0.move(to: point_TopLeft)
                    $0.addLine(to: point_BottomRight)
                    $0.move(to: point_TopRight)
                    $0.addLine(to: point_BottomLeft)
                }.cgPath
                $0.lineWidth = currentLineWidth
                $0.lineCap = kCALineCapRound
                $0.lineJoin = kCALineJoinRound
                $0.fillColor = UIColor.clear.cgColor
                $0.strokeColor = currentLineColor.cgColor
                $0.strokeEnd = 0.0
                borderCircle.addSublayer($0)
            }
            
            if animated {
                with(CABasicAnimation(keyPath: "strokeEnd")) {
                    $0.toValue = 1.0
                    $0.duration = animationDuration
                    $0.isRemovedOnCompletion = false
                    $0.fillMode = kCAFillModeForwards
                    tickLayer.add($0, forKey: nil)
                }
            } else {
                tickLayer.strokeEnd = 1.0
            }
        default: break
        }
    }
    
}
