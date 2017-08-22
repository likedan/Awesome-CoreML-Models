//
//  ChartPointsCandleStickViewsLayer.swift
//  SwiftCharts
//
//  Created by ischuetz on 29/04/15.
//  Copyright (c) 2015 ivanschuetz. All rights reserved.
//

import UIKit

open class ChartPointsCandleStickViewsLayer<T: ChartPointCandleStick, U: ChartCandleStickView>: ChartPointsViewsLayer<ChartPointCandleStick, ChartCandleStickView> {

    public init(xAxis: ChartAxis, yAxis: ChartAxis, innerFrame: CGRect, chartPoints: [T], viewGenerator: @escaping ChartPointViewGenerator) {
        super.init(xAxis: xAxis, yAxis: yAxis, chartPoints: chartPoints, viewGenerator: viewGenerator)
    }
    
    open func highlightChartpointView(screenLoc: CGPoint) {
        let  x = screenLoc.x
        for viewWithChartPoint in viewsWithChartPoints {
            let view = viewWithChartPoint.view
            let originX = view.frame.origin.x
            view.highlighted = x > originX && x < originX + view.frame.width
        }
    }
}
