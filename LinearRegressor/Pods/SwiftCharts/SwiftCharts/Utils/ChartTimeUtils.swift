//
//  ChartTimeUtils.swift
//  SwiftCharts
//
//  Created by ischuetz on 13/08/16.
//  Copyright © 2016 ivanschuetz. All rights reserved.
//

import UIKit

struct ChartTimeUtils {
    
    /**
     Converts seconds to the same amount as a dispatch_time_t
     
     - parameter secs: The number of seconds
     
     - returns: The number of seconds as a dispatch_time_t
     */
    static func toDispatchTime(_ secs: Float) -> DispatchTime {
        return DispatchTime.now() + Double(Int64(Double(secs) * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC)
    }    
}
