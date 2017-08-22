//
//  ChartAxisLayer.swift
//  SwiftCharts
//
//  Created by ischuetz on 02/05/15.
//  Copyright (c) 2015 ivanschuetz. All rights reserved.
//

import UIKit

public protocol ChartAxisLayer: ChartLayer {

    // Axis, used to map between model values and screen locations
    var axis: ChartAxis {get}

    var tapSettings: ChartAxisLayerTapSettings? {get set}
    
    var labelsGenerator: ChartAxisLabelsGenerator {get set}
    
    /// Displayed axis values
    var currentAxisValues: [Double] {get}
    
    /// The frame of the layer. This includes title, labels and line, and takes into account possible rotation and spacing settings.
    var frame: CGRect {get}

    var frameWithoutLabels: CGRect {get}
    
    /// Screen locations of current axis values
    var axisValuesScreenLocs: [CGFloat] {get}

    /// The axis values with their respective frames relative to the chart's view
    var axisValuesWithFrames: [(axisValue: Double, frames: [CGRect])] {get}

    /// The smallest screen distance between axis values
    var minAxisScreenSpace: CGFloat {get}

    /// Whether the axis is low (leading or bottom) or high (trailing or top)
    var low: Bool {get}

    var lineP1: CGPoint {get}
    var lineP2: CGPoint {get}
    
    /// If the axis frame should (incrementally) affect the inner frame size of the chart
    var canChangeFrameSize: Bool {set get}
}
