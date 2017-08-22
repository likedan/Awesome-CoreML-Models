//
//  ChartPointsSingleViewLayer.swift
//  swift_charts
//
//  Created by ischuetz on 19/04/15.
//  Copyright (c) 2015 ivanschuetz. All rights reserved.
//

import UIKit

// Layer that shows only one view at a time
open class ChartPointsSingleViewLayer<T: ChartPoint, U: UIView>: ChartPointsViewsLayer<T, U> {
    
    fileprivate var addedViews: [UIView] = []

    fileprivate var activeChartPoint: T?
    
    public init(xAxis: ChartAxis, yAxis: ChartAxis, innerFrame: CGRect, chartPoints: [T], viewGenerator: @escaping ChartPointViewGenerator, mode: ChartPointsViewsLayerMode = .scaleAndTranslate, keepOnFront: Bool = true) {
        super.init(xAxis: xAxis, yAxis: yAxis, chartPoints: chartPoints, viewGenerator: viewGenerator, mode: mode, keepOnFront: keepOnFront)
    }

    override open func display(chart: Chart) {
        // skip adding views - this layer manages its own list
    }
    
    open func showView(chartPoint: T, chart: Chart) {
    
        activeChartPoint = chartPoint
        
        for view in addedViews {
            view.removeFromSuperview()
        }
        
        let screenLoc = chartPointScreenLoc(chartPoint)
        let index = chartPointsModels.map{$0.chartPoint}.index(of: chartPoint)!
        let model: ChartPointLayerModel = ChartPointLayerModel(chartPoint: chartPoint, index: index, screenLoc: screenLoc)
        if let view = viewGenerator(model, self, chart) {
            addedViews.append(view)
            addSubview(chart, view: view)
            
            viewsWithChartPoints = [ViewWithChartPoint(view: view, chartPointModel: model)]
        }
    }
}
