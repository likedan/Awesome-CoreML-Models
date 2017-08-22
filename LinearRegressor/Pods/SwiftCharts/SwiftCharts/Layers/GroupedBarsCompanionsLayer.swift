//
//  GroupedBarsCompanionsLayer.swift
//  SwiftCharts
//
//  Created by ischuetz on 07/10/16.
//  Copyright (c) 2016 ivanschuetz. All rights reserved.
//

import UIKit

/**
 Allows to add views to chart which require grouped bars position. E.g. a label on top of each bar.
 It works by holding a reference to the grouped bars layer and requesting the position of the bars on updates
 We use a custom layer, since screen position of a grouped bar can't be derived directly from the chart point it represents. We need other factors like the passed spacing parameters, the width of the bars, etc. It seems convenient to implement an "observer" for current position of bars.
 NOTE: has to be passed to the chart after the grouped bars layer, in the layers array, in order to get its updated state.
 */
open class GroupedBarsCompanionsLayer<U: UIView>: ChartPointsLayer<ChartPoint> {
    
    public typealias CompanionViewGenerator = (_ barModel: ChartBarModel, _ barIndex: Int, _ viewIndex: Int, _ barView: UIView, _ layer: GroupedBarsCompanionsLayer<U>, _ chart: Chart) -> U?
    
    public typealias ViewUpdater = (_ barModel: ChartBarModel, _ barIndex: Int, _ viewIndex: Int, _ barView: UIView, _ layer: GroupedBarsCompanionsLayer<U>, _ chart: Chart, _ companionView: U) -> Void
    
    fileprivate let groupedBarsLayer: ChartGroupedStackedBarsLayer
    
    fileprivate let viewGenerator: CompanionViewGenerator
    fileprivate let viewUpdater: ViewUpdater
    
    fileprivate let delayInit: Bool
    
    fileprivate var companionViews: [U] = []
    
    public init(xAxis: ChartAxis, yAxis: ChartAxis, viewGenerator: @escaping CompanionViewGenerator, viewUpdater: @escaping ViewUpdater, groupedBarsLayer: ChartGroupedStackedBarsLayer, displayDelay: Float = 0, delayInit: Bool = false) {
        
        self.groupedBarsLayer = groupedBarsLayer
        self.viewGenerator = viewGenerator
        self.delayInit = delayInit
        self.viewUpdater = viewUpdater
        
        super.init(xAxis: xAxis, yAxis: yAxis, chartPoints: [], displayDelay: displayDelay)
    }
    
    override open func display(chart: Chart) {
        super.display(chart: chart)
        if !delayInit {
            initViews(chart, applyDelay: false)
        }
    }
    
    fileprivate func initViews(_ chart: Chart) {
        iterateBars {[weak self] (barModel, barIndex, viewIndex, barView) in guard let weakSelf = self else {return}
            if let companionView = weakSelf.viewGenerator(barModel, barIndex, viewIndex, barView, weakSelf, chart) {
                chart.addSubviewNoTransform(companionView)
                weakSelf.companionViews.append(companionView)
            }
        }
    }
    
    open func initViews(_ chart: Chart, applyDelay: Bool = true) {
        if applyDelay {
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + Double(Int64(Double(displayDelay) * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC)) {() -> Void in
                self.initViews(chart)
            }
        } else {
            initViews(chart)
        }
    }
    
    fileprivate func updatePositions() {
        
        guard let chart = chart else {return}
        
        iterateBars {[weak self] (barModel, barIndex, viewIndex, barView) in guard let weakSelf = self else {return}
            if viewIndex < weakSelf.companionViews.count {
                let companionView = weakSelf.companionViews[viewIndex]
                weakSelf.viewUpdater(barModel, barIndex, viewIndex, barView, weakSelf, chart, companionView)
            }
        }
    }
    
    fileprivate func iterateBars(_ f: (_ barModel: ChartBarModel, _ barIndex: Int, _ viewIndex: Int, _ barView: UIView) -> Void) {
        var viewIndex = 0
        for (group, barViews) in groupedBarsLayer.groupViews {
            for (barIndex, barModel) in group.bars.enumerated() {
                f(barModel, barIndex, viewIndex, barViews[barIndex])
                viewIndex += 1
            }
        }
    }
    
    open override func handlePanFinish() {
        super.handlePanEnd()
        updatePositions()
    }
    
    open override func handleZoomFinish() {
        super.handleZoomEnd()
        updatePositions()
    }
}
