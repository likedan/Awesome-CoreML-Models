//
//  ChartCoordsSpace.swift
//  SwiftCharts
//
//  Created by ischuetz on 27/04/15.
//  Copyright (c) 2015 ivanschuetz. All rights reserved.
//

import UIKit

/**
 A ChartCoordsSpace calculates the chart's inner frame and generates the axis layers based on given axis models, chart size and chart settings. In doing so it's able to calculate the frame for the inner area of the chart where points, bars, lines, etc. are drawn to represent data.
 
 ````
                         ┌────────────────────────────────────────────────┐
                         │                ChartSettings.top               │
                         │  ┌────┬────────────────────────────────┬────┐  │
                         │  │    │                X               │    │  │
                         │  │    │               high             │    │  │
                         │  ├────┼────────────────────────────────┼────┤  │
                         │  │    │                                │    │  │
                         │  │    │                                │    │  │
                         │  │    │                                │    │  │
                         │  │    │                                │    │  │
 ChartSettings.leading ──┼▶ │ Y  │        Chart Inner Frame       │ Y  │ ◀┼── ChartSettings.trailing
                         │  │low │                                │high│  │
                         │  │    │                                │    │  │
                         │  │    │                                │    │  │
                         │  ├────┼────────────────────────────────┼────┤  │
                         │  │    │                X               │    │  │
                         │  │    │               low              │    │  │
                         │  └────┴────────────────────────────────┴────┘  │
                         │               ChartSettings.bottom             │
                         └────────────────────────────────────────────────┘
                         │─────────────────── chartSize ──────────────────│
 ````
 */
open class ChartCoordsSpace {
    
    public typealias ChartAxisLayerModel = (p1: CGPoint, p2: CGPoint, firstModelValue: Double, lastModelValue: Double, axisValuesGenerator: ChartAxisValuesGenerator, labelsGenerator: ChartAxisLabelsGenerator, axisTitleLabels: [ChartAxisLabel], settings: ChartAxisSettings, labelsConflictSolver: ChartAxisLabelsConflictSolver?, leadingPadding: ChartAxisPadding, trailingPadding: ChartAxisPadding, labelSpaceReservationMode: AxisLabelsSpaceReservationMode, clipContents: Bool)
    public typealias ChartAxisLayerGenerator = (ChartAxisLayerModel) -> ChartAxisLayer
    
    fileprivate let chartSettings: ChartSettings
    fileprivate let chartSize: CGSize
    
    open fileprivate(set) var chartInnerFrame: CGRect = CGRect.zero

    fileprivate let yLowModels: [ChartAxisModel]
    fileprivate let yHighModels: [ChartAxisModel]
    fileprivate let xLowModels: [ChartAxisModel]
    fileprivate let xHighModels: [ChartAxisModel]

    fileprivate let yLowGenerator: ChartAxisLayerGenerator
    fileprivate let yHighGenerator: ChartAxisLayerGenerator
    fileprivate let xLowGenerator: ChartAxisLayerGenerator
    fileprivate let xHighGenerator: ChartAxisLayerGenerator
    
    open fileprivate(set) var yLowAxesLayers: [ChartAxisLayer] = []
    open fileprivate(set) var yHighAxesLayers: [ChartAxisLayer] = []
    open fileprivate(set) var xLowAxesLayers: [ChartAxisLayer] = []
    open fileprivate(set) var xHighAxesLayers: [ChartAxisLayer] = []

    /**
     A convenience initializer with default axis layer generators

     - parameter chartSettings: The chart layout settings
     - parameter chartSize:     The desired size of the chart
     - parameter yLowModels:    The chart axis model used to generate the Y low axis
     - parameter yHighModels:   The chart axis model used to generate the Y high axis
     - parameter xLowModels:    The chart axis model used to generate the X low axis
     - parameter xHighModels:   The chart axis model used to generate the X high axis

     - returns: The coordinate space with generated axis layers
     */
    public convenience init(chartSettings: ChartSettings, chartSize: CGSize, yLowModels: [ChartAxisModel] = [], yHighModels: [ChartAxisModel] = [], xLowModels: [ChartAxisModel] = [], xHighModels: [ChartAxisModel] = []) {
        
        func calculatePaddingValues(_ axis: ChartAxis, model: ChartAxisLayerModel, dimensionExtractor: @escaping (CGSize) -> CGFloat) -> (CGFloat, CGFloat) {

            func paddingForAxisValue(_ axisValueMaybe: Double?) -> CGFloat {
                return axisValueMaybe.map{model.labelsGenerator.generate($0, axis: axis)}?.first.map{dimensionExtractor($0.textSize) / 2} ?? 0
            }
            
            func calculatePadding(_ padding: ChartAxisPadding, axisValueMaybe: Double?) -> CGFloat {
                switch padding {
                case .label: return paddingForAxisValue(axisValueMaybe)
                case .labelPlus(let plus): return paddingForAxisValue(axisValueMaybe) + plus
                case .maxLabelFixed(let length): return max(paddingForAxisValue(axisValueMaybe), length)
                case .fixed(let length): return length
                case .none: return 0
                }
            }
            
            let axisValues: [Double] = {
                switch (model.leadingPadding, model.trailingPadding) {
                case (.label, _): fallthrough
                case (_, .label): fallthrough
                case (.labelPlus, _): fallthrough
                case (_, .labelPlus): fallthrough
                case (.maxLabelFixed(_), _): fallthrough
                case (_, .maxLabelFixed(_)): return model.axisValuesGenerator.generate(axis)
                default: return []
                }
            }()

            return (
                calculatePadding(model.leadingPadding, axisValueMaybe: axisValues.first),
                calculatePadding(model.trailingPadding, axisValueMaybe: axisValues.last)
            )
        }
        
        let yLowGenerator: ChartAxisLayerGenerator = {model in
            let tmpAxis = ChartAxisY(first: model.firstModelValue, last: model.lastModelValue, firstScreen: model.p1.y, lastScreen: model.p2.y)
            model.axisValuesGenerator.axisInitialized(tmpAxis)
            let tmpAxis2 = ChartAxisY(first: model.axisValuesGenerator.first ?? model.firstModelValue, last: model.axisValuesGenerator.last ?? model.lastModelValue, firstScreen: model.p1.y, lastScreen: model.p2.y)
            let (firstPadding, lastPadding) = calculatePaddingValues(tmpAxis2, model: model, dimensionExtractor: {$0.height})
            let axis = ChartAxisY(first: model.axisValuesGenerator.first ?? model.firstModelValue, last: model.axisValuesGenerator.last ?? model.lastModelValue, firstScreen: model.p1.y, lastScreen: model.p2.y, paddingFirstScreen: firstPadding, paddingLastScreen: lastPadding)
            return ChartAxisYLowLayerDefault(axis: axis, offset: model.p1.x, valuesGenerator: model.axisValuesGenerator, labelsGenerator: model.labelsGenerator, axisTitleLabels: model.axisTitleLabels, settings: model.settings, labelsConflictSolver: model.labelsConflictSolver, labelSpaceReservationMode: model.labelSpaceReservationMode, clipContents: model.clipContents)
        }
        let yHighGenerator: ChartAxisLayerGenerator = {model in
            let tmpAxis = ChartAxisY(first: model.firstModelValue, last: model.lastModelValue, firstScreen: model.p1.y, lastScreen: model.p2.y)
            model.axisValuesGenerator.axisInitialized(tmpAxis)
            let tmpAxis2 = ChartAxisY(first: model.axisValuesGenerator.first ?? model.firstModelValue, last: model.axisValuesGenerator.last ?? model.lastModelValue, firstScreen: model.p1.y, lastScreen: model.p2.y)
            let (firstPadding, lastPadding) = calculatePaddingValues(tmpAxis2, model: model, dimensionExtractor: {$0.height})
            let axis = ChartAxisY(first: model.axisValuesGenerator.first ?? model.firstModelValue, last: model.axisValuesGenerator.last ?? model.lastModelValue, firstScreen: model.p1.y, lastScreen: model.p2.y, paddingFirstScreen: firstPadding, paddingLastScreen: lastPadding)
            return ChartAxisYHighLayerDefault(axis: axis, offset: model.p1.x, valuesGenerator: model.axisValuesGenerator, labelsGenerator: model.labelsGenerator, axisTitleLabels: model.axisTitleLabels, settings: model.settings, labelsConflictSolver: model.labelsConflictSolver, labelSpaceReservationMode: model.labelSpaceReservationMode, clipContents: model.clipContents)
        }
        let xLowGenerator: ChartAxisLayerGenerator = {model in
            let tmpAxis = ChartAxisX(first: model.firstModelValue, last: model.lastModelValue, firstScreen: model.p1.x, lastScreen: model.p2.x)
            model.axisValuesGenerator.axisInitialized(tmpAxis)
            let tmpAxis2 = ChartAxisX(first: model.axisValuesGenerator.first ?? model.firstModelValue, last: model.axisValuesGenerator.last ?? model.lastModelValue, firstScreen: model.p1.x, lastScreen: model.p2.x)
            let (firstPadding, lastPadding) = calculatePaddingValues(tmpAxis2, model: model, dimensionExtractor: {$0.width})
            let axis = ChartAxisX(first: model.axisValuesGenerator.first ?? model.firstModelValue, last: model.axisValuesGenerator.last ?? model.lastModelValue, firstScreen: model.p1.x, lastScreen: model.p2.x, paddingFirstScreen: firstPadding, paddingLastScreen: lastPadding)
            return ChartAxisXLowLayerDefault(axis: axis, offset: model.p1.y, valuesGenerator: model.axisValuesGenerator, labelsGenerator: model.labelsGenerator, axisTitleLabels: model.axisTitleLabels, settings: model.settings, labelsConflictSolver: model.labelsConflictSolver, labelSpaceReservationMode: model.labelSpaceReservationMode, clipContents: model.clipContents)
        }
        let xHighGenerator: ChartAxisLayerGenerator = {model in
            let tmpAxis = ChartAxisX(first: model.firstModelValue, last: model.lastModelValue, firstScreen: model.p1.x, lastScreen: model.p2.x)
            model.axisValuesGenerator.axisInitialized(tmpAxis)
            let tmpAxis2 = ChartAxisX(first: model.axisValuesGenerator.first ?? model.firstModelValue, last: model.axisValuesGenerator.last ?? model.lastModelValue, firstScreen: model.p1.x, lastScreen: model.p2.x)
            let (firstPadding, lastPadding) = calculatePaddingValues(tmpAxis2, model: model, dimensionExtractor: {$0.width})
            let axis = ChartAxisX(first: model.axisValuesGenerator.first ?? model.firstModelValue, last: model.axisValuesGenerator.last ?? model.lastModelValue, firstScreen: model.p1.x, lastScreen: model.p2.x, paddingFirstScreen: firstPadding, paddingLastScreen: lastPadding)
            return ChartAxisXHighLayerDefault(axis: axis, offset: model.p1.y, valuesGenerator: model.axisValuesGenerator, labelsGenerator: model.labelsGenerator, axisTitleLabels: model.axisTitleLabels, settings: model.settings, labelsConflictSolver: model.labelsConflictSolver, labelSpaceReservationMode: model.labelSpaceReservationMode, clipContents: model.clipContents)
        }
        
        self.init(chartSettings: chartSettings, chartSize: chartSize, yLowModels: yLowModels, yHighModels: yHighModels, xLowModels: xLowModels, xHighModels: xHighModels, yLowGenerator: yLowGenerator, yHighGenerator: yHighGenerator, xLowGenerator: xLowGenerator, xHighGenerator: xHighGenerator)
    }
    
    public init(chartSettings: ChartSettings, chartSize: CGSize, yLowModels: [ChartAxisModel], yHighModels: [ChartAxisModel], xLowModels: [ChartAxisModel], xHighModels: [ChartAxisModel], yLowGenerator: @escaping ChartAxisLayerGenerator, yHighGenerator: @escaping ChartAxisLayerGenerator, xLowGenerator: @escaping ChartAxisLayerGenerator, xHighGenerator: @escaping ChartAxisLayerGenerator) {
        self.chartSettings = chartSettings
        self.chartSize = chartSize
        
        self.yLowModels = yLowModels
        self.yHighModels = yHighModels
        self.xLowModels = xLowModels
        self.xHighModels = xHighModels
        
        self.yLowGenerator = yLowGenerator
        self.yHighGenerator = yHighGenerator
        self.xLowGenerator = xLowGenerator
        self.xHighGenerator = xHighGenerator
        
        chartInnerFrame = calculateChartInnerFrame()
        
        self.yLowAxesLayers = generateYLowAxes()
        self.yHighAxesLayers = generateYHighAxes()
        self.xLowAxesLayers = generateXLowAxes()
        self.xHighAxesLayers = generateXHighAxes()
    }
    
    
    fileprivate func generateYLowAxes() -> [ChartAxisLayer] {
        return generateYAxisShared(axisModels: yLowModels, offset: chartSettings.leading, generator: yLowGenerator)
    }
    
    fileprivate func generateYHighAxes() -> [ChartAxisLayer] {
        let chartFrame = chartInnerFrame
        return generateYAxisShared(axisModels: yHighModels, offset: chartFrame.origin.x + chartFrame.width, generator: yHighGenerator)
    }
    
    fileprivate func generateXLowAxes() -> [ChartAxisLayer] {
        let chartFrame = chartInnerFrame
        let y = chartFrame.origin.y + chartFrame.height
        return self.generateXAxesShared(axisModels: xLowModels, offset: y, generator: xLowGenerator)
    }
    
    fileprivate func generateXHighAxes() -> [ChartAxisLayer] {
        return generateXAxesShared(axisModels: xHighModels, offset: chartSettings.top, generator: xHighGenerator)
    }

    /**
     Uses a generator to make X axis layers from axis models. This method is used for both low and high X axes.

     - parameter axisModels: The models used to generate the axis layers
     - parameter offset:     The offset in points for the generated layers
     - parameter generator:  The generator used to create the layers

     - returns: An array of ChartAxisLayers
     */
    fileprivate func generateXAxesShared(axisModels: [ChartAxisModel], offset: CGFloat, generator: ChartAxisLayerGenerator) -> [ChartAxisLayer] {
        let chartFrame = chartInnerFrame
        let chartSettings = self.chartSettings
        let x = chartFrame.origin.x
        let length = chartFrame.width
        
        return generateAxisShared(axisModels: axisModels, offset: offset, boundingPointsCreator: {offset in
            (p1: CGPoint(x: x, y: offset), p2: CGPoint(x: x + length, y: offset))
            }, nextLayerOffset: {layer in
                layer.frameWithoutLabels.height + chartSettings.spacingBetweenAxesX
            }, generator: generator)
    }
    
    /**
     Uses a generator to make Y axis layers from axis models. This method is used for both low and high Y axes.

     - parameter axisModels: The models used to generate the axis layers
     - parameter offset:     The offset in points for the generated layers
     - parameter generator:  The generator used to create the layers

     - returns: An array of ChartAxisLayers
     */
    fileprivate func generateYAxisShared(axisModels: [ChartAxisModel], offset: CGFloat, generator: ChartAxisLayerGenerator) -> [ChartAxisLayer] {
        let chartFrame = chartInnerFrame
        let chartSettings = self.chartSettings
        let y = chartFrame.origin.y
        let length = chartFrame.height
        
        return generateAxisShared(axisModels: axisModels, offset: offset, boundingPointsCreator: {offset in
            (p1: CGPoint(x: offset, y: y + length), p2: CGPoint(x: offset, y: y))
            }, nextLayerOffset: {layer in
                layer.frameWithoutLabels.width + chartSettings.spacingBetweenAxesY
            }, generator: generator)
    }

    /**
     Uses a generator to make axis layers from axis models. This method is used for all axes.

     - parameter axisModels:            The models used to generate the axis layers
     - parameter offset:                The offset in points for the generated layers
     - parameter boundingPointsCreator: A closure that creates a tuple containing the location of the smallest and largest values along the axis. For example, boundingPointsCreator for a Y axis might return a value like (p1: CGPoint(x, 0), p2: CGPoint(x, 100)), where x is the offset of the axis layer.
     - parameter nextLayerOffset:       A closure that returns the offset of the next axis layer relative to the current layer
     - parameter generator:             The generator used to create the layers

     - returns: An array of ChartAxisLayers
     */
    fileprivate func generateAxisShared(axisModels: [ChartAxisModel], offset: CGFloat, boundingPointsCreator: @escaping (_ offset: CGFloat) -> (p1: CGPoint, p2: CGPoint), nextLayerOffset: @escaping (ChartAxisLayer) -> CGFloat, generator: ChartAxisLayerGenerator) -> [ChartAxisLayer] {
        
        let chartSettings = self.chartSettings
        
        return axisModels.reduce((axes: Array<ChartAxisLayer>(), x: offset)) {tuple, chartAxisModel in
            let layers = tuple.axes
            let x: CGFloat = tuple.x
            let axisSettings = ChartAxisSettings(chartSettings)
            axisSettings.lineColor = chartAxisModel.lineColor
            let points = boundingPointsCreator(x)
            let layer = generator((p1: points.p1, p2: points.p2, firstModelValue: chartAxisModel.firstModelValue, lastModelValue: chartAxisModel.lastModelValue, axisValuesGenerator: chartAxisModel.axisValuesGenerator, labelsGenerator: chartAxisModel.labelsGenerator, axisTitleLabels: chartAxisModel.axisTitleLabels, settings: axisSettings, labelsConflictSolver: chartAxisModel.labelsConflictSolver, leadingPadding: chartAxisModel.leadingPadding, trailingPadding: chartAxisModel.trailingPadding, labelSpaceReservationMode: chartAxisModel.labelSpaceReservationMode, clipContents: chartAxisModel.clipContents))
            return (
                axes: layers + [layer],
                x: x + nextLayerOffset(layer)
            )
        }.0
    }

    /**
     Calculates the inner frame of the chart, which in short is the area where your points, bars, lines etc. are drawn. In order to calculate this frame the axes will be generated.

     - returns: The inner frame as a CGRect
     */
    fileprivate func calculateChartInnerFrame() -> CGRect {
        
        let totalDim = {(axisLayers: [ChartAxisLayer], dimPicker: (ChartAxisLayer) -> CGFloat, spacingBetweenAxes: CGFloat) -> CGFloat in
            return axisLayers.reduce((CGFloat(0), CGFloat(0))) {tuple, chartAxisLayer in
                let totalDim = tuple.0 + tuple.1
                return (totalDim + dimPicker(chartAxisLayer), spacingBetweenAxes)
            }.0
        }

        func totalWidth(_ axisLayers: [ChartAxisLayer]) -> CGFloat {
            return totalDim(axisLayers, {$0.frame.width}, chartSettings.spacingBetweenAxesY)
        }
        
        func totalHeight(_ axisLayers: [ChartAxisLayer]) -> CGFloat {
            return totalDim(axisLayers, {$0.frame.height}, chartSettings.spacingBetweenAxesX)
        }
        
        let yLowWidth = totalWidth(generateYLowAxes())
        let yHighWidth = totalWidth(generateYHighAxes())
        let xLowHeight = totalHeight(generateXLowAxes())
        let xHighHeight = totalHeight(generateXHighAxes())
        
        let leftWidth = yLowWidth + chartSettings.leading
        let topHeigth = xHighHeight + chartSettings.top
        let rightWidth = yHighWidth + chartSettings.trailing
        let bottomHeight = xLowHeight + chartSettings.bottom
        
        return CGRect(
            x: leftWidth,
            y: topHeigth,
            width: chartSize.width - leftWidth - rightWidth,
            height: chartSize.height - topHeigth - bottomHeight
        )
    }
}

/// A ChartCoordsSpace subclass specifically for a chart with axes along the left and bottom edges
open class ChartCoordsSpaceLeftBottomSingleAxis {

    open let yAxisLayer: ChartAxisLayer
    open let xAxisLayer: ChartAxisLayer
    open let chartInnerFrame: CGRect
    
    public init(chartSettings: ChartSettings, chartFrame: CGRect, xModel: ChartAxisModel, yModel: ChartAxisModel) {
        let coordsSpaceInitializer = ChartCoordsSpace(chartSettings: chartSettings, chartSize: chartFrame.size, yLowModels: [yModel], xLowModels: [xModel])
        self.chartInnerFrame = coordsSpaceInitializer.chartInnerFrame
        
        self.yAxisLayer = coordsSpaceInitializer.yLowAxesLayers[0]
        self.xAxisLayer = coordsSpaceInitializer.xLowAxesLayers[0]
    }
}

/// A ChartCoordsSpace subclass specifically for a chart with axes along the left and top edges
open class ChartCoordsSpaceLeftTopSingleAxis {
    
    open let yAxisLayer: ChartAxisLayer
    open let xAxisLayer: ChartAxisLayer
    open let chartInnerFrame: CGRect
    
    public init(chartSettings: ChartSettings, chartFrame: CGRect, xModel: ChartAxisModel, yModel: ChartAxisModel) {
        let coordsSpaceInitializer = ChartCoordsSpace(chartSettings: chartSettings, chartSize: chartFrame.size, yLowModels: [yModel], xHighModels: [xModel])
        self.chartInnerFrame = coordsSpaceInitializer.chartInnerFrame
        
        self.yAxisLayer = coordsSpaceInitializer.yLowAxesLayers[0]
        self.xAxisLayer = coordsSpaceInitializer.xHighAxesLayers[0]
    }
}

/// A ChartCoordsSpace subclass specifically for a chart with axes along the right and bottom edges
open class ChartCoordsSpaceRightBottomSingleAxis {
    
    open let yAxisLayer: ChartAxisLayer
    open let xAxisLayer: ChartAxisLayer
    open let chartInnerFrame: CGRect
    
    public init(chartSettings: ChartSettings, chartFrame: CGRect, xModel: ChartAxisModel, yModel: ChartAxisModel) {
        let coordsSpaceInitializer = ChartCoordsSpace(chartSettings: chartSettings, chartSize: chartFrame.size, yHighModels: [yModel], xLowModels: [xModel])
        self.chartInnerFrame = coordsSpaceInitializer.chartInnerFrame
        
        self.yAxisLayer = coordsSpaceInitializer.yHighAxesLayers[0]
        self.xAxisLayer = coordsSpaceInitializer.xLowAxesLayers[0]
    }
}

/// A ChartCoordsSpace subclass specifically for a chart with axes along the right and top edges
open class ChartCoordsSpaceRightTopSingleAxis {
    
    open let yAxisLayer: ChartAxisLayer
    open let xAxisLayer: ChartAxisLayer
    open let chartInnerFrame: CGRect
    
    public init(chartSettings: ChartSettings, chartFrame: CGRect, xModel: ChartAxisModel, yModel: ChartAxisModel) {
        let coordsSpaceInitializer = ChartCoordsSpace(chartSettings: chartSettings, chartSize: chartFrame.size, yHighModels: [yModel], xHighModels: [xModel])
        self.chartInnerFrame = coordsSpaceInitializer.chartInnerFrame
        
        self.yAxisLayer = coordsSpaceInitializer.yHighAxesLayers[0]
        self.xAxisLayer = coordsSpaceInitializer.xHighAxesLayers[0]
    }
}
