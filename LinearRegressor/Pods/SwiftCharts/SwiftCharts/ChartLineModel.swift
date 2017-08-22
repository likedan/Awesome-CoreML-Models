//
//  ChartLineModel.swift
//  swift_charts
//
//  Created by ischuetz on 11/04/15.
//  Copyright (c) 2015 ivanschuetz. All rights reserved.
//

import UIKit

/// Models a line to be drawn in a chart based on an array of chart points.
public struct ChartLineModel<T: ChartPoint> {

    /// The array of chart points that the line should be drawn with. In a simple case this would be drawn as straight line segments connecting each point.
    public let chartPoints: [T]

    /// The color that the line is drawn with
    public let lineColor: UIColor

    /// The width of the line in points
    public let lineWidth: CGFloat
    
    public let lineJoin: LineJoin
    
    public let lineCap: LineCap
    
    /// The duration in seconds of the animation that is run when the line appears
    public let animDuration: Float

    /// The delay in seconds before the animation runs
    public let animDelay: Float
    
    /// The dash pattern for the line
    public let dashPattern: [Double]?
    
    public init(chartPoints: [T], lineColor: UIColor, lineWidth: CGFloat = 1, lineJoin: LineJoin = .round, lineCap: LineCap = .round, animDuration: Float, animDelay: Float, dashPattern: [Double]? = nil) {
        self.chartPoints = chartPoints
        self.lineColor = lineColor
        self.lineWidth = lineWidth
        self.lineJoin = lineJoin
        self.lineCap = lineCap
        self.animDuration = animDuration
        self.animDelay = animDelay
        self.dashPattern = dashPattern
    }

    /// The number of chart points in the model
    var chartPointsCount: Int {
        return chartPoints.count
    }
    
}
