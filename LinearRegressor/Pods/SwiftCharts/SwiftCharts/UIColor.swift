//
//  UIColor.swift
//  SwiftCharts
//
//  Created by ischuetz on 24/08/16.
//  Copyright © 2016 ivanschuetz. All rights reserved.
//

import UIKit

extension UIColor {
    
    var alpha: CGFloat {
        return components.alpha
    }
    
    var components: (red: CGFloat, green: CGFloat, blue: CGFloat, alpha: CGFloat) {
        var r: CGFloat = 0, g: CGFloat = 0, b: CGFloat = 0, a: CGFloat = 0
        getRed(&r, green: &g, blue: &b, alpha: &a)
        return (red: r, green: g, blue: b, alpha: a)
    }
    
    func adjustBrigtness(factor brightnessFactor: CGFloat) -> UIColor {
        var h: CGFloat = 0, s: CGFloat = 0, b: CGFloat = 0, a: CGFloat = 0
        guard getHue(&h, saturation: &s, brightness: &b, alpha: &a) else {return self}
        
        return UIColor(hue: h, saturation: s, brightness: min(b * brightnessFactor, 1), alpha: a)
    }
    
    func copy(_ red: CGFloat? = nil, green: CGFloat? = nil, blue: CGFloat? = nil, alpha: CGFloat? = nil) -> UIColor {
        let components = self.components
        return UIColor(red: red ?? components.red, green: green ?? components.green, blue: blue ?? components.blue, alpha: alpha ?? components.alpha)
    }
}