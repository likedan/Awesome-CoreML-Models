//
//  CubicLinePathGenerator.swift
//  SwiftCharts
//
//  Created by ischuetz on 28/04/15.
//  Copyright (c) 2015 ivanschuetz. All rights reserved.
//

import UIKit

open class CubicLinePathGenerator: ChartLinesViewPathGenerator {
    
    fileprivate let tension1: CGFloat
    fileprivate let tension2: CGFloat
    
    /**
    - parameter tension1: p1 tension, where 0 is straight line. A value higher than 0.3 is not recommended.
    - parameter tension2: p2 tension, where 0 is straight line. A value higher than 0.3 is not recommended.
    */
    public init(tension1: CGFloat, tension2: CGFloat) {
        self.tension1 = tension1
        self.tension2 = tension2
    }
    
    // src: http://stackoverflow.com/a/29876400/930450 (modified)
    open func generatePath(points: [CGPoint], lineWidth: CGFloat) -> UIBezierPath {
        
        let path = UIBezierPath()
        
        guard !points.isEmpty else {return path}
        
        var p0: CGPoint
        var p1: CGPoint
        var p2: CGPoint
        var p3: CGPoint
        var tensionBezier1: CGFloat
        var tensionBezier2: CGFloat
        
        path.lineCapStyle = .round
        path.lineJoinStyle = .round
        
        var previousPoint1: CGPoint = CGPoint.zero
        
        path.move(to: points.first!)
        
        for i in 0..<(points.count - 1) {
            p1 = points[i]
            p2 = points[i + 1]
            
            tensionBezier1 = tension1
            tensionBezier2 = tension2
            
            if i > 0 {  // Exception for first line because there is no previous point
                p0 = previousPoint1
                
                if p2.y - p1.y =~ p2.y - p0.y {
                    tensionBezier1 = 0
                }
                
            } else {
                tensionBezier1 = 0
                p0 = p1
            }
            
            if i < points.count - 2 { // Exception for last line because there is no next point
                p3 = points[i + 2]
                if p3.y - p2.y =~ p2.y - p1.y {
                    tensionBezier2 = 0
                }
            } else {
                p3 = p2
                tensionBezier2 = 0
            }

            let controlPoint1 = CGPoint(x: p1.x + (p2.x - p1.x) / 3, y: p1.y - (p1.y - p2.y) / 3 - (p0.y - p1.y) * tensionBezier1)
            let controlPoint2 = CGPoint(x: p1.x + 2 * (p2.x - p1.x) / 3, y: (p1.y - 2 * (p1.y - p2.y) / 3) + (p2.y - p3.y) * tensionBezier2)
            
            path.addCurve(to: p2, controlPoint1: controlPoint1, controlPoint2: controlPoint2)
            
            previousPoint1 = p1;
        }
        
        return path
    }
}
