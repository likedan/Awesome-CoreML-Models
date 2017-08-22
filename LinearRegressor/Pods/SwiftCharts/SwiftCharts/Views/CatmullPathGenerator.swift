//
//  CatmullPathGenerator.swift
//  SwiftCharts
//
//  Created by ischuetz on 22/09/16.
//  Copyright © 2016 ivanschuetz. All rights reserved.
//

import UIKit

open class CatmullPathGenerator: ChartLinesViewPathGenerator {
    
    public init() {}
    
    open func generatePath(points: [CGPoint], lineWidth: CGFloat) -> UIBezierPath {
        guard let last = points.last else {return UIBezierPath()}
        return UIBezierPath(catmullRomPoints: points + [last.offset(x: 1)], alpha: 0.5) ?? CubicLinePathGenerator(tension1: 0.2, tension2: 0.2).generatePath(points: points, lineWidth: lineWidth)
    }
}

// src: https://github.com/andrelind/swift-catmullrom/blob/master/CatmullRom.swift (modified)
private extension UIBezierPath {
    
    convenience init?(catmullRomPoints: [CGPoint], alpha: CGFloat) {
        self.init()
        
        if catmullRomPoints.count < 4 {
            return nil
        }
        
        let startIndex = 0
        let endIndex = catmullRomPoints.count - 2
        
        for i in startIndex ..< endIndex {
            let prevIndex = i - 1 < 0 ? catmullRomPoints.count - 1 : i - 1
            let nextIndex = i + 1 % catmullRomPoints.count
            let nextNextIndex = nextIndex + 1 % catmullRomPoints.count
            
            let p0 = catmullRomPoints[prevIndex]
            let p1 = catmullRomPoints[i]
            let p2 = catmullRomPoints[nextIndex]
            let p3 = catmullRomPoints[nextNextIndex]

            let d1 = p1.substract(p0).length()
            let d2 = p2.substract(p1).length()
            let d3 = p3.substract(p2).length()
            
            var b1 = p2.multiplyBy(pow(d1, 2 * alpha))
            b1 = b1.substract(p0.multiplyBy(pow(d2, 2 * alpha)))
            b1 = b1.add(p1.multiplyBy(2 * pow(d1, 2 * alpha) + 3 * pow(d1, alpha) * pow(d2, alpha) + pow(d2, 2 * alpha)))
            b1 = b1.multiplyBy(1.0 / (3 * pow(d1, alpha) * (pow(d1, alpha) + pow(d2, alpha))))
            
            var b2 = p1.multiplyBy(pow(d3, 2 * alpha))
            b2 = b2.substract(p3.multiplyBy(pow(d2, 2 * alpha)))
            b2 = b2.add(p2.multiplyBy(2 * pow(d3, 2 * alpha) + 3 * pow(d3, alpha) * pow(d2, alpha) + pow(d2, 2 * alpha)))
            b2 = b2.multiplyBy(1.0 / (3 * pow(d3, alpha) * (pow(d3, alpha) + pow(d2, alpha))))
            
            if i == startIndex {
                move(to: p1)
            }
            
            addCurve(to: p2, controlPoint1: b1, controlPoint2: b2)
        }
    }
}