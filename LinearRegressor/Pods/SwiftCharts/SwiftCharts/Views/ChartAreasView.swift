//
//  ChartAreasView.swift
//  swift_charts
//
//  Created by ischuetz on 18/04/15.
//  Copyright (c) 2015 ivanschuetz. All rights reserved.
//

import UIKit

open class ChartAreasView: UIView {

    fileprivate let animDuration: Float
    fileprivate let colors: [UIColor]
    fileprivate let animDelay: Float
    
    public init(points: [CGPoint], frame: CGRect, colors: [UIColor], animDuration: Float, animDelay: Float) {
        self.colors = colors
        self.animDuration = animDuration
        self.animDelay = animDelay
        
        super.init(frame: frame)

        backgroundColor = UIColor.clear
        show(path: generateAreaPath(points: points))
    }
    
    required public init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    fileprivate func generateAreaPath(points: [CGPoint]) -> UIBezierPath {
        
        let progressline = UIBezierPath()
        progressline.lineWidth = 1.0
        progressline.lineCapStyle = .round
        progressline.lineJoinStyle = .round
        
        if let p = points.first {
            progressline.move(to: p)
        }
        
        for i in 1..<points.count {
            let p = points[i]
            progressline.addLine(to: p)
        }
        
        progressline.close()
        
        return progressline
    }
    
    fileprivate func show(path: UIBezierPath) {
        guard let firstColor = colors.first else {
            print("WARNING: No color(s) used for ChartAreasView")
            return
        }
        let areaLayer = CAShapeLayer()
        areaLayer.lineJoin = kCALineJoinBevel
        areaLayer.fillColor   = firstColor.cgColor
        areaLayer.lineWidth   = 2.0
        areaLayer.strokeEnd   = 0.0
        if colors.count == 1 {
            layer.addSublayer(areaLayer)
        }
        
        areaLayer.path = path.cgPath
        areaLayer.strokeColor = firstColor.cgColor
        
        if colors.count > 1 {
            let gradient = CAGradientLayer()
            gradient.anchorPoint = CGPoint.zero
            var CGColors: [CGColor] = []
            for color in colors {
                CGColors.append(color.cgColor)
            }
            gradient.colors = CGColors
            gradient.bounds = layer.bounds
            
            let pathY = path.bounds.origin.y
            let pathHeight = path.bounds.height
            let maskHeight = gradient.bounds.height
        
            var bottomY: CGFloat?
            var topY: CGFloat?
            if pathY < pathHeight {
                bottomY = (pathY/pathHeight)/2
                topY = ((maskHeight - (pathHeight-pathY))/maskHeight)/2
            } else {
                bottomY = 0
                topY = ((maskHeight-pathHeight)/maskHeight)
            }
            
            gradient.startPoint = CGPoint(x: 0.5, y: 0+topY!)
            gradient.endPoint = CGPoint(x: 0.5, y: 1.0-bottomY!)
            gradient.mask = areaLayer
            layer.addSublayer(gradient)
        }
        
        if animDuration > 0 {
            let maskLayer = CAGradientLayer()
            maskLayer.anchorPoint = CGPoint.zero
            
            let colors = [
                UIColor(white: 0, alpha: 0).cgColor,
                UIColor(white: 0, alpha: 1).cgColor]
            maskLayer.colors = colors
            maskLayer.bounds = CGRect(x: 0, y: 0, width: 0, height: layer.bounds.size.height)
            maskLayer.startPoint = CGPoint(x: 1, y: 0)
            maskLayer.endPoint = CGPoint(x: 0, y: 0)
            layer.mask = maskLayer
        
            let revealAnimation = CABasicAnimation(keyPath: "bounds")
            revealAnimation.fromValue = NSValue(cgRect: CGRect(x: 0, y: 0, width: 0, height: layer.bounds.size.height))
            
            let target = CGRect(x: layer.bounds.origin.x, y: layer.bounds.origin.y, width: layer.bounds.size.width + 2000, height: layer.bounds.size.height)
            
            revealAnimation.toValue = NSValue(cgRect: target)
            revealAnimation.duration = CFTimeInterval(animDuration)
            
            revealAnimation.isRemovedOnCompletion = false
            revealAnimation.fillMode = kCAFillModeForwards
            
            revealAnimation.beginTime = CACurrentMediaTime() + CFTimeInterval(animDelay)
            layer.mask?.add(revealAnimation, forKey: "revealAnimation")
        }
    }
}
