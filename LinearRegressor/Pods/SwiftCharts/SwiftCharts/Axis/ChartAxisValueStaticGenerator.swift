//
//  ChartAxisValuesGenerator.swift
//  swift_charts
//
//  Created by ischuetz on 12/04/15.
//  Copyright (c) 2015 ivanschuetz. All rights reserved.
//

import UIKit

public typealias ChartAxisValueStaticGenerator = (Double) -> ChartAxisValue

/// Dynamic axis values generation
public struct ChartAxisValuesStaticGenerator {

    /**
     Calculates the axis values that bound some chart points along the X axis

     Think of a segment as the "space" between two axis values.

     - parameter chartPoints:             The chart points to bound.
     - parameter minSegmentCount:         The minimum number of segments in the range of axis values. This value is prioritized over the maximum in order to prevent a conflict.
     - parameter maxSegmentCount:         The maximum number of segments in the range of axis values.
     - parameter multiple:                The desired width of each segment between axis values.
     - parameter axisValueGenerator:      Function that converts a scalar value to an axis value.
     - parameter addPaddingSegmentIfEdge: Whether or not to add an extra value to the start and end if the first and last chart points fall exactly on the axis values.

     - returns: An array of axis values.
     */
    public static func generateXAxisValuesWithChartPoints(_ chartPoints: [ChartPoint], minSegmentCount: Double, maxSegmentCount: Double, multiple: Double = 10, axisValueGenerator: ChartAxisValueStaticGenerator, addPaddingSegmentIfEdge: Bool) -> [ChartAxisValue] {
        return generateAxisValuesWithChartPoints(chartPoints, minSegmentCount: minSegmentCount, maxSegmentCount: maxSegmentCount, multiple: multiple, axisValueGenerator: axisValueGenerator, addPaddingSegmentIfEdge: addPaddingSegmentIfEdge, axisPicker: {$0.x})
    }

    /**
     Calculates the axis values that bound some chart points along the Y axis

     Think of a segment as the "space" between two axis values.

     - parameter chartPoints:             The chart points to bound.
     - parameter minSegmentCount:         The minimum number of segments in the range of axis values. This value is prioritized over the maximum in order to prevent a conflict.
     - parameter maxSegmentCount:         The maximum number of segments in the range of axis values.
     - parameter multiple:                The desired width of each segment between axis values.
     - parameter axisValueGenerator:      Function that converts a scalar value to an axis value.
     - parameter addPaddingSegmentIfEdge: Whether or not to add an extra value to the start and end if the first and last chart points fall exactly on the axis values.

     - returns: An array of axis values.
     */
    public static func generateYAxisValuesWithChartPoints(_ chartPoints: [ChartPoint], minSegmentCount: Double, maxSegmentCount: Double, multiple: Double = 10, axisValueGenerator: ChartAxisValueStaticGenerator, addPaddingSegmentIfEdge: Bool) -> [ChartAxisValue] {
        return generateAxisValuesWithChartPoints(chartPoints, minSegmentCount: minSegmentCount, maxSegmentCount: maxSegmentCount, multiple: multiple, axisValueGenerator: axisValueGenerator, addPaddingSegmentIfEdge: addPaddingSegmentIfEdge, axisPicker: {$0.y})
    }

    /**
     Calculates the axis values that bound some chart points along a particular axis dimension.

     Think of a segment as the "space" between two axis values.

     - parameter chartPoints:             The chart points to bound.
     - parameter minSegmentCount:         The minimum number of segments in the range of axis values. This value is prioritized over the maximum in order to prevent a conflict.
     - parameter maxSegmentCount:         The maximum number of segments in the range of axis values.
     - parameter multiple:                The desired width of each segment between axis values.
     - parameter axisValueGenerator:      Function that converts a scalar value to an axis value.
     - parameter addPaddingSegmentIfEdge: Whether or not to add an extra value to the start and end if the first and last chart points fall exactly on the axis values.
     - parameter axisPicker:              A function that maps a chart point to its value for a particular axis.

     - returns: An array of axis values.
     */
    fileprivate static func generateAxisValuesWithChartPoints(_ chartPoints: [ChartPoint], minSegmentCount: Double, maxSegmentCount: Double, multiple: Double = 10, axisValueGenerator: ChartAxisValueStaticGenerator, addPaddingSegmentIfEdge: Bool, axisPicker: (ChartPoint) -> ChartAxisValue) -> [ChartAxisValue] {
        
        let sortedChartPoints = chartPoints.sorted {(obj1, obj2) in
            return axisPicker(obj1).scalar < axisPicker(obj2).scalar
        }
        
        if let first = sortedChartPoints.first, let last = sortedChartPoints.last {
            return generateAxisValuesWithChartPoints(axisPicker(first).scalar, last: axisPicker(last).scalar, minSegmentCount: minSegmentCount, maxSegmentCount: maxSegmentCount, multiple: multiple, axisValueGenerator: axisValueGenerator, addPaddingSegmentIfEdge: addPaddingSegmentIfEdge)
            
        } else {
            print("Trying to generate Y axis without datapoints, returning empty array")
            return []
        }
    }

    /**
     Calculates the axis values that bound two values and have an optimal number of segments between them.
     
     Think of a segment as the "space" between two axis values.

     - parameter first:                   The first scalar value to bound.
     - parameter last:                    The last scalar value to bound.
     - parameter minSegmentCount:         The minimum number of segments in the range of axis values. This value is prioritized over the maximum in order to prevent a conflict.
     - parameter maxSegmentCount:         The maximum number of segments in the range of axis values.
     - parameter multiple:                The desired width of each segment between axis values.
     - parameter axisValueGenerator:      Function that converts a scalar value to an axis value.
     - parameter addPaddingSegmentIfEdge: Whether or not to add an extra value to the start and end if the first and last scalar values fall exactly on the axis values.

     - returns: An array of axis values
     */
    fileprivate static func generateAxisValuesWithChartPoints(_ first: Double, last lastPar: Double, minSegmentCount: Double, maxSegmentCount: Double, multiple: Double, axisValueGenerator: ChartAxisValueStaticGenerator, addPaddingSegmentIfEdge: Bool) -> [ChartAxisValue] {
        precondition(multiple > 0, "Invalid multiple: \(multiple)")
        
        guard lastPar >=~ first else {fatalError("Invalid range generating axis values")}
        
        let last = lastPar =~ first ? lastPar + 1 : lastPar

        // The first axis value will be less than or equal to the first scalar value, aligned with the desired multiple
        var firstValue = first - (first.truncatingRemainder(dividingBy: multiple))
        // The last axis value will be greater than or equal to the first scalar value, aligned with the desired multiple
        var lastValue = last + (abs(multiple - last).truncatingRemainder(dividingBy: multiple))
        var segmentSize = multiple

        // If there should be a padding segment added when a scalar value falls on the first or last axis value, adjust the first and last axis values
        if firstValue =~ first && addPaddingSegmentIfEdge {
            firstValue = firstValue - segmentSize
        }
        if lastValue =~ last && addPaddingSegmentIfEdge {
            lastValue = lastValue + segmentSize
        }
        
        let distance = lastValue - firstValue
        var currentMultiple = multiple
        var segmentCount = distance / currentMultiple

        // Find the optimal number of segments and segment width

        // If the number of segments is greater than desired, make each segment wider
        while segmentCount > maxSegmentCount {
            currentMultiple *= 2
            segmentCount = distance / currentMultiple
        }
        segmentCount = ceil(segmentCount)

        // Increase the number of segments until there are enough as desired
        while segmentCount < minSegmentCount {
            segmentCount += 1
        }
        segmentSize = currentMultiple

        // Generate axis values from the first value, segment size and number of segments
        let offset = firstValue
        return (0...Int(segmentCount)).map {segment in
            let scalar = offset + (Double(segment) * segmentSize)
            return axisValueGenerator(scalar)
        }
    }
    
}
