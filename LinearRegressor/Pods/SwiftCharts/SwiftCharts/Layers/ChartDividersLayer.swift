//
//  ChartDividersLayer.swift
//  SwiftCharts
//
//  Created by ischuetz on 21/04/15.
//  Copyright (c) 2015 ivanschuetz. All rights reserved.
//

import UIKit

public struct ChartDividersLayerSettings {
    let linesColor: UIColor
    let linesWidth: CGFloat
    let start: CGFloat // Points from start to axis, axis is 0
    let end: CGFloat // Points from axis to end, axis is 0
    let show: ((Double) -> Bool)? // Set visibility of individual axis values. If nil, all axis values will be shown.
    
    public init(linesColor: UIColor = UIColor.gray, linesWidth: CGFloat = 0.3, start: CGFloat = 5, end: CGFloat = 5, show: ((Double) -> Bool)? = nil) {
        self.linesColor = linesColor
        self.linesWidth = linesWidth
        self.start = start
        self.end = end
        self.show = show
    }
}

public enum ChartDividersLayerAxis {
    case x, y, xAndY
}

open class ChartDividersLayer: ChartCoordsSpaceLayer {
    
    fileprivate let settings: ChartDividersLayerSettings
    
    let axis: ChartDividersLayerAxis

    fileprivate let xAxisLayer: ChartAxisLayer
    fileprivate let yAxisLayer: ChartAxisLayer
    
    public init(xAxisLayer: ChartAxisLayer, yAxisLayer: ChartAxisLayer, axis: ChartDividersLayerAxis = .xAndY, settings: ChartDividersLayerSettings) {
        self.axis = axis
        self.settings = settings
        
        self.xAxisLayer = xAxisLayer
        self.yAxisLayer = yAxisLayer

        super.init(xAxis: xAxisLayer.axis, yAxis: yAxisLayer.axis)
    }
    
    fileprivate func drawLine(context: CGContext, color: UIColor, width: CGFloat, p1: CGPoint, p2: CGPoint) {
        ChartDrawLine(context: context, p1: p1, p2: p2, width: width, color: color)
    }
    
    override open func chartViewDrawing(context: CGContext, chart: Chart) {
        let xValues = xAxisLayer.currentAxisValues
        let yValues = yAxisLayer.currentAxisValues
        
        if axis == .x || axis == .xAndY {
            for xValue in xValues {
                guard (settings.show?(xValue) ?? true) else {continue}
                
                let xScreenLoc = xAxisLayer.axis.screenLocForScalar(xValue)
                
                let x1 = xScreenLoc
                let y1 = xAxisLayer.lineP1.y + (xAxisLayer.low ? -settings.end : settings.end)
                let x2 = xScreenLoc
                let y2 = xAxisLayer.lineP1.y + (xAxisLayer.low ? settings.start : -settings.start)
                drawLine(context: context, color: settings.linesColor, width: settings.linesWidth, p1: CGPoint(x: x1, y: y1), p2: CGPoint(x: x2, y: y2))
            }
        }
        
        if axis == .y || axis == .xAndY {
            for yValue in yValues {
                guard (settings.show?(yValue) ?? true) else {continue}
                
                let yScreenLoc = yAxisLayer.axis.screenLocForScalar(yValue)
                
                let x1 = yAxisLayer.lineP1.x + (yAxisLayer.low ? -settings.start : settings.start)
                let y1 = yScreenLoc
                let x2 = yAxisLayer.lineP1.x + (yAxisLayer.low ? settings.end : settings.end)
                let y2 = yScreenLoc
                drawLine(context: context, color: settings.linesColor, width: settings.linesWidth, p1: CGPoint(x: x1, y: y1), p2: CGPoint(x: x2, y: y2))
            }
        }
    }
}
