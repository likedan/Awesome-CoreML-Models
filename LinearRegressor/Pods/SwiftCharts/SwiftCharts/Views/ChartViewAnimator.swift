//
//  ChartViewAnimator.swift
//  SwiftCharts
//
//  Created by ischuetz on 02/09/16.
//  Copyright © 2016 ivanschuetz. All rights reserved.
//

import UIKit

/// Animates a view from init state to target state and back. General animation settings like duration, delay, etc. are defined in the containing ChartViewAnimators instance.
public protocol ChartViewAnimator {
    
    func initState(_ view: UIView)
    
    func targetState(_ view: UIView)
    
    
    func prepare(_ view: UIView)
    
    func animate(_ view: UIView)
    
    func invert(_ view: UIView)
}

extension ChartViewAnimator {
    
    public func prepare(_ view: UIView) {
        initState(view)
    }
    
    public func animate(_ view: UIView) {
        targetState(view)
    }
    
    public func invert(_ view: UIView) {
        initState(view)
    }
}