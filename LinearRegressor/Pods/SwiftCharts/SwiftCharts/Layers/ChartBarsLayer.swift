//
//  ChartBarsLayer.swift
//  Examples
//
//  Created by ischuetz on 17/05/15.
//  Copyright (c) 2015 ivanschuetz. All rights reserved.
//

import UIKit

open class ChartBarModel {
    open let constant: ChartAxisValue
    open let axisValue1: ChartAxisValue
    open let axisValue2: ChartAxisValue
    open let bgColor: UIColor?

    /**
    - parameter constant:Value of coordinate which doesn't change between start and end of the bar - if the bar is horizontal, this is y, if it's vertical it's x.
    - parameter axisValue1:Start, variable coordinate.
    - parameter axisValue2:End, variable coordinate.
    - parameter bgColor:Background color of bar.
    */
    public init(constant: ChartAxisValue, axisValue1: ChartAxisValue, axisValue2: ChartAxisValue, bgColor: UIColor? = nil) {
        self.constant = constant
        self.axisValue1 = axisValue1
        self.axisValue2 = axisValue2
        self.bgColor = bgColor
    }
}

class ChartBarsViewGenerator<T: ChartBarModel, U: ChartPointViewBar> {
    let layer: ChartCoordsSpaceLayer
    let barWidth: CGFloat
    
    let horizontal: Bool
    
    let viewGenerator: ChartBarsLayer<U>.ChartBarViewGenerator?
    
    init(horizontal: Bool, layer: ChartCoordsSpaceLayer, barWidth: CGFloat, viewGenerator: ChartBarsLayer<U>.ChartBarViewGenerator?) {
        self.layer = layer
        self.horizontal = horizontal
        self.barWidth = barWidth
        self.viewGenerator = viewGenerator
    }
    
    func viewPoints(_ barModel: T, constantScreenLoc: CGFloat) -> (p1: CGPoint, p2: CGPoint) {
        switch horizontal {
        case true:
            return (
                CGPoint(x: layer.modelLocToScreenLoc(x: barModel.axisValue1.scalar), y: constantScreenLoc),
                CGPoint(x: layer.modelLocToScreenLoc(x: barModel.axisValue2.scalar), y: constantScreenLoc))
        case false:
            return (
                CGPoint(x: constantScreenLoc, y: layer.modelLocToScreenLoc(y: barModel.axisValue1.scalar)),
                CGPoint(x: constantScreenLoc, y: layer.modelLocToScreenLoc(y: barModel.axisValue2.scalar)))
        }
    }
    
    func constantScreenLoc(_ barModel: T) -> CGFloat {
        return horizontal ? layer.modelLocToScreenLoc(y: barModel.constant.scalar) : layer.modelLocToScreenLoc(x: barModel.constant.scalar)
    }
    
    func viewPoints(_ barModel: T, constantScreenLoc constantScreenLocMaybe: CGFloat? = nil) -> (p1: CGPoint, p2: CGPoint) {
        let constantScreenLoc = constantScreenLocMaybe ?? self.constantScreenLoc(barModel)
        return viewPoints(barModel, constantScreenLoc: constantScreenLoc)
    }
    
    func generateView(_ barModel: T, constantScreenLoc constantScreenLocMaybe: CGFloat? = nil, bgColor: UIColor?, settings: ChartBarViewSettings, model: ChartBarModel, index: Int, groupIndex: Int, chart: Chart? = nil) -> U {
        let viewPoints = self.viewPoints(barModel, constantScreenLoc: constantScreenLocMaybe)
        return viewGenerator?(viewPoints.p1, viewPoints.p2, barWidth, bgColor, settings, model, index) ??
            U(p1: viewPoints.p1, p2: viewPoints.p2, width: barWidth, bgColor: bgColor, settings: settings)
    }
}


public struct ChartTappedBar {
    public let model: ChartBarModel
    public let view: ChartPointViewBar
    public let layer: ChartCoordsSpaceLayer
}


open class ChartBarsLayer<T: ChartPointViewBar>: ChartCoordsSpaceLayer {
    
    public typealias ChartBarViewGenerator = (_ p1: CGPoint, _ p2: CGPoint, _ width: CGFloat, _ bgColor: UIColor?, _ settings: ChartBarViewSettings, _ model: ChartBarModel, _ index: Int) -> T
    
    fileprivate let bars: [ChartBarModel]
    fileprivate let barWidth: CGFloat
    fileprivate let horizontal: Bool
    fileprivate let settings: ChartBarViewSettings
    
    fileprivate var barViews: [(model: ChartBarModel, view: T)] = []
    
    fileprivate var tapHandler: ((ChartTappedBar) -> Void)?
    
    fileprivate var viewGenerator: ChartBarViewGenerator? // Custom bar views
    
    fileprivate let mode: ChartPointsViewsLayerMode
    
    fileprivate var barsGenerator: ChartBarsViewGenerator<ChartBarModel, T>?
    
    public init(xAxis: ChartAxis, yAxis: ChartAxis, bars: [ChartBarModel], horizontal: Bool = false, barWidth: CGFloat, settings: ChartBarViewSettings, mode: ChartPointsViewsLayerMode = .scaleAndTranslate, tapHandler: ((ChartTappedBar) -> Void)? = nil, viewGenerator: ChartBarViewGenerator? = nil) {
        self.bars = bars
        self.horizontal = horizontal
        self.barWidth = barWidth
        self.settings = settings
        self.mode = mode
        self.tapHandler = tapHandler
        self.viewGenerator = viewGenerator
        
        super.init(xAxis: xAxis, yAxis: yAxis)
        
        barsGenerator = ChartBarsViewGenerator(horizontal: horizontal, layer: self, barWidth: barWidth, viewGenerator: viewGenerator)
    }
    
    open override func chartInitialized(chart: Chart) {
        super.chartInitialized(chart: chart)
        
        guard let barsGenerator = barsGenerator else {return}
        
        for (index, barModel) in bars.enumerated() {
            let barView = barsGenerator.generateView(barModel, bgColor: barModel.bgColor, settings: settings, model: barModel, index: index, groupIndex: 0, chart: chart)
            barView.tapHandler = {[weak self] tappedBarView in guard let weakSelf = self else {return}
                weakSelf.tapHandler?(ChartTappedBar(model: barModel, view: tappedBarView, layer: weakSelf))
            }
        
            barViews.append((barModel, barView))
            
            addSubview(chart, view: barView)
        }
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
    
    func updateForTransform() {
        guard let barsGenerator = barsGenerator else {return}
        switch mode {
        case .scaleAndTranslate:
            break
        case .translate:
            for (barModel, barView) in barViews {
                let (p1, p2) = barsGenerator.viewPoints(barModel)
                barView.updateFrame(p1, p2: p2)
            }
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
