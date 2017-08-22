//
//  Optional.swift
//  SwiftCharts
//
//  Created by ischuetz on 06/08/16.
//  Copyright © 2016 ivanschuetz. All rights reserved.
//

import UIKit

extension Optional where Wrapped: Comparable {
    
    func minOpt(_ other: Wrapped?) -> Wrapped? {
        return anyOrF(other) {min($0, $1)}
    }
    
    func maxOpt(_ other: Wrapped?) -> Wrapped? {
        return anyOrF(other) {max($0, $1)}
    }

    func minOpt(_ other: Wrapped) -> Wrapped {
        return anyOrF(other) {min($0, $1)}!
    }
    
    func maxOpt(_ other: Wrapped) -> Wrapped {
        return anyOrF(other) {max($0, $1)}!
    }
    
    fileprivate func anyOrF(_ other: Wrapped?, f: (Wrapped, Wrapped) -> Wrapped?) -> Wrapped? {
        switch (self, other) {
        case (nil, nil): return nil
        case (let value, nil): return value
        case (nil, let value): return value
        case (let value1, let value2): return f(value1!, value2!)
        }
    }
}
