//
//  ChartLineDrawer.swift
//  SwiftCharts
//
//  Created by ischuetz on 25/04/15.
//  Copyright (c) 2015 ivanschuetz. All rights reserved.
//

import UIKit

class ChartLineDrawer: ChartContextDrawer {
    fileprivate let p1: CGPoint
    fileprivate let p2: CGPoint
    fileprivate let color: UIColor
    fileprivate let strokeWidth: CGFloat
    
    init(p1: CGPoint, p2: CGPoint, color: UIColor, strokeWidth: CGFloat = 0.2) {
        self.p1 = p1
        self.p2 = p2
        self.color = color
        self.strokeWidth = strokeWidth
    }

    override func draw(context: CGContext, chart: Chart) {
        ChartDrawLine(context: context, p1: p1, p2: p2, width: strokeWidth, color: color)
    }
}
