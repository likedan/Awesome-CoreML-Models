//
//  Int.swift
//  SwiftCharts
//
//  Created by ischuetz on 26/07/16.
//  Copyright © 2016 ivanschuetz. All rights reserved.
//

import UIKit

extension Int {
    
    // Lazily computes prime factors 
    // src: https://gist.github.com/JadenGeller/f998071fe71c2bc2976ef6465f0e6e5d
    public var primeFactors: AnySequence<Int> {
        func factor(_ input: Int) -> (prime: Int, remainder: Int) {
            let end = Int(sqrt(Float(input)))
            if end > 2 {
                for prime in 2...end {
                    if input % prime == 0 {
                        return (prime, input / prime)
                    }
                }
            }
            return (input, 1)
        }
        var current = self
        return AnySequence(AnyIterator {
            guard current != 1 else { return nil }
            
            let result = factor(current)
            current = result.remainder
            return result.prime
        })
    }
    
    func floorMultiple(_ value: Int) -> Int {
        return Int(floor(Double(self) / Double(value)) * Double(value))
    }
    
    func ceilMultiple(_ value: Int) -> Int {
        return Int(ceil(Double(self) / Double(value)) * Double(value))
    }
}
