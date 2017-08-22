//
//  StraigthLinePathGenerator.swift
//  SwiftCharts
//
//  Created by ischuetz on 28/04/15.
//  Copyright (c) 2015 ivanschuetz. All rights reserved.
//

import UIKit

open class StraightLinePathGenerator: ChartLinesViewPathGenerator {
    
    public init() {}
    
    open func generatePath(points: [CGPoint], lineWidth: CGFloat) -> UIBezierPath {

        let progressline = UIBezierPath()
      
        if points.count >= 2 {

            progressline.lineWidth = lineWidth
            progressline.lineCapStyle = .round
            progressline.lineJoinStyle = .round
        
            for i in 0..<(points.count - 1) {
                let p1 = points[i]
                let p2 = points[i + 1]
            
                progressline.move(to: p1)
                progressline.addLine(to: p2)
            }
        }

        return progressline
    }
}
