//
//  ChartShowCoordsLinesLayer.swift
//  swift_charts
//
//  Created by ischuetz on 19/04/15.
//  Copyright (c) 2015 ivanschuetz. All rights reserved.
//

import UIKit

// TODO improve behaviour during zooming and panning - line has to be only translated, not scaled. Needs .translate behaviour of ChartPointsViewsLayer, maybe we can extend this layer?
open class ChartShowCoordsLinesLayer<T: ChartPoint>: ChartPointsLayer<T> {
    
    fileprivate var view: UIView?

    fileprivate var activeChartPoint: T?
    
    public init(xAxis: ChartAxis, yAxis: ChartAxis, chartPoints: [T]) {
        super.init(xAxis: xAxis, yAxis: yAxis, chartPoints: chartPoints)
    }
    
    open func showChartPointLines(_ chartPoint: T, chart: Chart) {
       
        if let view = self.view {
            
            activeChartPoint = chartPoint
            
            for v in view.subviews {
                v.removeFromSuperview()
            }
            
            let screenLoc = chartPointScreenLoc(chartPoint)
            
            let hLine = UIView(frame: CGRect(x: screenLoc.x, y: screenLoc.y, width: 0, height: 1))
            let vLine = UIView(frame: CGRect(x: screenLoc.x, y: screenLoc.y, width: 0, height: 1))
            
            for lineView in [hLine, vLine] {
                lineView.backgroundColor = UIColor.black
                view.addSubview(lineView)
            }
            
            func animations() {
                let axisOriginX = modelLocToScreenLoc(x: xAxis.first)
                let axisOriginY = modelLocToScreenLoc(y: yAxis.first)
                let axisLengthY = axisOriginY - modelLocToScreenLoc(y: yAxis.last)
                
                hLine.frame = CGRect(x: axisOriginX, y: screenLoc.y, width: screenLoc.x - axisOriginX, height: 1)
                vLine.frame = CGRect(x: screenLoc.x, y: screenLoc.y, width: 1, height: axisLengthY - screenLoc.y)
            }

            UIView.animate(withDuration: 0.2, delay: 0, options: .curveEaseOut, animations: {
                animations()
            }, completion: nil)
        }
    }
    
    override open func display(chart: Chart) {
        let view = UIView(frame: chart.bounds)
        view.isUserInteractionEnabled = true
        chart.addSubview(view)
        self.view = view
    }
    
    open override func zoom(_ x: CGFloat, y: CGFloat, centerX: CGFloat, centerY: CGFloat) {
        super.zoom(x, y: y, centerX: centerX, centerY: centerY)
        updateChartPointsScreenLocations()
    }
    
    open override func pan(_ deltaX: CGFloat, deltaY: CGFloat) {
        super.pan(deltaX, deltaY: deltaY)
        updateChartPointsScreenLocations()
    }
}
