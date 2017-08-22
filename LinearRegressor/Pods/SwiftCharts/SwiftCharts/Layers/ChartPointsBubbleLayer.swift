//
//  ChartPointsBubbleLayer.swift
//  Examples
//
//  Created by ischuetz on 16/05/15.
//  Copyright (c) 2015 ivanschuetz. All rights reserved.
//

import UIKit

open class ChartPointsBubbleLayer<T: ChartPointBubble>: ChartPointsLayer<T> {
    
    fileprivate let diameterFactor: Double
    
    public init(xAxis: ChartAxis, yAxis: ChartAxis, chartPoints: [T], displayDelay: Float = 0, maxBubbleDiameter: Double = 30, minBubbleDiameter: Double = 2) {
        
        let (minDiameterScalar, maxDiameterScalar): (Double, Double) = chartPoints.reduce((min: 0, max: 0)) {tuple, chartPoint in
            (min: min(tuple.min, chartPoint.diameterScalar), max: max(tuple.max, chartPoint.diameterScalar))
        }
        
        diameterFactor = (maxBubbleDiameter - minBubbleDiameter) / (maxDiameterScalar - minDiameterScalar)

        super.init(xAxis: xAxis, yAxis: yAxis, chartPoints: chartPoints, displayDelay: displayDelay)
    }
    
    override open func chartViewDrawing(context: CGContext, chart: Chart) {

        for chartPointModel in chartPointsModels {

            context.setLineWidth(1.0)
            context.setStrokeColor(chartPointModel.chartPoint.borderColor.cgColor)
            context.setFillColor(chartPointModel.chartPoint.bgColor.cgColor)
            
            let diameter = CGFloat(chartPointModel.chartPoint.diameterScalar * diameterFactor)
            let circleRect = (CGRect(x: chartPointModel.screenLoc.x - diameter / 2, y: chartPointModel.screenLoc.y - diameter / 2, width: diameter, height: diameter))
            
            context.fillEllipse(in: circleRect)
            context.strokeEllipse(in: circleRect)
        }
    }
}
