//
//  InfoBubble.swift
//  SwiftCharts
//
//  Created by ischuetz on 11/04/15.
//  Copyright (c) 2015 ivanschuetz. All rights reserved.
//

import UIKit

open class InfoBubble: UIView {

    open let arrowWidth: CGFloat
    open let arrowHeight: CGFloat
    open let bgColor: UIColor
    open let arrowX: CGFloat
    open let arrowY: CGFloat
    
    fileprivate let contentView: UIView?
    
    open let minSuperviewPadding: CGFloat
    open let space: CGFloat
    
    open let point: CGPoint
    
    open var tapHandler: (() -> Void)?

    open var inverted: Bool {
        return superview.map{inverted($0)} ?? false
    }

    open let horizontal: Bool
    
    public convenience init(point: CGPoint, size: CGSize, superview: UIView, arrowHeight: CGFloat = 15, contentView: UIView, bgColor: UIColor = UIColor.gray, minSuperviewPadding: CGFloat = 2, space: CGFloat = 12, horizontal: Bool = false) {
        
        let w: CGFloat = size.width + (horizontal ? arrowHeight : 0)
        let h: CGFloat = size.height + (!horizontal ? arrowHeight : 0)
        
        let x = horizontal ? point.x : min(max(superview.bounds.minX + minSuperviewPadding, point.x - w / 2), superview.bounds.maxX - w - minSuperviewPadding) // align with center and move rect to fit in available horizontal space
        let y = horizontal ? min(max(0 + minSuperviewPadding, point.y - h / 2), superview.bounds.maxY - h - minSuperviewPadding) : point.y // align with center and move rect to fit in available vertical space
        
        let frame: CGRect = {
            if !horizontal {
                return point.y < h ? CGRect(x: x, y: point.y + space, width: w, height: h) : CGRect(x: x, y: point.y - (h + space), width: w, height: h)
            } else {
                return point.x < superview.frame.width - w - space ? CGRect(x: x + space, y: y, width: w, height: h) : CGRect(x: x - (w + space), y: y, width: w, height: h)
            }
        }()
   
        self.init(point: point, frame: frame, arrowWidth: 15, arrowHeight: arrowHeight, contentView: contentView, bgColor: bgColor, arrowX: point.x - x, arrowY: point.y - y, horizontal: horizontal)
    }
    
    public init(point: CGPoint, frame: CGRect, arrowWidth: CGFloat, arrowHeight: CGFloat, contentView: UIView? = nil, bgColor: UIColor = UIColor.white, space: CGFloat = 12, minSuperviewPadding: CGFloat = 2, arrowX: CGFloat, arrowY: CGFloat, horizontal: Bool = false) {
        self.point = point
        self.arrowWidth = arrowWidth
        self.arrowHeight = arrowHeight
        self.bgColor = bgColor
        self.space = space
        self.minSuperviewPadding = minSuperviewPadding
        self.horizontal = horizontal
        
        let arrowHalf = arrowWidth / 2
        self.arrowX = max(arrowHalf, min(frame.size.width - arrowHalf, arrowX))
        self.arrowY = max(arrowHalf, min(frame.size.height - arrowHalf, arrowY))
        
        self.contentView = contentView
        
        super.init(frame: frame)
        backgroundColor = UIColor.clear
        
        let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(onTap))
        addGestureRecognizer(tapRecognizer)
    }
    
    @objc func onTap(_ sender: UITapGestureRecognizer) {
        tapHandler?()
    }
    
    open override func didMoveToSuperview() {
        if let contentView = contentView {
            contentView.center = horizontal ? bounds.center.offset(x: inverted ? -arrowHeight / 2 : arrowHeight / 2) : bounds.center.offset(y: inverted ? arrowHeight / 2 : -arrowHeight / 2)
            addSubview(contentView)
        }
    }

    open func inverted(_ superview: UIView) -> Bool {
        return horizontal ? point.x > superview.frame.width - frame.width - space : point.y < bounds.size.height
    }
    
    required public init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override open func draw(_ rect: CGRect) {
        guard let context = UIGraphicsGetCurrentContext() else {return}
        context.setFillColor(bgColor.cgColor)
        context.setStrokeColor(bgColor.cgColor)
        
        let rrect = horizontal ? rect.insetBy(dx: inverted ? 0 : arrowHeight, dw: inverted ? arrowHeight : 0) : rect.insetBy(dy: inverted ? arrowHeight : 0, dh: inverted ? 0 : arrowHeight)
        
        let minx = rrect.minX, maxx = rrect.maxX
        let miny = rrect.minY, maxy = rrect.maxY
        
        let outlinePath = CGMutablePath()

        outlinePath.move(to: CGPoint(x: minx, y: miny))
        outlinePath.addLine(to: CGPoint(x: maxx, y: miny))
        outlinePath.addLine(to: CGPoint(x: maxx, y: maxy))
        outlinePath.addLine(to: CGPoint(x: minx, y: maxy))
        outlinePath.closeSubpath()
        context.addPath(outlinePath)

        let arrowPath = CGMutablePath()
        
        if inverted {
            
            if horizontal {
                arrowPath.move(to: CGPoint(x: maxx, y: arrowY - arrowWidth / 2))
                arrowPath.addLine(to: CGPoint(x: maxx + arrowHeight, y: arrowY))
                arrowPath.addLine(to: CGPoint(x: maxx, y: arrowY + arrowWidth / 2))
                
            } else {
                arrowPath.move(to: CGPoint(x: arrowX - arrowWidth / 2, y: miny))
                arrowPath.addLine(to: CGPoint(x: arrowX, y: miny - arrowHeight))
                arrowPath.addLine(to: CGPoint(x: arrowX + arrowWidth / 2, y: miny))
            }

        } else {
            
            if horizontal {
                arrowPath.move(to: CGPoint(x: minx, y: arrowY - arrowWidth / 2))
                arrowPath.addLine(to: CGPoint(x: minx - arrowHeight, y: arrowY))
                arrowPath.addLine(to: CGPoint(x: minx, y: arrowY + arrowWidth / 2))

            } else {
                arrowPath.move(to: CGPoint(x: arrowX + arrowWidth / 2, y: maxy))
                arrowPath.addLine(to: CGPoint(x: arrowX, y: maxy + arrowHeight))
                arrowPath.addLine(to: CGPoint(x: arrowX - arrowWidth / 2, y: maxy))
            }
        }
        
        arrowPath.closeSubpath()
        context.addPath(arrowPath)
        
        context.fillPath()
    }
}


extension InfoBubble {
    
    public convenience init(point: CGPoint, preferredSize: CGSize, superview: UIView, arrowHeight: CGFloat = 15, text: String, font: UIFont, textColor: UIColor, bgColor: UIColor = UIColor.gray, minSuperviewPadding: CGFloat = 2, innerPadding: CGFloat = 4, horizontal: Bool = false) {
        let label = UILabel()
        label.text = text
        label.font = font
        label.textColor = textColor
        label.sizeToFit()
        
        let size = CGSize(width: max(preferredSize.width, label.frame.width + innerPadding * 2), height: max(preferredSize.height, label.frame.height + innerPadding * 2))
        
        self.init(point: point, size: size, superview: superview, arrowHeight: arrowHeight, contentView: label, bgColor: bgColor, horizontal: horizontal)
    }
}
