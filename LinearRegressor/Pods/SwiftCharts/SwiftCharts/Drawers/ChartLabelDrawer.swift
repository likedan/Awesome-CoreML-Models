//
//  ChartLabelDrawer.swift
//  SwiftCharts
//
//  Created by ischuetz on 25/04/15.
//  Copyright (c) 2015 ivanschuetz. All rights reserved.
//

import UIKit

public enum ChartLabelTextAlignment {
    case left, right, `default`
}

public struct ChartLabelSettings {
    public var font: UIFont
    public var fontColor: UIColor
    public var rotation: CGFloat
    public var rotationKeep: ChartLabelDrawerRotationKeep
    public var shiftXOnRotation: Bool
    public var textAlignment: ChartLabelTextAlignment
    
    public init(font: UIFont = UIFont.systemFont(ofSize: 14), fontColor: UIColor = UIColor.black, rotation: CGFloat = 0, rotationKeep: ChartLabelDrawerRotationKeep = .center, shiftXOnRotation: Bool = true, textAlignment: ChartLabelTextAlignment = .default) {
        self.font = font
        self.fontColor = fontColor
        self.rotation = rotation
        self.rotationKeep = rotationKeep
        self.shiftXOnRotation = shiftXOnRotation
        self.textAlignment = textAlignment
    }
}

public extension ChartLabelSettings {
    public func defaultVertical() -> ChartLabelSettings {
        var copy = self
        copy.rotation = -90
        
        return copy
    }
}

extension ChartLabelSettings: CustomDebugStringConvertible {
    public var debugDescription: String {
        return [
            "font": font,
            "fontColor": fontColor,
            "rotation": rotation,
            "rotationKeep": rotationKeep,
            "shiftXOnRotation": shiftXOnRotation,
            "textAlignment": textAlignment
            ]
                .debugDescription
    }
}

// coordinate of original label which will be preserved after the rotation
public enum ChartLabelDrawerRotationKeep {
    case center, top, bottom
}

open class ChartLabelDrawer: ChartContextDrawer {
    
    open var screenLoc: CGPoint
    open var transform: CGAffineTransform?    
    open let label: ChartAxisLabel
    
    open var center: CGPoint {
        return CGPoint(x: screenLoc.x + size.width / 2, y: screenLoc.y + size.height / 2)
    }
    
    open var size: CGSize {
        return label.textSizeNonRotated
    }
    
    open var frame: CGRect {
        return CGRect(x: screenLoc.x, y: screenLoc.y, width: size.width, height: size.height)
    }
    
    public init(label: ChartAxisLabel, screenLoc: CGPoint) {
        self.label = label
        self.screenLoc = screenLoc
        
        super.init()
        
        self.transform = self.transform(screenLoc, settings: label.settings)
    }

    override open func draw(context: CGContext, chart: Chart) {
        let labelSize = size
        
        let labelX = screenLoc.x
        let labelY = screenLoc.y
        
        func drawLabel() {
            self.drawLabel(x: labelX, y: labelY, text: label.text)
        }
        
        if let transform = transform {
            context.saveGState()
            context.concatenate(transform)
            drawLabel()
            context.restoreGState()

        } else {
            drawLabel()
        }
    }
    
    fileprivate func transform(_ screenLoc: CGPoint, settings: ChartLabelSettings) -> CGAffineTransform? {
        let labelSize = size
        
        let labelX = screenLoc.x
        let labelY = screenLoc.y
        
        let labelHalfWidth = labelSize.width / 2
        let labelHalfHeight = labelSize.height / 2
        
        if settings.rotation != 0 {

            let centerX = labelX + labelHalfWidth
            let centerY = labelY + labelHalfHeight
            
            let rotation = settings.rotation * CGFloat.pi / 180

            var transform = CGAffineTransform.identity
            
            if settings.rotationKeep == .center {
                transform = CGAffineTransform(translationX: -(labelHalfWidth - labelHalfHeight), y: 0)
                
            } else {
                
                var transformToGetBounds = CGAffineTransform(translationX: 0, y: 0)
                transformToGetBounds = transformToGetBounds.translatedBy(x: centerX, y: centerY)
                transformToGetBounds = transformToGetBounds.rotated(by: rotation)
                transformToGetBounds = transformToGetBounds.translatedBy(x: -centerX, y: -centerY)
                let rect = CGRect(x: labelX, y: labelY, width: labelSize.width, height: labelSize.height)
                let newRect = rect.applying(transformToGetBounds)

                let offsetTop: CGFloat = {
                    switch settings.rotationKeep {
                    case .top:
                        return labelY - newRect.origin.y
                    case .bottom:
                        return newRect.origin.y + newRect.size.height - (labelY + rect.size.height)
                    default:
                        return 0
                    }
                }()
                
                // when the labels are diagonal we have to shift a little so they look aligned with axis value. We align origin of new rect with the axis value
                if settings.shiftXOnRotation {
                    let xOffset: CGFloat = abs(settings.rotation) =~ 90 ? 0 : centerX - newRect.origin.x
                    transform = transform.translatedBy(x: xOffset, y: offsetTop)
                }
            }

            transform = transform.translatedBy(x: centerX, y: centerY)
            transform = transform.rotated(by: rotation)
            transform = transform.translatedBy(x: -centerX, y: -centerY)
            return transform
            
        } else {
            return nil
        }
    }

    
    fileprivate func drawLabel(x: CGFloat, y: CGFloat, text: String) {
        #if swift(>=4)
        let attributes = [NSAttributedStringKey.font: label.settings.font, NSAttributedStringKey.foregroundColor: label.settings.fontColor]
        #else
        let attributes = [NSFontAttributeName: label.settings.font, NSForegroundColorAttributeName: label.settings.fontColor]
        #endif
        let attrStr = NSAttributedString(string: text, attributes: attributes)
        attrStr.draw(at: CGPoint(x: x, y: y))
    }
}
