//
//  Operators.swift
//  SwiftCharts
//
//  Created by ischuetz on 16/07/16.
//  Copyright © 2016 ivanschuetz. All rights reserved.
//

import Foundation

infix operator =~ : ComparisonPrecedence

func =~ (a: Float, b: Float) -> Bool {
    return fabsf(a - b) < Float.ulpOfOne
}

func =~ (a: CGFloat, b: CGFloat) -> Bool {
    return fabs(a - b) < CGFloat.ulpOfOne
}

func =~ (a: Double, b: Double) -> Bool {
    return fabs(a - b) < Double.ulpOfOne
}

infix operator !=~ : ComparisonPrecedence

func !=~ (a: Float, b: Float) -> Bool {
    return !(a =~ b)
}

func !=~ (a: CGFloat, b: CGFloat) -> Bool {
    return !(a =~ b)
}

func !=~ (a: Double, b: Double) -> Bool {
    return !(a =~ b)
}

infix operator <=~ : ComparisonPrecedence

func <=~ (a: Float, b: Float) -> Bool {
    return a =~ b || a < b
}

func <=~ (a: CGFloat, b: CGFloat) -> Bool {
    return a =~ b || a < b
}

func <=~ (a: Double, b: Double) -> Bool {
    return a =~ b || a < b
}

infix operator >=~ : ComparisonPrecedence

func >=~ (a: Float, b: Float) -> Bool {
    return a =~ b || a > b
}

func >=~ (a: CGFloat, b: CGFloat) -> Bool {
    return a =~ b || a > b
}

func >=~ (a: Double, b: Double) -> Bool {
    return a =~ b || a > b
}
