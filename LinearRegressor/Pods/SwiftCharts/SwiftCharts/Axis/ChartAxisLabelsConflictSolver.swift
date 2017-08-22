//
//  ChartAxisLabelsConflictSolver.swift
//  SwiftCharts
//
//  Created by ischuetz on 27/06/16.
//  Copyright © 2016 ivanschuetz. All rights reserved.
//

import Foundation

/// Maps label drawers array to a new array in order to solve conflicts
public protocol ChartAxisLabelsConflictSolver {
    
    func solveConflicts(_ labels: [ChartAxisValueLabelDrawers]) -> [ChartAxisValueLabelDrawers]
}
