//
//  ChartAxisLabelsGenerator.swift
//  SwiftCharts
//
//  Created by ischuetz on 27/06/16.
//  Copyright © 2016 ivanschuetz. All rights reserved.
//

import Foundation

/// Generates labels for an axis value. Note: Supports only one label per axis value (1 element array)
public protocol ChartAxisLabelsGenerator {

    /// If the complete label should disappear as soon as a part of it is outside of the axis edges
    var onlyShowCompleteLabels: Bool {get set}
    
    var maxStringPTWidth: CGFloat? {get set}
    
    func generate(_ scalar: Double) -> [ChartAxisLabel]
    
    /// Generates label for scalar taking into account axis state
    func generate(_ scalar: Double, axis: ChartAxis) -> [ChartAxisLabel]
    
    func fonts(_ scalar: Double) -> [UIFont]
    
    func cache(_ scalar: Double, labels: [ChartAxisLabel])
    
    func cachedLabels(_ scalar: Double) -> [ChartAxisLabel]?
}


extension ChartAxisLabelsGenerator {
    
    public var onlyShowCompleteLabels: Bool {
        return true
    }
    
    public var maxStringPTWidth: CGFloat? {
        return nil
    }
    
    fileprivate func truncate(_ labels: [ChartAxisLabel], scalar: Double, maxStringPTWidth: CGFloat) -> [ChartAxisLabel] {
        guard let font = fonts(scalar).first else {return []}
        return labels.map {label in
            label.copy(label.text.truncate(maxStringPTWidth, font: font))
        }
    }
    
    public func generate(_ scalar: Double, axis: ChartAxis) -> [ChartAxisLabel] {
    
        return cachedLabels(scalar) ?? {
        
            let labels = generate(scalar)
            
            let truncatedLabels: [ChartAxisLabel] = maxStringPTWidth.map{truncate(labels, scalar: scalar, maxStringPTWidth: $0)} ?? labels
            cache(scalar, labels: truncatedLabels)
            
            if onlyShowCompleteLabels {
                return truncatedLabels.first.map {label in
                    if axis.isInBoundaries(axis.screenLocForScalar(scalar), screenSize: label.textSize) {
                        return [label]
                    } else {
                        return []
                    }
                    } ?? []
            } else {
                return truncatedLabels
            }
        }()
    }
}
