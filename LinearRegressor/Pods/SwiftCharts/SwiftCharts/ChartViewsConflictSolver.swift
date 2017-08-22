//
//  ChartViewsConflictSolver.swift
//  SwiftCharts
//
//  Created by ischuetz on 30/04/15.
//  Copyright (c) 2015 ivanschuetz. All rights reserved.
//

import UIKit

/// For now as class, which in this case is acceptable. Protocols currently don't work very well with generics.
open class ChartViewsConflictSolver<T: ChartPoint, U: UIView> {

    /**
    Repositions views if they overlap

    - parameter views: The views to check for overlap and resolve
    */
    func solveConflicts(views: [ChartPointsViewsLayer<T, U>.ViewWithChartPoint]) {}
}
