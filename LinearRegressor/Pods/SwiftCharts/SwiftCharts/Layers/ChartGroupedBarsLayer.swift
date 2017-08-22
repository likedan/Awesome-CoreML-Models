//
//  ChartGroupedBarsLayer.swift
//  Examples
//
//  Created by ischuetz on 19/05/15.
//  Copyright (c) 2015 ivanschuetz. All rights reserved.
//

import UIKit

public final class ChartPointsBarGroup<T: ChartBarModel> {
    public let constant: ChartAxisValue
    public let bars: [T]
    
    public init(constant: ChartAxisValue, bars: [T]) {
        self.constant = constant
        self.bars = bars
    }
}


open class ChartGroupedBarsLayer<T: ChartBarModel, U: ChartPointViewBar>: ChartCoordsSpaceLayer {

    fileprivate let groups: [ChartPointsBarGroup<T>]
    
    fileprivate let barWidth: CGFloat?
    fileprivate let barSpacing: CGFloat?
    fileprivate let groupSpacing: CGFloat?
    
    public let horizontal: Bool
    
    fileprivate let settings: ChartBarViewSettings
    
    open fileprivate(set) var groupViews: [(ChartPointsBarGroup<T>, [ChartPointViewBar])] = []
    
    fileprivate let mode: ChartPointsViewsLayerMode
    
    fileprivate let viewGenerator: ChartBarsLayer<U>.ChartBarViewGenerator?
    
    convenience init(xAxis: ChartAxis, yAxis: ChartAxis, groups: [ChartPointsBarGroup<T>], horizontal: Bool = false, barSpacing: CGFloat?, groupSpacing: CGFloat?, settings: ChartBarViewSettings, mode: ChartPointsViewsLayerMode = .scaleAndTranslate, viewGenerator: ChartBarsLayer<U>.ChartBarViewGenerator? = nil) {
        self.init(xAxis: xAxis, yAxis: yAxis, groups: groups, horizontal: horizontal, barWidth: nil, barSpacing: barSpacing, groupSpacing: groupSpacing, settings: settings, mode: mode, viewGenerator: viewGenerator)
    }
    
    init(xAxis: ChartAxis, yAxis: ChartAxis, groups: [ChartPointsBarGroup<T>], horizontal: Bool = false, barWidth: CGFloat?, barSpacing: CGFloat?, groupSpacing: CGFloat?, settings: ChartBarViewSettings, mode: ChartPointsViewsLayerMode = .scaleAndTranslate, viewGenerator: ChartBarsLayer<U>.ChartBarViewGenerator? = nil) {
        self.groups = groups
        self.horizontal = horizontal
        self.barWidth = barWidth
        self.barSpacing = barSpacing
        self.groupSpacing = groupSpacing
        self.settings = settings
        self.mode = mode
        self.viewGenerator = viewGenerator
        
        super.init(xAxis: xAxis, yAxis: yAxis)
    }
    
    func barsGenerator(barWidth: CGFloat, chart: Chart) -> ChartBarsViewGenerator<T, U> {
        fatalError("override")
    }
    
    open override func chartInitialized(chart: Chart) {
        super.chartInitialized(chart: chart)
        if !settings.delayInit {
            initBars(chart)
        }
    }
    
    open func initBars(_ chart: Chart) {
        calculateDimensions(chart) {maxBarCountInGroup, barWidth in
            let barsGenerator = self.barsGenerator(barWidth: barWidth, chart: chart)
            
            for (groupIndex, group) in self.groups.enumerated() {
                var groupBars = [ChartPointViewBar]()
                for (barIndex, bar) in group.bars.enumerated() {
                    
                    let constantScreenLoc = self.calculateConstantScreenLocDir({self.modelLocToScreenLoc(y: $0)}, index: barIndex, group: group, barWidth: barWidth, maxBarCountInGroup: maxBarCountInGroup, horizontal: barsGenerator.horizontal)
                    let barView = barsGenerator.generateView(bar, constantScreenLoc: constantScreenLoc, bgColor: bar.bgColor, settings: self.settings, model: bar, index: barIndex, groupIndex: groupIndex)
                    self.configBarView(group, groupIndex: groupIndex, barIndex: barIndex, bar: bar, barView: barView)
                    groupBars.append(barView)
                    self.addSubview(chart, view: barView)
                }
                self.groupViews.append((group, groupBars))
            }
        }
    }
    
    func calculateConstantScreenLoc(_ screenLocCalculator: (Double) -> CGFloat, index: Int, group: ChartPointsBarGroup<T>, barWidth: CGFloat, maxBarCountInGroup: CGFloat) -> CGFloat {
        let totalWidth = CGFloat(group.bars.count) * barWidth + ((barSpacing ?? 0) * (maxBarCountInGroup - 1))
        let groupCenter = screenLocCalculator(group.constant.scalar)
        let origin = groupCenter - totalWidth / 2
        return origin + CGFloat(index) * (barWidth + (barSpacing ?? 0)) + barWidth / 2
    }
    
    func mooh(_ screenLocCalculator: (Double) -> CGFloat, index: Int, group: ChartPointsBarGroup<T>, barWidth: CGFloat, maxBarCountInGroup: CGFloat, horizontal: Bool) -> CGFloat {
        return 1
    }
    
    func calculateConstantScreenLocDir(_ screenLocCalculator: (Double) -> CGFloat, index: Int, group: ChartPointsBarGroup<T>, barWidth: CGFloat, maxBarCountInGroup: CGFloat, horizontal: Bool) -> CGFloat {
        if horizontal {
            return calculateConstantScreenLoc({modelLocToScreenLoc(y: $0)}, index: index, group: group, barWidth: barWidth, maxBarCountInGroup: maxBarCountInGroup)
        } else {
            return calculateConstantScreenLoc({modelLocToScreenLoc(x: $0)}, index: index, group: group, barWidth: barWidth, maxBarCountInGroup: maxBarCountInGroup)
        }
    }
    
    fileprivate func calculateDimensions(_ chart: Chart, onCalculate: (_ maxBarCountInGroup: CGFloat, _ barWidth: CGFloat) -> Void) {
        
        let axis = horizontal ? yAxis : xAxis
        let groupAvailableLength = (axis.screenLength  - (groupSpacing ?? 0) * CGFloat(groups.count)) / CGFloat(groups.count + 1)
        let maxBarCountInGroup = groups.reduce(CGFloat(0)) {maxCount, group in
            max(maxCount, CGFloat(group.bars.count))
        }
        
        let barWidth = self.barWidth ?? (((groupAvailableLength - ((barSpacing ?? 0) * (maxBarCountInGroup - 1))) / CGFloat(maxBarCountInGroup)))
  
        onCalculate(maxBarCountInGroup, barWidth)
    }
    
    func configBarView(_ group: ChartPointsBarGroup<T>, groupIndex: Int, barIndex: Int, bar: T, barView: U) {
//        barView.selectionViewUpdater = selectionViewUpdater
    }
    
    func addSubview(_ chart: Chart, view: UIView) {
        mode == .scaleAndTranslate ? chart.addSubview(view) : chart.addSubviewNoTransform(view)
    }
    
    open override func zoom(_ x: CGFloat, y: CGFloat, centerX: CGFloat, centerY: CGFloat) {
        super.zoom(x, y: y, centerX: centerX, centerY: centerY)
        updateForTransform()
    }
    
    open override func pan(_ deltaX: CGFloat, deltaY: CGFloat) {
        super.pan(deltaX, deltaY: deltaY)
        updateForTransform()
    }
    
    fileprivate func updatePanZoomTranslateMode() {
        guard let chart = chart else {return}
        
        calculateDimensions(chart) {maxBarCountInGroup, barWidth in
            let barsGenerator = self.barsGenerator(barWidth: barWidth, chart: chart)
            for (groupIndex, group) in self.groups.enumerated() {
                for (barIndex, bar) in group.bars.enumerated() {
                    let constantScreenLoc = self.calculateConstantScreenLocDir({self.modelLocToScreenLoc(y: $0)}, index: barIndex, group: group, barWidth: barWidth, maxBarCountInGroup: maxBarCountInGroup, horizontal: barsGenerator.horizontal)
                    
                    if groupIndex < self.groupViews.count {
                        let groupViews = self.groupViews[groupIndex].1
                        if barIndex < groupViews.count {
                            let barView = groupViews[barIndex]
                            let (p1, p2) = barsGenerator.viewPoints(bar, constantScreenLoc: constantScreenLoc)
                            barView.updateFrame(p1, p2: p2)
                            barView.setNeedsDisplay()
                        }
                    }
                }
            }
        }
    }
    
    func updateForTransform() {
        switch mode {
        case .scaleAndTranslate: break
        case .translate: updatePanZoomTranslateMode()
        case .custom: fatalError("Not supported")
        }
    }
    
    open override func modelLocToScreenLoc(x: Double) -> CGFloat {
        switch mode {
        case .scaleAndTranslate:
            return super.modelLocToScreenLoc(x: x)
        case .translate:
            return super.modelLocToContainerScreenLoc(x: x)
        case .custom: fatalError("Not supported")
        }
    }
    
    open override func modelLocToScreenLoc(y: Double) -> CGFloat {
        switch mode {
        case .scaleAndTranslate:
            return super.modelLocToScreenLoc(y: y)
        case .translate:
            return super.modelLocToContainerScreenLoc(y: y)
        case .custom: fatalError("Not supported")
        }
    }

}


public struct ChartTappedGroupBar {
    public let tappedBar: ChartTappedBar
    public let group: ChartPointsBarGroup<ChartBarModel>
    public let groupIndex: Int
    public let barIndex: Int // in group
    public let layer: ChartGroupedBarsLayer<ChartBarModel, ChartPointViewBar>
}

public typealias ChartGroupedPlainBarsLayer = ChartGroupedPlainBarsLayer_<Any>
open class ChartGroupedPlainBarsLayer_<N>: ChartGroupedBarsLayer<ChartBarModel, ChartPointViewBar> {
    
    let tapHandler: ((ChartTappedGroupBar) -> Void)?
    
    public convenience init(xAxis: ChartAxis, yAxis: ChartAxis, groups: [ChartPointsBarGroup<ChartBarModel>], horizontal: Bool = false, barSpacing: CGFloat?, groupSpacing: CGFloat?, settings: ChartBarViewSettings, mode: ChartPointsViewsLayerMode = .scaleAndTranslate, tapHandler: ((ChartTappedGroupBar) -> Void)? = nil, viewGenerator: ChartBarsLayer<ChartPointViewBar>.ChartBarViewGenerator? = nil) {
        self.init(xAxis: xAxis, yAxis: yAxis, groups: groups, horizontal: horizontal, barWidth: nil, barSpacing: barSpacing, groupSpacing: groupSpacing, settings: settings, mode: mode, tapHandler: tapHandler, viewGenerator: viewGenerator)
    }
    
    public init(xAxis: ChartAxis, yAxis: ChartAxis, groups: [ChartPointsBarGroup<ChartBarModel>], horizontal: Bool, barWidth: CGFloat?, barSpacing: CGFloat?, groupSpacing: CGFloat?, settings: ChartBarViewSettings, mode: ChartPointsViewsLayerMode = .scaleAndTranslate, tapHandler: ((ChartTappedGroupBar) -> Void)? = nil, viewGenerator: ChartBarsLayer<ChartPointViewBar>.ChartBarViewGenerator? = nil) {
        self.tapHandler = tapHandler
        super.init(xAxis: xAxis, yAxis: yAxis, groups: groups, horizontal: horizontal, barWidth: barWidth, barSpacing: barSpacing, groupSpacing: groupSpacing, settings: settings, mode: mode, viewGenerator: viewGenerator)
    }
    
    override func barsGenerator(barWidth: CGFloat, chart: Chart) -> ChartBarsViewGenerator<ChartBarModel, ChartPointViewBar> {
        return ChartBarsViewGenerator(horizontal: self.horizontal, layer: self, barWidth: barWidth, viewGenerator: viewGenerator)
    }
    
    override func configBarView(_ group: ChartPointsBarGroup<ChartBarModel>, groupIndex: Int, barIndex: Int, bar: ChartBarModel, barView: ChartPointViewBar) {
        super.configBarView(group, groupIndex: groupIndex, barIndex: barIndex, bar: bar, barView: barView)
        
        barView.tapHandler = {[weak self] _ in guard let weakSelf = self else {return}
            let tappedBar = ChartTappedBar(model: bar, view: barView, layer: weakSelf)
            let tappedGroupBar = ChartTappedGroupBar(tappedBar: tappedBar, group: group, groupIndex: groupIndex, barIndex: barIndex, layer: weakSelf)
            weakSelf.tapHandler?(tappedGroupBar)
        }
    }
}


public struct ChartTappedGroupBarStacked {
    public let tappedBar: ChartTappedBarStacked
    public let group: ChartPointsBarGroup<ChartStackedBarModel>
    public let groupIndex: Int
    public let barIndex: Int // in group
}

public typealias ChartGroupedStackedBarsLayer = ChartGroupedStackedBarsLayer_<Any>
open class ChartGroupedStackedBarsLayer_<N>: ChartGroupedBarsLayer<ChartStackedBarModel, ChartPointViewBarStacked> {
    fileprivate let stackFrameSelectionViewUpdater: ChartViewSelector?
    let tapHandler: ((ChartTappedGroupBarStacked) -> Void)?
    
    fileprivate let stackedViewGenerator: ChartStackedBarsLayer<ChartPointViewBarStacked>.ChartBarViewGenerator?
    
    public convenience init(xAxis: ChartAxis, yAxis: ChartAxis, groups: [ChartPointsBarGroup<ChartStackedBarModel>], horizontal: Bool = false, barSpacing: CGFloat?, groupSpacing: CGFloat?, settings: ChartBarViewSettings, mode: ChartPointsViewsLayerMode = .scaleAndTranslate, stackFrameSelectionViewUpdater: ChartViewSelector? = nil, tapHandler: ((ChartTappedGroupBarStacked) -> Void)? = nil, viewGenerator: ChartStackedBarsLayer<ChartPointViewBarStacked>.ChartBarViewGenerator? = nil) {
        self.init(xAxis: xAxis, yAxis: yAxis, groups: groups, horizontal: horizontal, barWidth: nil, barSpacing: barSpacing, groupSpacing: groupSpacing, settings: settings, mode: mode, stackFrameSelectionViewUpdater: stackFrameSelectionViewUpdater, tapHandler: tapHandler, viewGenerator: viewGenerator)
    }
    
    public init(xAxis: ChartAxis, yAxis: ChartAxis, groups: [ChartPointsBarGroup<ChartStackedBarModel>], horizontal: Bool, barWidth: CGFloat?, barSpacing: CGFloat?, groupSpacing: CGFloat?, settings: ChartBarViewSettings, mode: ChartPointsViewsLayerMode = .scaleAndTranslate, stackFrameSelectionViewUpdater: ChartViewSelector? = nil, tapHandler: ((ChartTappedGroupBarStacked) -> Void)? = nil, viewGenerator: ChartStackedBarsLayer<ChartPointViewBarStacked>.ChartBarViewGenerator? = nil) {
        self.stackFrameSelectionViewUpdater = stackFrameSelectionViewUpdater
        self.tapHandler = tapHandler
        self.stackedViewGenerator = viewGenerator
        super.init(xAxis: xAxis, yAxis: yAxis, groups: groups, horizontal: horizontal, barWidth: barWidth, barSpacing: barSpacing, groupSpacing: groupSpacing, settings: settings, mode: mode)
    }
    
    override func barsGenerator(barWidth: CGFloat, chart: Chart) -> ChartBarsViewGenerator<ChartStackedBarModel, ChartPointViewBarStacked> {
        return ChartStackedBarsViewGenerator(horizontal: horizontal, layer: self, barWidth: barWidth, viewGenerator: stackedViewGenerator)
    }
    
    override func configBarView(_ group: ChartPointsBarGroup<ChartStackedBarModel>, groupIndex: Int, barIndex: Int, bar: ChartStackedBarModel, barView: ChartPointViewBarStacked) {
        barView.stackedTapHandler = {[weak self, unowned barView] tappedStackedBar in guard let weakSelf = self else {return}
            
            let stackFrameData = tappedStackedBar.stackFrame.map{stackFrame in
                ChartTappedBarStackedFrame(stackedItemModel: bar.items[stackFrame.index], stackedItemView: stackFrame.view, stackedItemViewFrameRelativeToBarParent: stackFrame.viewFrameRelativeToBarSuperview, stackedItemIndex: stackFrame.index)
            }
            
            let tappedStacked = ChartTappedBarStacked(model: bar, barView: barView, stackFrameData: stackFrameData, layer: weakSelf)
            let tappedGroupBar = ChartTappedGroupBarStacked(tappedBar: tappedStacked, group: group, groupIndex: groupIndex, barIndex: barIndex)
            weakSelf.tapHandler?(tappedGroupBar)
        }
        barView.stackFrameSelectionViewUpdater = stackFrameSelectionViewUpdater
    }
}
