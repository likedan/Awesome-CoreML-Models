//
//  ChartAxisValue.swift
//  SwiftCharts
//
//  Created by ischuetz on 26/07/16.
//  Copyright © 2016 ivanschuetz. All rights reserved.
//

import UIKit

extension Array where Element: ChartAxisValue {

    func calculateLabelsDimensions() -> (total: CGSize, max: CGSize) {
        return flatMap({
            guard let label = $0.labels.first else {return nil}
            return label.textSizeNonRotated
        }).reduce((total: CGSize.zero, max: CGSize.zero), {(lhs: (total: CGSize, max: CGSize), rhs: CGSize) in
            return (
                CGSize(width: lhs.total.width + rhs.width, height: lhs.total.height + rhs.height),
                CGSize(width: Swift.max(lhs.max.width, rhs.width), height: Swift.max(lhs.max.height, rhs.height))
            )
        })
    }
}
