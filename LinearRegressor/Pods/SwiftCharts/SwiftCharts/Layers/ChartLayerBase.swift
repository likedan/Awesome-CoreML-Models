//
//  ChartLayerBase.swift
//  SwiftCharts
//
//  Created by ischuetz on 02/05/15.
//  Copyright (c) 2015 ivanschuetz. All rights reserved.
//

import UIKit

/// Convenience class to store common properties and make protocol's methods optional
open class ChartLayerBase: NSObject, ChartLayer {

    open weak var chart: Chart?
    
    open func chartInitialized(chart: Chart) {
        self.chart = chart
    }
    
    open func chartViewDrawing(context: CGContext, chart: Chart) {}

    open func chartContentViewDrawing(context: CGContext, chart: Chart) {}

    open func chartDrawersContentViewDrawing(context: CGContext, chart: Chart, view: UIView) {}
    
    open func update() {}
    
    open func handleAxisInnerFrameChange(_ xLow: ChartAxisLayerWithFrameDelta?, yLow: ChartAxisLayerWithFrameDelta?, xHigh: ChartAxisLayerWithFrameDelta?, yHigh: ChartAxisLayerWithFrameDelta?) {}
    
    open func zoom(_ x: CGFloat, y: CGFloat, centerX: CGFloat, centerY: CGFloat) {}
    
    open func zoom(_ scaleX: CGFloat, scaleY: CGFloat, centerX: CGFloat, centerY: CGFloat) {}
    
    open func pan(_ deltaX: CGFloat, deltaY: CGFloat) {}

    open func processPan(location: CGPoint, deltaX: CGFloat, deltaY: CGFloat, isGesture: Bool, isDeceleration: Bool) -> Bool {
        return false
    }
    
    open func handlePanStart(_ location: CGPoint) {}
    
    open func handlePanFinish() {}
    
    open func handleZoomFinish() {}
    
    open func handlePanEnd() {}
    
    open func handleZoomEnd() {}
    
    open func processZoom(deltaX: CGFloat, deltaY: CGFloat, anchorX: CGFloat, anchorY: CGFloat) -> Bool {
        return false
    }
    
    open func handleGlobalTap(_ location: CGPoint) -> Any? {
        return nil
    }
    
    open func keepInBoundaries() {}
    
    public override init() {}
}
