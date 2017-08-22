//
//  ChartAxisLabelsConflictSolverMoveUpDown.swift
//  SwiftCharts
//
//  Created by ischuetz on 27/06/16.
//  Copyright © 2016 ivanschuetz. All rights reserved.
//

import Foundation

/// Solves frame overlaps by moving drawers up and down by half of the height of their frames. Assumes being used for y axis, which currently supports only 1 label per axis value.
open class ChartAxisLabelsConflictSolverMoveUpDown: ChartAxisLabelsConflictSolver {
    
    let maxIterations: Int
 
    /**
     - parameter maxIterations: Max count of iterations through the passed labels to solve conflicts.
     */
    public init(maxIterations: Int = 20) {
        self.maxIterations = maxIterations
    }
    
    open func solveConflicts(_ labels: [ChartAxisValueLabelDrawers]) -> [ChartAxisValueLabelDrawers] {
        
        var lastDrawerWithRect: (drawer: ChartLabelDrawer, rect: CGRect)?
        
        var iteration = 0
        var doNextIteration = true
        
        while (iteration < maxIterations && doNextIteration) {
            
            doNextIteration = false
            
            for (_, labelDrawers) in labels {
                
                guard let labelDrawer = labelDrawers.first else {continue} // for now y axis supports only one label / value
                
                if let (lastDrawer, lastRect) = lastDrawerWithRect {
                    let intersection = labelDrawer.frame.intersection(lastRect)
                    if intersection != CGRect.null {
                        
                        doNextIteration = true // if there's a conflict do another iteration after this iteration in case there are more conflicts as result of solving this conflict
                        
                        labelDrawer.screenLoc = CGPoint(x: labelDrawer.screenLoc.x, y: labelDrawer.screenLoc.y - intersection.height / 2)
                        lastDrawer.screenLoc = CGPoint(x: lastDrawer.screenLoc.x, y: lastDrawer.screenLoc.y + intersection.height / 2)
                    }
                }
                
                lastDrawerWithRect = (labelDrawer, labelDrawer.frame)
            }
            
            iteration += 1
        }
        
        return labels
    }
}