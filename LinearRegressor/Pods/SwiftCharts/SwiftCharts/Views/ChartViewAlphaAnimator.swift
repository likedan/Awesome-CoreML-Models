//
//  ChartViewAlphaAnimator.swift
//  SwiftCharts
//
//  Created by ischuetz on 02/09/16.
//  Copyright © 2016 ivanschuetz. All rights reserved.
//

import UIKit

public struct ChartViewAlphaAnimator: ChartViewAnimator {
    
    public let initAlpha: CGFloat
    public let targetAlpha: CGFloat
    
    public init(initAlpha: CGFloat, targetAlpha: CGFloat) {
        self.initAlpha = initAlpha
        self.targetAlpha = targetAlpha
    }
    
    public func initState(_ view: UIView) {
        view.alpha = initAlpha
    }
    
    public func targetState(_ view: UIView) {
        view.alpha = targetAlpha
    }
}