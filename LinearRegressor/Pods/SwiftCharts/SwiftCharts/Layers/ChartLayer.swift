//
//  ChartLayer.swift
//  SwiftCharts
//
//  Created by ischuetz on 02/05/15.
//  Copyright (c) 2015 ivanschuetz. All rights reserved.
//

import UIKit

public protocol ChartLayer {
    
    var chart: Chart? {get set}

    // Execute actions after chart initialisation, e.g. add subviews
    func chartInitialized(chart: Chart)
    
    // Draw directly in chart's context
    // Everything drawn here will appear behind subviews added by any layer (regardless of position in layers array)
    func chartViewDrawing(context: CGContext, chart: Chart)
    
    func chartContentViewDrawing(context: CGContext, chart: Chart)

    func chartDrawersContentViewDrawing(context: CGContext, chart: Chart, view: UIView)
    
    /// Trigger views update, to match updated model data
    func update()
    
    /// Handle a change of the available inner space caused by an axis change of size in a direction orthogonal to the axis.
    func handleAxisInnerFrameChange(_ xLow: ChartAxisLayerWithFrameDelta?, yLow: ChartAxisLayerWithFrameDelta?, xHigh: ChartAxisLayerWithFrameDelta?, yHigh: ChartAxisLayerWithFrameDelta?)
    
    func zoom(_ x: CGFloat, y: CGFloat, centerX: CGFloat, centerY: CGFloat)
    
    func zoom(_ scaleX: CGFloat, scaleY: CGFloat, centerX: CGFloat, centerY: CGFloat)

    func pan(_ deltaX: CGFloat, deltaY: CGFloat)
    
    func handlePanStart(_ location: CGPoint)
    
    func handlePanFinish()
    
    func handleZoomFinish()
    
    func handlePanEnd()
    
    func handleZoomEnd()
    
    @discardableResult
    func handleGlobalTap(_ location: CGPoint) -> Any?
    
    /// Return true to disable chart panning
    func processPan(location: CGPoint, deltaX: CGFloat, deltaY: CGFloat, isGesture: Bool, isDeceleration: Bool) -> Bool
    
    /// Return true to disable chart zooming
    func processZoom(deltaX: CGFloat, deltaY: CGFloat, anchorX: CGFloat, anchorY: CGFloat) -> Bool
    
    func keepInBoundaries()
}