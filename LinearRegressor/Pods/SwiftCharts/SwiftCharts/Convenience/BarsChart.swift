//
//  BarsChart.swift
//  Examples
//
//  Created by ischuetz on 19/07/15.
//  Copyright (c) 2015 ivanschuetz. All rights reserved.
//

import UIKit

open class BarsChartConfig: ChartConfig {
    open let valsAxisConfig: ChartAxisConfig
    open let xAxisLabelSettings: ChartLabelSettings
    open let yAxisLabelSettings: ChartLabelSettings
    
    public init(chartSettings: ChartSettings = ChartSettings(), valsAxisConfig: ChartAxisConfig, xAxisLabelSettings: ChartLabelSettings = ChartLabelSettings(), yAxisLabelSettings: ChartLabelSettings = ChartLabelSettings(), guidelinesConfig: GuidelinesConfig = GuidelinesConfig()) {
        self.valsAxisConfig = valsAxisConfig
        self.xAxisLabelSettings = xAxisLabelSettings
        self.yAxisLabelSettings = yAxisLabelSettings
        
        super.init(chartSettings: chartSettings, guidelinesConfig: guidelinesConfig)
    }
}

open class BarsChart: Chart {
    
    public init(frame: CGRect, chartConfig: BarsChartConfig, xTitle: String, yTitle: String, bars barModels: [(String, Double)], color: UIColor, barWidth: CGFloat, animDuration: Float = 0.5, animDelay: Float = 0.5, horizontal: Bool = false) {
        
        let zero = ChartAxisValueDouble(0)
        let bars: [ChartBarModel] = barModels.enumerated().map {let (index, barModel) = $0;
            return ChartBarModel(constant: ChartAxisValueDouble(index), axisValue1: zero, axisValue2: ChartAxisValueDouble(barModel.1), bgColor: color)
        }
        
        let valAxisValues = stride(from: chartConfig.valsAxisConfig.from, through: chartConfig.valsAxisConfig.to, by: chartConfig.valsAxisConfig.by).map{ChartAxisValueDouble($0, labelSettings : chartConfig.xAxisLabelSettings)}
        let labelAxisValues = [ChartAxisValueString(order: -1)] + barModels.enumerated().map{ let (index, tuple) = $0; return ChartAxisValueString(tuple.0, order: index, labelSettings : chartConfig.xAxisLabelSettings)} + [ChartAxisValueString(order: barModels.count)]

        let (xValues, yValues): ([ChartAxisValue], [ChartAxisValue]) = horizontal ? (valAxisValues, labelAxisValues) : (labelAxisValues, valAxisValues)
        
        let xModel = ChartAxisModel(axisValues: xValues, axisTitleLabel: ChartAxisLabel(text: xTitle, settings: chartConfig.xAxisLabelSettings))
        let yModel = ChartAxisModel(axisValues: yValues, axisTitleLabel: ChartAxisLabel(text: yTitle, settings: chartConfig.xAxisLabelSettings.defaultVertical()))
        let coordsSpace = ChartCoordsSpaceLeftBottomSingleAxis(chartSettings: chartConfig.chartSettings, chartFrame: frame, xModel: xModel, yModel: yModel)
        let (xAxisLayer, yAxisLayer, innerFrame) = (coordsSpace.xAxisLayer, coordsSpace.yAxisLayer, coordsSpace.chartInnerFrame)
        
        let barViewSettings = ChartBarViewSettings(animDuration: animDuration, animDelay: animDelay)
        
        let barsLayer: ChartLayer = ChartBarsLayer(xAxis: xAxisLayer.axis, yAxis: yAxisLayer.axis, bars: bars, horizontal: horizontal, barWidth: barWidth, settings: barViewSettings)
        
        let guidelinesLayer = GuidelinesDefaultLayerGenerator.generateOpt(xAxisLayer: xAxisLayer, yAxisLayer: yAxisLayer, guidelinesConfig: chartConfig.guidelinesConfig)
        
        let view = ChartBaseView(frame: frame)
        let layers: [ChartLayer] = [xAxisLayer, yAxisLayer] + (guidelinesLayer.map{[$0]} ?? []) + [barsLayer]
      
        super.init(
            view: view,
            innerFrame: innerFrame,
            settings: chartConfig.chartSettings,
            layers: layers
        )
    }
    
    public required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
