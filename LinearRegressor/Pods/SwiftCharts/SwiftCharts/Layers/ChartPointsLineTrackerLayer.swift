//
//  ChartPointsTrackerLayer.swift
//  swift_charts
//
//  Created by ischuetz on 16/04/15.
//  Copyright (c) 2015 ivanschuetz. All rights reserved.
//

import UIKit

public struct ChartPointsLineTrackerLayerThumbSettings {
    let thumbSize: CGFloat
    let thumbBorderWidth: CGFloat
    let thumbBorderColor: UIColor
    
    public init(thumbSize: CGFloat, thumbBorderWidth: CGFloat = 4, thumbBorderColor: UIColor = UIColor.black) {
        self.thumbSize = thumbSize
        self.thumbBorderWidth = thumbBorderWidth
        self.thumbBorderColor = thumbBorderColor
    }
}

public struct ChartPointsLineTrackerLayerSettings {
    let thumbSettings: ChartPointsLineTrackerLayerThumbSettings? // nil -> no thumb
    let selectNearest: Bool
    
    public init(thumbSettings: ChartPointsLineTrackerLayerThumbSettings? = nil, selectNearest: Bool = false) {
        self.thumbSettings = thumbSettings
        self.selectNearest = selectNearest
    }
}


public struct ChartTrackerSelectedChartPoint<T: ChartPoint, U>: CustomDebugStringConvertible {
    
    public let chartPoint: T
    public let screenLoc: CGPoint
    public let lineIndex: Int
    public let lineModel: ChartTrackerLineLayerModel<T, U>
    public let lineExtra: U?
    
    init(chartPoint: T, intersection: ChartTrackerIntersection<T, U>) {
        self.init(chartPoint: chartPoint, screenLoc: intersection.screenLoc, lineIndex: intersection.lineIndex, lineModel: intersection.lineModel, lineExtra: intersection.lineModel.extra)
    }
    
    init(chartPoint: T, screenLoc: CGPoint, lineIndex: Int, lineModel: ChartTrackerLineLayerModel<T, U>, lineExtra: U?) {
        self.chartPoint = chartPoint
        self.screenLoc = screenLoc
        self.lineIndex = lineIndex
        self.lineModel = lineModel
        self.lineExtra = lineExtra
    }
    
    func copy(_ chartPoint: T? = nil, screenLoc: CGPoint? = nil, lineIndex: Int? = nil, lineModel: ChartTrackerLineLayerModel<T, U>? = nil, lineExtra: U? = nil) -> ChartTrackerSelectedChartPoint<T, U> {
        return ChartTrackerSelectedChartPoint(
            chartPoint: chartPoint ?? self.chartPoint,
            screenLoc: screenLoc ?? self.screenLoc,
            lineIndex: lineIndex ?? self.lineIndex,
            lineModel: lineModel ?? self.lineModel,
            lineExtra: lineExtra ?? self.lineExtra
        )
    }
    
    public var debugDescription: String {
        return "chartPoint: \(chartPoint), screenLoc: \(screenLoc), lineIndex: \(lineIndex), lineModel: \(lineModel)"
    }
}

public struct ChartTrackerIntersection<T: ChartPoint, U> {
    let screenLoc: CGPoint
    let lineIndex: Int
    let lineModel: ChartTrackerLineLayerModel<T, U>
    
    init(screenLoc: CGPoint, lineIndex: Int, lineModel: ChartTrackerLineLayerModel<T, U>) {
        self.screenLoc = screenLoc
        self.lineIndex = lineIndex
        self.lineModel = lineModel
    }
}

public struct ChartTrackerLineModel<T: ChartPoint, U> {
    public let chartPoints: [T]
    public let extra: U?
    
    public init(chartPoints: [T]) {
        self.init(chartPoints: chartPoints, extra: nil)
    }
    
    /// extra: optional object which is passed back with the line in the position update handler. Can be for example an id to group certain lines together, a color, etc.
    public init(chartPoints: [T], extra: U?) {
        self.chartPoints = chartPoints
        self.extra = extra
    }
}

public struct ChartTrackerLineLayerModel<T: ChartPoint, U> {
    public let chartPointModels: [ChartPointLayerModel<T>]
    public let extra: U?
    
    init(chartPointModels: [ChartPointLayerModel<T>], extra: U?) {
        self.chartPointModels = chartPointModels
        self.extra = extra
    }
    
    func copy(_ chartPointModels: [ChartPointLayerModel<T>]? = nil, extra: U?? = nil) -> ChartTrackerLineLayerModel {
        return ChartTrackerLineLayerModel(
            chartPointModels: chartPointModels ?? self.chartPointModels,
            extra: extra ?? self.extra
        )
    }
}

open class ChartPointsLineTrackerLayer<T: ChartPoint, U>: ChartPointsLayer<T> {
    
    fileprivate let lineColor: UIColor
    fileprivate let animDuration: Float
    fileprivate let animDelay: Float
    
    fileprivate let settings: ChartPointsLineTrackerLayerSettings

    fileprivate var isTracking: Bool = false
    
    open var positionUpdateHandler: (([ChartTrackerSelectedChartPoint<T, U>]) -> Void)?
    
    open let lines: [ChartTrackerLineModel<T, U>]
    open var lineModels: [ChartTrackerLineLayerModel<T, U>] = []
    
    fileprivate var currentIntersections: [ChartTrackerIntersection<T, U>] = []
    
    fileprivate var lineView: UIView?
    
    public convenience init(xAxis: ChartAxis, yAxis: ChartAxis, lines: [[T]], lineColor: UIColor, animDuration: Float, animDelay: Float, settings: ChartPointsLineTrackerLayerSettings, positionUpdateHandler: (([ChartTrackerSelectedChartPoint<T, U>]) -> Void)? = nil) {
        self.init(xAxis: xAxis, yAxis: yAxis, lines: lines.map{ChartTrackerLineModel(chartPoints: $0)}, lineColor: lineColor, animDuration: animDuration, animDelay: animDelay, settings: settings, positionUpdateHandler: positionUpdateHandler)
    }
    
    public init(xAxis: ChartAxis, yAxis: ChartAxis, lines: [ChartTrackerLineModel<T, U>], lineColor: UIColor, animDuration: Float, animDelay: Float, settings: ChartPointsLineTrackerLayerSettings, positionUpdateHandler: (([ChartTrackerSelectedChartPoint<T, U>]) -> Void)? = nil) {
        self.lineColor = lineColor
        self.animDuration = animDuration
        self.animDelay = animDelay
        self.settings = settings
        self.positionUpdateHandler = positionUpdateHandler
        self.lines = lines
        super.init(xAxis: xAxis, yAxis: yAxis, chartPoints: Array(lines.map{$0.chartPoints}.joined()))
    }

    fileprivate func linesIntersection(line1P1: CGPoint, line1P2: CGPoint, line2P1: CGPoint, line2P2: CGPoint) -> CGPoint? {
        return findLineIntersection(p0X: line1P1.x, p0y: line1P1.y, p1x: line1P2.x, p1y: line1P2.y, p2x: line2P1.x, p2y: line2P1.y, p3x: line2P2.x, p3y: line2P2.y)
    }
    
    override func initChartPointModels() {
        lineModels = lines.map{ChartTrackerLineLayerModel<T, U>(chartPointModels: generateChartPointModels($0.chartPoints), extra: $0.extra)}
        chartPointsModels = Array(lineModels.map{$0.chartPointModels}.joined()) // consistency
    }
    
    override func updateChartPointsScreenLocations() {
        super.updateChartPointsScreenLocations()
        for i in 0..<lineModels.count {
            let line = lineModels[i]
            let updatedChartPoints = updateChartPointsScreenLocations(line.chartPointModels)
            let updatedLine = line.copy(updatedChartPoints)
            lineModels[i] = updatedLine
        }
    }
    
    // src: http://stackoverflow.com/a/14795484/930450 (modified)
    fileprivate func findLineIntersection(p0X: CGFloat , p0y: CGFloat, p1x: CGFloat, p1y: CGFloat, p2x: CGFloat, p2y: CGFloat, p3x: CGFloat, p3y: CGFloat) -> CGPoint? {
        
        var s02x: CGFloat, s02y: CGFloat, s10x: CGFloat, s10y: CGFloat, s32x: CGFloat, s32y: CGFloat, sNumer: CGFloat, tNumer: CGFloat, denom: CGFloat, t: CGFloat;
        
        s10x = p1x - p0X
        s10y = p1y - p0y
        s32x = p3x - p2x
        s32y = p3y - p2y
        
        denom = s10x * s32y - s32x * s10y
        if denom =~ 0 {
            return nil // Collinear
        }
        let denomPositive: Bool = denom > 0
        
        s02x = p0X - p2x
        s02y = p0y - p2y
        sNumer = s10x * s02y - s10y * s02x
        if (sNumer < 0) == denomPositive {
            return nil // No collision
        }
        
        tNumer = s32x * s02y - s32y * s02x
        if (tNumer < 0) == denomPositive {
            return nil // No collision
        }
        if ((sNumer > denom) == denomPositive) || ((tNumer > denom) == denomPositive) {
            return nil // No collision
        }
        
        // Collision detected
        t = tNumer / denom
        let i_x = p0X + (t * s10x)
        let i_y = p0y + (t * s10y)
        return CGPoint(x: i_x, y: i_y)
    }
    
    fileprivate func intersectsWithChartPointLines(_ rect: CGRect) -> Bool {
        let rectLines = rect.asLinesArray()
        return iterateLineSegments({p1, p2, _, _ in
            for rectLine in rectLines {
                if self.linesIntersection(line1P1: rectLine.p1, line1P2: rectLine.p2, line2P1: p1.screenLoc, line2P2: p2.screenLoc) != nil {
                    return true
                }
            }
            return nil
        }) ?? false
    }

    fileprivate func intersectsWithTrackerLine(_ rect: CGRect) -> Bool {
        
        guard let currentIntersection = currentIntersections.first else {return false}
        
        let rectLines = rect.asLinesArray()
        
        let line = toLine(currentIntersection.screenLoc)
        
        for rectLine in rectLines {
            if linesIntersection(line1P1: rectLine.p1, line1P2: rectLine.p2, line2P1: line.p1, line2P2: line.p2) != nil {
                return true
            }
        }
        
        return false
    }
   
    fileprivate func updateTrackerLineOnValidState(updateFunc: (_ view: UIView) -> ()) {
        if !chartPointsModels.isEmpty {
            if let view = chart?.contentView {
                updateFunc(view)
            }
        }
    }
    
    /// f: function to be applied to each segment in the lines defined by p1, p2. Returns an object of type U to exit, returning it from the outer function, or nil to continue
    fileprivate func iterateLineSegments<V>(_ f: (_ p1: ChartPointLayerModel<T>, _ p2: ChartPointLayerModel<T>, _ lineIndex: Int, _ line: ChartTrackerLineLayerModel<T, U>) -> V?) -> V? {
        for (index, line) in lineModels.enumerated() {
            let lineChartPoints = line.chartPointModels
            
            guard !lineChartPoints.isEmpty else {continue}
            
            for i in 0..<(lineChartPoints.count - 1) {
                let m1 = lineChartPoints[i]
                let m2 = lineChartPoints[i + 1]
                
                if let res = f(m1, m2, index, line) {
                    return res
                }
            }
        }
        return nil
    }
    
    fileprivate func updateTrackerLine(touchPoint: CGPoint) {
        
        updateTrackerLineOnValidState{(view) in
            
            let constantX = touchPoint.x
            
            let touchlineP1 = CGPoint(x: constantX, y: 0)
            let touchlineP2 = CGPoint(x: constantX, y: view.frame.size.height)
            
            var intersections: [ChartTrackerIntersection<T, U>] = []
            
            let _: Any? = self.iterateLineSegments({p1, p2, lineIndex, lineModel in
                if let intersection = self.linesIntersection(line1P1: touchlineP1, line1P2: touchlineP2, line2P1: p1.screenLoc, line2P2: p2.screenLoc) {
                    intersections.append(ChartTrackerIntersection<T, U>(screenLoc: intersection, lineIndex: lineIndex, lineModel: lineModel))
                }
                return nil
            })
            
            if !intersections.isEmpty {
                
                self.currentIntersections = self.settings.selectNearest ? touchPoint.nearest(intersections, pointMapper: {$0.screenLoc}).map{[$0.pointMappable]} ?? [] : intersections
                self.isTracking = true
                
                self.updateLineView()
                
                if self.chartPointsModels.count > 1 {
                    
                    let chartPoints: [ChartTrackerSelectedChartPoint<T, U>] = intersections.map {intersection in
                        
                        // the charpoints as well as the touch (-> intersection) use global coordinates, to draw in drawer container we have to translate to its coordinates
                        let trans = self.globalToDrawersContainerCoordinates(intersection.screenLoc)!
                        
                        let zoomedAxisX = self.xAxis.firstVisibleScreen - self.xAxis.firstScreen + trans.x
                        let zoomedAxisY = self.yAxis.lastVisibleScreen - self.yAxis.lastScreen + trans.y
                        
                        let xScalar = self.xAxis.innerScalarForScreenLoc(zoomedAxisX)
                        let yScalar = self.yAxis.innerScalarForScreenLoc(zoomedAxisY)
                        
                        let dummyModel = self.chartPointsModels[0]
                        let x = dummyModel.chartPoint.x.copy(xScalar)
                        let y = dummyModel.chartPoint.y.copy(yScalar)
                        
                        let chartPoint = T(x: x, y: y)
                        
                        return ChartTrackerSelectedChartPoint<T, U>(chartPoint: chartPoint, intersection: intersection)
                    }
                    
                    self.positionUpdateHandler?(chartPoints)
                }
                
            } else {
                self.clearIntersections()
            }
        }
    }
    
    fileprivate func updateLineView() {
        
        guard let firstIntersection = currentIntersections.first, let containerTouchCoordinates = globalToDrawersContainerCoordinates(firstIntersection.screenLoc) else {return}
        
        if lineView == nil {
            let lineView = UIView()
            lineView.frame.size = CGSize(width: 2, height: 10000000)
            lineView.backgroundColor = UIColor.black
            chart?.addSubviewNoTransform(lineView)
            self.lineView = lineView
        }
        
        lineView?.center.x = containerTouchCoordinates.x
    }

    fileprivate func toLine(_ intersection: CGPoint) -> (p1: CGPoint, p2: CGPoint) {
        return (p1: CGPoint(x: intersection.x, y: 0), p2: CGPoint(x: intersection.x, y: 10000000))
    }

    open override func handlePanStart(_ location: CGPoint) {
        guard let localLocation = toLocalCoordinates(location) else {return}
        
        updateChartPointsScreenLocations()
        
        let surroundingRect = localLocation.surroundingRect(30)
        
        if intersectsWithChartPointLines(surroundingRect) || intersectsWithTrackerLine(surroundingRect) {
            isTracking = true
        } else {
            clearIntersections()
        }
    }
    
    fileprivate func clearIntersections() {
        currentIntersections = []
        positionUpdateHandler?([])
        lineView?.removeFromSuperview()
        lineView = nil
    }
    
    open override func processPan(location: CGPoint, deltaX: CGFloat, deltaY: CGFloat, isGesture: Bool, isDeceleration: Bool) -> Bool {
        guard let localLocation = toLocalCoordinates(location) else {return false}
        
        if isTracking {
            updateTrackerLine(touchPoint: localLocation)
            return true
        } else {
            return false
        }
    }
    
    open override func handleGlobalTap(_ location: CGPoint) -> Any? {
        guard let localLocation = toLocalCoordinates(location) else {return nil}
        
        updateChartPointsScreenLocations()
        
        updateTrackerLine(touchPoint: localLocation)

        return nil
    }
    
    open override func handlePanEnd() {
        isTracking = false
    }
    
    open override func modelLocToScreenLoc(x: Double) -> CGFloat {
        return xAxis.screenLocForScalar(x) - (chart?.containerFrame.origin.x ?? 0)
    }
    
    open override func modelLocToScreenLoc(y: Double) -> CGFloat {
        return yAxis.screenLocForScalar(y) - (chart?.containerFrame.origin.y ?? 0)
    }
    
    open override func zoom(_ scaleX: CGFloat, scaleY: CGFloat, centerX: CGFloat, centerY: CGFloat) {
        chart?.drawersContentView.setNeedsDisplay()
        
        clearIntersections()
    }
    
    open override func zoom(_ x: CGFloat, y: CGFloat, centerX: CGFloat, centerY: CGFloat) {
        super.zoom(x, y: y, centerX: centerX, centerY: centerY)
        clearIntersections()
        chart?.drawersContentView.setNeedsDisplay()
    }
    
    open override func pan(_ deltaX: CGFloat, deltaY: CGFloat) {
        super.pan(deltaX, deltaY: deltaY)
        chart?.drawersContentView.setNeedsDisplay()
    }
}
