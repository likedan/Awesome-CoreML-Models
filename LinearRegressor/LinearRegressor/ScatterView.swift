//
//  ScatterExample.swift
//  Examples
//
//  Created by ischuetz on 17/05/15.
//  Copyright (c) 2015 ivanschuetz. All rights reserved.
//

import UIKit
import SwiftCharts

private enum MyExampleModelDataType {
    case type0, type1, type2, type3
}

private enum Shape {
    case triangle, square, circle, cross
}

class ScatterView {

    var chart: Chart?
    
    func renderWithData(x: [Double], y: [Double], frame: CGRect) {
        let labelSettings = ChartLabelSettings()
        
        var models = [(x: Double, y: Double, type: MyExampleModelDataType)]()
        for index in 0...x.count - 1 {
            models.append((x[index], y[index], .type2))
        }
        
        let layerSpecifications: [MyExampleModelDataType : (shape: Shape, color: UIColor)] = [
            .type0 : (.triangle, UIColor.red),
            .type1 : (.square, UIColor.green),
            .type2 : (.circle, UIColor.blue),
            .type3 : (.cross, UIColor.black)
        ]
        
        
        let xValues = stride(from: 0, through: 50, by: 10).map {ChartAxisValueInt($0, labelSettings: labelSettings)}
        let yValues = stride(from: 0, through: 50, by: 10).map {ChartAxisValueInt($0, labelSettings: labelSettings)}
        
        let xModel = ChartAxisModel(axisValues: xValues, axisTitleLabel: ChartAxisLabel(text: "Predicted", settings: labelSettings))
        let yModel = ChartAxisModel(axisValues: yValues, axisTitleLabel: ChartAxisLabel(text: "Measured", settings: labelSettings.defaultVertical()))
        
        let coordsSpace = ChartCoordsSpaceLeftBottomSingleAxis(chartSettings: ChartSettings(), chartFrame: frame, xModel: xModel, yModel: yModel)
        let (xAxisLayer, yAxisLayer, innerFrame) = (coordsSpace.xAxisLayer, coordsSpace.yAxisLayer, coordsSpace.chartInnerFrame)
        
        let scatterLayers = toLayers(models, layerSpecifications: layerSpecifications, xAxis: xAxisLayer, yAxis: yAxisLayer, chartInnerFrame: innerFrame)
        
        let guidelinesLayerSettings = ChartGuideLinesDottedLayerSettings(linesColor: UIColor.black, linesWidth: 1)
        let guidelinesLayer = ChartGuideLinesDottedLayer(xAxisLayer: xAxisLayer, yAxisLayer: yAxisLayer, settings: guidelinesLayerSettings)
        
        let settings = ChartSettings()
        let chart = Chart(
            frame: frame,
            innerFrame: innerFrame,
            settings: ChartSettings(),
            layers: [
                xAxisLayer,
                yAxisLayer,
                guidelinesLayer
                ] + scatterLayers
        )
        
        self.chart = chart
    }

    fileprivate func toLayers(_ models: [(x: Double, y: Double, type: MyExampleModelDataType)], layerSpecifications: [MyExampleModelDataType : (shape: Shape, color: UIColor)], xAxis: ChartAxisLayer, yAxis: ChartAxisLayer, chartInnerFrame: CGRect) -> [ChartLayer] {
        
        // group chartpoints by type
        var groupedChartPoints: Dictionary<MyExampleModelDataType, [ChartPoint]> = [:]
        for model in models {
            let chartPoint = ChartPoint(x: ChartAxisValueDouble(model.x), y: ChartAxisValueDouble(model.y))
            if groupedChartPoints[model.type] != nil {
                groupedChartPoints[model.type]!.append(chartPoint)
                
            } else {
                groupedChartPoints[model.type] = [chartPoint]
            }
        }

        let tapSettings = ChartPointsTapSettings()
        
        // create layer for each group
        let dim: CGFloat = 7
        let size = CGSize(width: dim, height: dim)
        let layers: [ChartLayer] = groupedChartPoints.map {(type, chartPoints) in
            let layerSpecification = layerSpecifications[type]!
            switch layerSpecification.shape {
                case .triangle:
                    return ChartPointsScatterTrianglesLayer(xAxis: xAxis.axis, yAxis: yAxis.axis, chartPoints: chartPoints, itemSize: size, itemFillColor: layerSpecification.color, tapSettings: tapSettings)
                case .square:
                    return ChartPointsScatterSquaresLayer(xAxis: xAxis.axis, yAxis: yAxis.axis, chartPoints: chartPoints, itemSize: size, itemFillColor: layerSpecification.color, tapSettings: tapSettings)
                case .circle:
                    return ChartPointsScatterCirclesLayer(xAxis: xAxis.axis, yAxis: yAxis.axis, chartPoints: chartPoints, itemSize: size, itemFillColor: layerSpecification.color, tapSettings: tapSettings)
                case .cross:
                    return ChartPointsScatterCrossesLayer(xAxis: xAxis.axis, yAxis: yAxis.axis, chartPoints: chartPoints, itemSize: size, itemFillColor: layerSpecification.color, tapSettings: tapSettings)
            }
        }
        
        return layers
    }
}
