//
//  ChartConfig.swift
//  Examples
//
//  Settings wrappers for default charts.
//  These charts are assumed to have one x axis at the bottom and one y axis at the left.
//
//  Created by ischuetz on 19/07/15.
//  Copyright (c) 2015 ivanschuetz. All rights reserved.
//

import UIKit

open class ChartConfig {
    open let chartSettings: ChartSettings
    open let guidelinesConfig: GuidelinesConfig? // nil means no guidelines
    
    public init(chartSettings: ChartSettings, guidelinesConfig: GuidelinesConfig?) {
        self.chartSettings = chartSettings
        self.guidelinesConfig = guidelinesConfig
    }
}


open class ChartConfigXY: ChartConfig {
    open let xAxisConfig: ChartAxisConfig
    open let yAxisConfig: ChartAxisConfig
    open let xAxisLabelSettings: ChartLabelSettings
    open let yAxisLabelSettings: ChartLabelSettings

    public init(chartSettings: ChartSettings = ChartSettings(), xAxisConfig: ChartAxisConfig, yAxisConfig: ChartAxisConfig, xAxisLabelSettings: ChartLabelSettings = ChartLabelSettings(), yAxisLabelSettings: ChartLabelSettings = ChartLabelSettings(), guidelinesConfig: GuidelinesConfig? = GuidelinesConfig()) {
        self.xAxisConfig = xAxisConfig
        self.yAxisConfig = yAxisConfig
        self.xAxisLabelSettings = xAxisLabelSettings
        self.yAxisLabelSettings = yAxisLabelSettings
        
        super.init(chartSettings: chartSettings, guidelinesConfig: guidelinesConfig)
    }
}

public struct ChartAxisConfig {
    public let from: Double
    public let to: Double
    public let by: Double
    
    public init(from: Double, to: Double, by: Double) {
        self.from = from
        self.to = to
        self.by = by
    }
}

public struct GuidelinesConfig {
    public let dotted: Bool
    public let lineWidth: CGFloat
    public let lineColor: UIColor
    
    public init(dotted: Bool = true, lineWidth: CGFloat = 0.1, lineColor: UIColor = UIColor.black) {
        self.dotted = dotted
        self.lineWidth = lineWidth
        self.lineColor = lineColor
    }
}

// Helper to generate default guidelines layer for GuidelinesConfig
public struct GuidelinesDefaultLayerGenerator {

    public static func generateOpt(xAxisLayer: ChartAxisLayer, yAxisLayer: ChartAxisLayer, guidelinesConfig: GuidelinesConfig?) -> ChartLayer? {
        if let guidelinesConfig = guidelinesConfig {
            return generate(xAxisLayer: xAxisLayer, yAxisLayer: yAxisLayer, guidelinesConfig: guidelinesConfig)
        } else {
            return nil
        }
    }
    
    public static func generate(xAxisLayer: ChartAxisLayer, yAxisLayer: ChartAxisLayer, guidelinesConfig: GuidelinesConfig) -> ChartLayer {
        if guidelinesConfig.dotted {
            let settings = ChartGuideLinesDottedLayerSettings(linesColor: guidelinesConfig.lineColor, linesWidth: guidelinesConfig.lineWidth)
            return ChartGuideLinesDottedLayer(xAxisLayer: xAxisLayer, yAxisLayer: yAxisLayer, settings: settings)
            
        } else {
            let settings = ChartGuideLinesDottedLayerSettings(linesColor: guidelinesConfig.lineColor, linesWidth: guidelinesConfig.lineWidth)
            return ChartGuideLinesDottedLayer(xAxisLayer: xAxisLayer, yAxisLayer: yAxisLayer, settings: settings)
        }
    }
}
