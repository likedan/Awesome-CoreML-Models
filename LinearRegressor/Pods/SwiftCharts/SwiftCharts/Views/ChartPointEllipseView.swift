//
//  ChartPointEllipseView.swift
//  SwiftCharts
//
//  Created by ischuetz on 19/04/15.
//  Copyright (c) 2015 ivanschuetz. All rights reserved.
//

import UIKit

open class ChartPointEllipseView: UIView {
    
    open var fillColor: UIColor = UIColor.gray
    open var borderColor: UIColor? = nil
    open var borderWidth: CGFloat? = nil
    open var animDelay: Float = 0
    open var animDuration: Float = 0
    open var animateSize: Bool = true
    open var animateAlpha: Bool = true
    open var animDamping: CGFloat = 1
    open var animInitSpringVelocity: CGFloat = 1
    
    open var touchHandler: (() -> ())?

    convenience public init(center: CGPoint, diameter: CGFloat) {
        self.init(center: center, width: diameter, height: diameter)
    }
    
    public init(center: CGPoint, width: CGFloat, height: CGFloat) {
        super.init(frame: CGRect(x: center.x - width / 2, y: center.y - height / 2, width: width, height: height))
        self.backgroundColor = UIColor.clear
    }

    required public init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
   
    override open func didMoveToSuperview() {
        if animDuration != 0 {
            if animateSize {
                transform = CGAffineTransform(scaleX: 0.1, y: 0.1)
            }
            if animateAlpha {
                alpha = 0
            }
            
            UIView.animate(withDuration: TimeInterval(animDuration), delay: TimeInterval(animDelay), usingSpringWithDamping: animDamping, initialSpringVelocity: animInitSpringVelocity, options: UIViewAnimationOptions(), animations: {
                if self.animateSize {
                    self.transform = CGAffineTransform(scaleX: 1, y: 1)
                }
                if self.animateAlpha {
                    self.alpha = 1
                }
            }, completion: nil)
        }
    }
    
    override open func draw(_ rect: CGRect) {
        guard let context = UIGraphicsGetCurrentContext() else {return}

        let borderOffset = borderWidth ?? 0
        let circleRect = (CGRect(x: borderOffset, y: borderOffset, width: frame.size.width - (borderOffset * 2), height: frame.size.height - (borderOffset * 2)))
        
        if let borderWidth = borderWidth, let borderColor = borderColor {
            context.setLineWidth(borderWidth)
            context.setStrokeColor(borderColor.cgColor)
            context.strokeEllipse(in: circleRect)
        }
        context.setFillColor(fillColor.cgColor)
        context.fillEllipse(in: circleRect)
    }
    
    override open func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        touchHandler?()
    }
}
