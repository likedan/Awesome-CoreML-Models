//
//  ChartPointsViewsLayer.swift
//  SwiftCharts
//
//  Created by ischuetz on 27/04/15.
//  Copyright (c) 2015 ivanschuetz. All rights reserved.
//

import UIKit

public enum ChartPointsViewsLayerMode {
    case scaleAndTranslate, translate, custom
}

open class ChartPointsViewsLayer<T: ChartPoint, U: UIView>: ChartPointsLayer<T> {

    public typealias ChartPointViewGenerator = (_ chartPointModel: ChartPointLayerModel<T>, _ layer: ChartPointsViewsLayer<T, U>, _ chart: Chart) -> U?
    public typealias ViewWithChartPoint = (view: U, chartPointModel: ChartPointLayerModel<T>)
    
    open internal(set) var viewsWithChartPoints: [ViewWithChartPoint] = []
    
    fileprivate let delayBetweenItems: Float = 0
    
    let viewGenerator: ChartPointViewGenerator
    
    fileprivate var conflictSolver: ChartViewsConflictSolver<T, U>?
    
    fileprivate let mode: ChartPointsViewsLayerMode
    
    // For cases when layers behind re-add subviews on pan/zoom, ensure views of this layer stays on front
    // TODO z ordering
    fileprivate let keepOnFront: Bool
    
    public let delayInit: Bool
    
    public var customTransformer: ((ChartPointLayerModel<T>, UIView, ChartPointsViewsLayer<T, U>) -> Void)?
    
    fileprivate let clipViews: Bool
    
    public init(xAxis: ChartAxis, yAxis: ChartAxis, chartPoints:[T], viewGenerator: @escaping ChartPointViewGenerator, conflictSolver: ChartViewsConflictSolver<T, U>? = nil, displayDelay: Float = 0, delayBetweenItems: Float = 0, mode: ChartPointsViewsLayerMode = .scaleAndTranslate, keepOnFront: Bool = true, delayInit: Bool = false, clipViews: Bool = true) {
        self.viewGenerator = viewGenerator
        self.conflictSolver = conflictSolver
        self.mode = mode
        self.keepOnFront = keepOnFront
        self.delayInit = delayInit
        self.clipViews = clipViews
        super.init(xAxis: xAxis, yAxis: yAxis, chartPoints: chartPoints, displayDelay: displayDelay)
    }
    
    override open func display(chart: Chart) {
        super.display(chart: chart)
        if !delayInit {
            initViews(chart)
        }
    }
    
    open func initViews(_ chart: Chart) {
        viewsWithChartPoints = generateChartPointViews(chartPointModels: chartPointsModels, chart: chart)
        
        if delayBetweenItems =~ 0 {
            for v in viewsWithChartPoints {addSubview(chart, view: v.view)}
            
        } else {
            for viewWithChartPoint in viewsWithChartPoints {
                let view = viewWithChartPoint.view
                addSubview(chart, view: view)
            }
        }
    }
    
    func addSubview(_ chart: Chart, view: UIView) {
        switch mode {
        case .scaleAndTranslate:
            chart.addSubview(view)
        case .translate: fallthrough
        case .custom:
            if !clipViews {
                chart.addSubviewNoTransformUnclipped(view)
            } else {
                chart.addSubviewNoTransform(view)
            }
            
        }
    }
    
    func reloadViews() {
        guard let chart = chart else {return}
        
        for v in viewsWithChartPoints {
            v.view.removeFromSuperview()
        }
        
        display(chart: chart)
    }
    
    fileprivate func generateChartPointViews(chartPointModels: [ChartPointLayerModel<T>], chart: Chart) -> [ViewWithChartPoint] {
        let viewsWithChartPoints: [ViewWithChartPoint] = chartPointsModels.flatMap {model in
            if let view = viewGenerator(model, self, chart) {
                return (view: view, chartPointModel: model)
            } else {
                return nil
            }
        }
        
        conflictSolver?.solveConflicts(views: viewsWithChartPoints)
        
        return viewsWithChartPoints
    }
    
    override open func chartPointsForScreenLoc(_ screenLoc: CGPoint) -> [T] {
        return filterChartPoints{inXBounds(screenLoc.x, view: $0.view) && inYBounds(screenLoc.y, view: $0.view)}
    }
    
    override open func chartPointsForScreenLocX(_ x: CGFloat) -> [T] {
        return filterChartPoints{inXBounds(x, view: $0.view)}
    }
    
    override open func chartPointsForScreenLocY(_ y: CGFloat) -> [T] {
        return filterChartPoints{inYBounds(y, view: $0.view)}
    }
    
    fileprivate func filterChartPoints(_ filter: (ViewWithChartPoint) -> Bool) -> [T] {
        return viewsWithChartPoints.reduce([]) {arr, viewWithChartPoint in
            if filter(viewWithChartPoint) {
                return arr + [viewWithChartPoint.chartPointModel.chartPoint]
            } else {
                return arr
            }
        }
    }
    
    fileprivate func inXBounds(_ x: CGFloat, view: UIView) -> Bool {
        return (x > view.frame.origin.x) && (x < (view.frame.origin.x + view.frame.width))
    }
    
    fileprivate func inYBounds(_ y: CGFloat, view: UIView) -> Bool {
        return (y > view.frame.origin.y) && (y < (view.frame.origin.y + view.frame.height))
    }
    
    open override func zoom(_ x: CGFloat, y: CGFloat, centerX: CGFloat, centerY: CGFloat) {
        super.zoom(x, y: y, centerX: centerX, centerY: centerY)
        updateForTransform()
    }
    
    open override func pan(_ deltaX: CGFloat, deltaY: CGFloat) {
        super.pan(deltaX, deltaY: deltaY)
        updateForTransform()
    }
    
    func updateForTransform() {
        switch mode {
            
        case .scaleAndTranslate:
            updateChartPointsScreenLocations()
            
        case .translate:
            for i in 0..<viewsWithChartPoints.count {
                viewsWithChartPoints[i].chartPointModel.screenLoc = modelLocToScreenLoc(x: viewsWithChartPoints[i].chartPointModel.chartPoint.x.scalar, y: viewsWithChartPoints[i].chartPointModel.chartPoint.y.scalar)
                viewsWithChartPoints[i].view.center = viewsWithChartPoints[i].chartPointModel.screenLoc
            }
            
        case .custom:
            for i in 0..<viewsWithChartPoints.count {
                customTransformer?(viewsWithChartPoints[i].chartPointModel, viewsWithChartPoints[i].view, self)
            }
        }
        
        if keepOnFront {
            bringToFront()
        }
    }
    
    open override func modelLocToScreenLoc(x: Double, y: Double) -> CGPoint {
        switch mode {
        case .scaleAndTranslate:
            return super.modelLocToScreenLoc(x: x, y: y)
        case .translate: fallthrough
        case .custom:
            return super.modelLocToContainerScreenLoc(x: x, y: y)
        }
    }
    
    open func bringToFront() {
        for (view, _) in viewsWithChartPoints {
            view.superview?.bringSubview(toFront: view)
        }
    }
}
