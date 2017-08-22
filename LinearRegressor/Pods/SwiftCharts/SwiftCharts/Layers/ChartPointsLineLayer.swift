//
//  ChartPointsLineLayer.swift
//  SwiftCharts
//
//  Created by ischuetz on 25/04/15.
//  Copyright (c) 2015 ivanschuetz. All rights reserved.
//

import UIKit

public enum LineJoin {
    case miter
    case round
    case bevel
    
    public var CALayerString: String {
        switch self {
        case .miter: return kCALineJoinMiter
        case .round: return kCALineCapRound
        case .bevel: return kCALineJoinBevel
        }
    }
    
    public var CGValue: CGLineJoin {
        switch self {
        case .miter: return .miter
        case .round: return .round
        case .bevel: return .bevel
        }
    }
}

public enum LineCap {
    case butt
    case round
    case square
    
    public var CALayerString: String {
        switch self {
        case .butt: return kCALineCapButt
        case .round: return kCALineCapRound
        case .square: return kCALineCapSquare
        }
    }
    
    public var CGValue: CGLineCap {
        switch self {
        case .butt: return .butt
        case .round: return .round
        case .square: return .square
        }
    }
}

public struct ScreenLine<T: ChartPoint> {
    public internal(set) var points: [CGPoint]
    public let color: UIColor
    public let lineWidth: CGFloat
    public let lineJoin: LineJoin
    public let lineCap: LineCap
    public let animDuration: Float
    public let animDelay: Float
    public let lineModel: ChartLineModel<T>
    public let dashPattern: [Double]?
    
    init(points: [CGPoint], color: UIColor, lineWidth: CGFloat, lineJoin: LineJoin, lineCap: LineCap, animDuration: Float, animDelay: Float, lineModel: ChartLineModel<T>, dashPattern: [Double]?) {
        self.points = points
        self.color = color
        self.lineWidth = lineWidth
        self.lineJoin = lineJoin
        self.lineCap = lineCap
        self.animDuration = animDuration
        self.animDelay = animDelay
        self.lineModel = lineModel
        self.dashPattern = dashPattern
    }
}

open class ChartPointsLineLayer<T: ChartPoint>: ChartPointsLayer<T> {
    open fileprivate(set) var lineModels: [ChartLineModel<T>]
    open fileprivate(set) var lineViews: [ChartLinesView] = []
    open let pathGenerator: ChartLinesViewPathGenerator
    open fileprivate(set) var screenLines: [(screenLine: ScreenLine<T>, view: ChartLinesView)] = []
    
    public let useView: Bool
    public let delayInit: Bool
    
    fileprivate var isInTransform = false
    
    public init(xAxis: ChartAxis, yAxis: ChartAxis, lineModels: [ChartLineModel<T>], pathGenerator: ChartLinesViewPathGenerator = StraightLinePathGenerator(), displayDelay: Float = 0, useView: Bool = true, delayInit: Bool = false) {
        self.lineModels = lineModels
        self.pathGenerator = pathGenerator
        self.useView = useView
        self.delayInit = delayInit
        
        let chartPoints: [T] = lineModels.flatMap{$0.chartPoints}
        
        super.init(xAxis: xAxis, yAxis: yAxis, chartPoints: chartPoints, displayDelay: displayDelay)
    }
    
    fileprivate func toScreenLine(lineModel: ChartLineModel<T>, chart: Chart) -> ScreenLine<T> {
        return ScreenLine(
            points: lineModel.chartPoints.map{chartPointScreenLoc($0)},
            color: lineModel.lineColor,
            lineWidth: lineModel.lineWidth,
            lineJoin: lineModel.lineJoin,
            lineCap: lineModel.lineCap,
            animDuration: lineModel.animDuration,
            animDelay: lineModel.animDelay,
            lineModel: lineModel,
            dashPattern: lineModel.dashPattern
        )
    }
    
    override open func display(chart: Chart) {
        if !delayInit {
            if useView {
                initScreenLines(chart)
            }
        }
    }
    
    open func initScreenLines(_ chart: Chart) {
        let screenLines = lineModels.map{toScreenLine(lineModel: $0, chart: chart)}
        
        for screenLine in screenLines {
            let lineView = generateLineView(screenLine, chart: chart)
            lineViews.append(lineView)
            lineView.isUserInteractionEnabled = false
            chart.addSubviewNoTransform(lineView)
            self.screenLines.append((screenLine, lineView))
        }
    }
    
    open func generateLineView(_ screenLine: ScreenLine<T>, chart: Chart) -> ChartLinesView {
        return ChartLinesView(
            path: pathGenerator.generatePath(points: screenLine.points, lineWidth: screenLine.lineWidth),
            frame: chart.contentView.bounds,
            lineColor: screenLine.color,
            lineWidth: screenLine.lineWidth,
            lineJoin: screenLine.lineJoin,
            lineCap: screenLine.lineCap,
            animDuration: isInTransform ? 0 : screenLine.animDuration,
            animDelay: isInTransform ? 0 : screenLine.animDelay,
            dashPattern: screenLine.dashPattern
        )
    }
    
    override open func chartDrawersContentViewDrawing(context: CGContext, chart: Chart, view: UIView) {
        if !useView {
            for lineModel in lineModels {
                let points = lineModel.chartPoints.map { modelLocToScreenLoc(x: $0.x.scalar, y: $0.y.scalar) }
                let path = pathGenerator.generatePath(points: points, lineWidth: lineModel.lineWidth)
                
                context.saveGState()
                context.addPath(path.cgPath)
                context.setLineWidth(lineModel.lineWidth)
                context.setLineJoin(lineModel.lineJoin.CGValue)
                context.setLineCap(lineModel.lineCap.CGValue)
                context.setLineDash(phase: 0, lengths: lineModel.dashPattern?.map { CGFloat($0) } ?? [])
                context.setStrokeColor(lineModel.lineColor.cgColor)
                context.strokePath()
                context.restoreGState()
            }
        }
    }
    
    open override func modelLocToScreenLoc(x: Double) -> CGFloat {
        return xAxis.screenLocForScalar(x) - (chart?.containerFrame.origin.x ?? 0)
    }
    
    open override func modelLocToScreenLoc(y: Double) -> CGFloat {
        return yAxis.screenLocForScalar(y) - (chart?.containerFrame.origin.y ?? 0)
    }
    
    open override func zoom(_ scaleX: CGFloat, scaleY: CGFloat, centerX: CGFloat, centerY: CGFloat) {
        if !useView {
            chart?.drawersContentView.setNeedsDisplay()
        }
    }
    
    open override func zoom(_ x: CGFloat, y: CGFloat, centerX: CGFloat, centerY: CGFloat) {
        if !useView {
            chart?.drawersContentView.setNeedsDisplay()
        } else {
            updateScreenLines()
        }
    }
    
    open override func pan(_ deltaX: CGFloat, deltaY: CGFloat) {
        if !useView {
            chart?.drawersContentView.setNeedsDisplay()
        } else {
            updateScreenLines()
        }
    }

    fileprivate func updateScreenLines() {

        guard let chart = chart else {return}
        
        isInTransform = true
        
        for i in 0..<screenLines.count {
            for j in 0..<screenLines[i].screenLine.points.count {
                let chartPoint = screenLines[i].screenLine.lineModel.chartPoints[j]
                screenLines[i].screenLine.points[j] = modelLocToScreenLoc(x: chartPoint.x.scalar, y: chartPoint.y.scalar)
            }
            
            screenLines[i].view.removeFromSuperview()
            screenLines[i].view = generateLineView(screenLines[i].screenLine, chart: chart)
            chart.addSubviewNoTransform(screenLines[i].view)
        }
        
        isInTransform = false
    }
}
