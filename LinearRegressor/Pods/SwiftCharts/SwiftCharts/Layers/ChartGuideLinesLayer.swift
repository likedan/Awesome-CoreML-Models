//
//  ChartGuideLinesLayer.swift
//  SwiftCharts
//
//  Created by ischuetz on 26/04/15.
//  Copyright (c) 2015 ivanschuetz. All rights reserved.
//

import UIKit

open class ChartGuideLinesLayerSettings {
    public let linesColor: UIColor
    public let linesWidth: CGFloat
    
    public init(linesColor: UIColor = UIColor.gray, linesWidth: CGFloat = 0.3) {
        self.linesColor = linesColor
        self.linesWidth = linesWidth
    }
}

open class ChartGuideLinesDottedLayerSettings: ChartGuideLinesLayerSettings {
    public let dotWidth: CGFloat
    public let dotSpacing: CGFloat
    
    public init(linesColor: UIColor, linesWidth: CGFloat, dotWidth: CGFloat = 2, dotSpacing: CGFloat = 2) {
        self.dotWidth = dotWidth
        self.dotSpacing = dotSpacing
        super.init(linesColor: linesColor, linesWidth: linesWidth)
    }
}

public enum ChartGuideLinesLayerAxis {
    case x, y, xAndY
}

open class ChartGuideLinesLayerAbstract<T: ChartGuideLinesLayerSettings>: ChartCoordsSpaceLayer {
    
    fileprivate let settings: T
    fileprivate let axis: ChartGuideLinesLayerAxis
    fileprivate let xAxisLayer: ChartAxisLayer
    fileprivate let yAxisLayer: ChartAxisLayer

    public init(xAxisLayer: ChartAxisLayer, yAxisLayer: ChartAxisLayer, axis: ChartGuideLinesLayerAxis = .xAndY, settings: T) {
        self.settings = settings
        self.axis = axis
        self.xAxisLayer = xAxisLayer
        self.yAxisLayer = yAxisLayer
        
        super.init(xAxis: xAxisLayer.axis, yAxis: yAxisLayer.axis)
    }
    
    fileprivate func drawGuideline(_ context: CGContext, p1: CGPoint, p2: CGPoint) {
        fatalError("override")
    }
    
    override open func chartViewDrawing(context: CGContext, chart: Chart) {
        let originScreenLoc = chart.containerFrame.origin
        let xScreenLocs = xAxisLayer.axisValuesScreenLocs
        let yScreenLocs = yAxisLayer.axisValuesScreenLocs
        
        if axis == .x || axis == .xAndY {
            for xScreenLoc in xScreenLocs {
                guard (!yAxisLayer.low || xScreenLoc > yAxisLayer.frame.maxX) && (yAxisLayer.low || xScreenLoc < yAxisLayer.frame.minX) else {continue}
                let x1 = xScreenLoc
                let y1 = originScreenLoc.y
                let x2 = x1
                let y2 = originScreenLoc.y + chart.containerFrame.height
                drawGuideline(context, p1: CGPoint(x: x1, y: y1), p2: CGPoint(x: x2, y: y2))
            }
        }
        
        if axis == .y || axis == .xAndY {
            for yScreenLoc in yScreenLocs {
                guard (xAxisLayer.low || yScreenLoc > xAxisLayer.frame.maxY) && (!xAxisLayer.low || yScreenLoc < xAxisLayer.frame.minY) else {continue}
                let x1 = originScreenLoc.x
                let y1 = yScreenLoc
                let x2 = originScreenLoc.x + chart.containerFrame.width
                let y2 = y1
                drawGuideline(context, p1: CGPoint(x: x1, y: y1), p2: CGPoint(x: x2, y: y2))
            }
        }
    }
}

public typealias ChartGuideLinesLayer = ChartGuideLinesLayer_<Any>
open class ChartGuideLinesLayer_<N>: ChartGuideLinesLayerAbstract<ChartGuideLinesLayerSettings> {
    
    override public init(xAxisLayer: ChartAxisLayer, yAxisLayer: ChartAxisLayer, axis: ChartGuideLinesLayerAxis = .xAndY, settings: ChartGuideLinesLayerSettings) {
        super.init(xAxisLayer: xAxisLayer, yAxisLayer: yAxisLayer, axis: axis, settings: settings)
    }
    
    override fileprivate func drawGuideline(_ context: CGContext, p1: CGPoint, p2: CGPoint) {
        ChartDrawLine(context: context, p1: p1, p2: p2, width: settings.linesWidth, color: settings.linesColor)
    }
}

public typealias ChartGuideLinesDottedLayer = ChartGuideLinesDottedLayer_<Any>
open class ChartGuideLinesDottedLayer_<N>: ChartGuideLinesLayerAbstract<ChartGuideLinesDottedLayerSettings> {
    
    override public init(xAxisLayer: ChartAxisLayer, yAxisLayer: ChartAxisLayer, axis: ChartGuideLinesLayerAxis = .xAndY, settings: ChartGuideLinesDottedLayerSettings) {
        super.init(xAxisLayer: xAxisLayer, yAxisLayer: yAxisLayer, axis: axis, settings: settings)
    }
    
    override fileprivate func drawGuideline(_ context: CGContext, p1: CGPoint, p2: CGPoint) {
        ChartDrawDottedLine(context: context, p1: p1, p2: p2, width: settings.linesWidth, color: settings.linesColor, dotWidth: settings.dotWidth, dotSpacing: settings.dotSpacing)
    }
}


open class ChartGuideLinesForValuesLayerAbstract<T: ChartGuideLinesLayerSettings>: ChartCoordsSpaceLayer {
    
    fileprivate let settings: T
    fileprivate let axisValuesX: [ChartAxisValue]
    fileprivate let axisValuesY: [ChartAxisValue]

    public init(xAxis: ChartAxis, yAxis: ChartAxis, settings: T, axisValuesX: [ChartAxisValue], axisValuesY: [ChartAxisValue]) {
        self.settings = settings
        self.axisValuesX = axisValuesX
        self.axisValuesY = axisValuesY
        super.init(xAxis: xAxis, yAxis: yAxis)
    }
    
    fileprivate func drawGuideline(_ context: CGContext, color: UIColor, width: CGFloat, p1: CGPoint, p2: CGPoint, dotWidth: CGFloat, dotSpacing: CGFloat) {
        ChartDrawDottedLine(context: context, p1: p1, p2: p2, width: width, color: color, dotWidth: dotWidth, dotSpacing: dotSpacing)
    }
    
    fileprivate func drawGuideline(_ context: CGContext, p1: CGPoint, p2: CGPoint) {
        fatalError("override")
    }
    
    override open func chartViewDrawing(context: CGContext, chart: Chart) {
        let originScreenLoc = chart.containerFrame.origin
        
        for axisValue in axisValuesX {
            let screenLoc = xAxis.screenLocForScalar(axisValue.scalar)
            let x1 = screenLoc
            let y1 = originScreenLoc.y
            let x2 = x1
            let y2 = originScreenLoc.y + chart.containerFrame.height
            drawGuideline(context, p1: CGPoint(x: x1, y: y1), p2: CGPoint(x: x2, y: y2))

        }
        
        for axisValue in axisValuesY {
            let screenLoc = yAxis.screenLocForScalar(axisValue.scalar)
            let x1 = originScreenLoc.x
            let y1 = screenLoc
            let x2 = originScreenLoc.x + chart.containerFrame.width
            let y2 = y1
            drawGuideline(context, p1: CGPoint(x: x1, y: y1), p2: CGPoint(x: x2, y: y2))

        }
    }
}


public typealias ChartGuideLinesForValuesLayer = ChartGuideLinesForValuesLayer_<Any>
open class ChartGuideLinesForValuesLayer_<N>: ChartGuideLinesForValuesLayerAbstract<ChartGuideLinesLayerSettings> {
    
    public override init(xAxis: ChartAxis, yAxis: ChartAxis, settings: ChartGuideLinesLayerSettings, axisValuesX: [ChartAxisValue], axisValuesY: [ChartAxisValue]) {
        super.init(xAxis: xAxis, yAxis: yAxis, settings: settings, axisValuesX: axisValuesX, axisValuesY: axisValuesY)
    }
    
    override fileprivate func drawGuideline(_ context: CGContext, p1: CGPoint, p2: CGPoint) {
        ChartDrawLine(context: context, p1: p1, p2: p2, width: settings.linesWidth, color: settings.linesColor)
    }
}

public typealias ChartGuideLinesForValuesDottedLayer = ChartGuideLinesForValuesDottedLayer_<Any>
open class ChartGuideLinesForValuesDottedLayer_<N>: ChartGuideLinesForValuesLayerAbstract<ChartGuideLinesDottedLayerSettings> {
    
    public override init(xAxis: ChartAxis, yAxis: ChartAxis, settings: ChartGuideLinesDottedLayerSettings, axisValuesX: [ChartAxisValue], axisValuesY: [ChartAxisValue]) {
        super.init(xAxis: xAxis, yAxis: yAxis, settings: settings, axisValuesX: axisValuesX, axisValuesY: axisValuesY)
    }
    
    override fileprivate func drawGuideline(_ context: CGContext, p1: CGPoint, p2: CGPoint) {
        ChartDrawDottedLine(context: context, p1: p1, p2: p2, width: settings.linesWidth, color: settings.linesColor, dotWidth: settings.dotWidth, dotSpacing: settings.dotSpacing)
    }
}

