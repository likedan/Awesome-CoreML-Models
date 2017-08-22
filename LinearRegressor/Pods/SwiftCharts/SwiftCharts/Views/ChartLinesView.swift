//
//  ChartLinesView.swift
//  swift_charts
//
//  Created by ischuetz on 11/04/15.
//  Copyright (c) 2015 ivanschuetz. All rights reserved.
//

import UIKit

public protocol ChartLinesViewPathGenerator {
    func generatePath(points: [CGPoint], lineWidth: CGFloat) -> UIBezierPath
}

open class ChartLinesView: UIView {

    open let lineColor: UIColor
    open let lineWidth: CGFloat
    open let lineJoin: LineJoin
    open let lineCap: LineCap
    open let animDuration: Float
    open let animDelay: Float
    open let dashPattern: [Double]?
    
    public init(path: UIBezierPath, frame: CGRect, lineColor: UIColor, lineWidth: CGFloat, lineJoin: LineJoin, lineCap: LineCap, animDuration: Float, animDelay: Float, dashPattern: [Double]?) {
        self.lineColor = lineColor
        self.lineWidth = lineWidth
        self.lineJoin = lineJoin
        self.lineCap = lineCap
        self.animDuration = animDuration
        self.animDelay = animDelay
        self.dashPattern = dashPattern
        
        super.init(frame: frame)

        backgroundColor = UIColor.clear
        show(path: path)
    }

    required public init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    fileprivate func createLineMask(frame: CGRect) -> CALayer {
        let lineMaskLayer = CAShapeLayer()
        var maskRect = frame
        maskRect.origin.y = 0
        maskRect.size.height = frame.size.height
        let path = CGPath(rect: maskRect, transform: nil)
        
        lineMaskLayer.path = path
        
        return lineMaskLayer
    }

    open func generateLayer(path: UIBezierPath) -> CAShapeLayer {
        let lineLayer = CAShapeLayer()
        lineLayer.lineJoin = lineJoin.CALayerString
        lineLayer.lineCap = lineCap.CALayerString
        lineLayer.fillColor = UIColor.clear.cgColor
        lineLayer.lineWidth = lineWidth
        
        lineLayer.path = path.cgPath
        lineLayer.strokeColor = lineColor.cgColor
        
        if dashPattern != nil {
            lineLayer.lineDashPattern = dashPattern as [NSNumber]?
        }
        
        if animDuration > 0 {
            lineLayer.strokeEnd = 0.0
            let pathAnimation = CABasicAnimation(keyPath: "strokeEnd")
            pathAnimation.duration = CFTimeInterval(animDuration)
            pathAnimation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
            pathAnimation.fromValue = NSNumber(value: 0 as Float)
            pathAnimation.toValue = NSNumber(value: 1 as Float)
            pathAnimation.autoreverses = false
            pathAnimation.isRemovedOnCompletion = false
            pathAnimation.fillMode = kCAFillModeForwards
            
            pathAnimation.beginTime = CACurrentMediaTime() + CFTimeInterval(animDelay)
            lineLayer.add(pathAnimation, forKey: "strokeEndAnimation")
            
        } else {
            lineLayer.strokeEnd = 1
        }
        
        return lineLayer
    }
    
    fileprivate func show(path: UIBezierPath) {
        layer.addSublayer(generateLayer(path: path))
    }
 }
