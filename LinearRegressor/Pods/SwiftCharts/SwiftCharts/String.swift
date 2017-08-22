//
//  String.swift
//  SwiftCharts
//
//  Created by ischuetz on 13/08/16.
//  Copyright © 2016 ivanschuetz. All rights reserved.
//

import UIKit

extension String {
    
    subscript (i: Int) -> Character {
        return self[characters.index(startIndex, offsetBy: i)]
    }
    
    subscript (i: Int) -> String {
        return String(self[i] as Character)
    }
    
    subscript (r: Range<Int>) -> String {
        let start = characters.index(startIndex, offsetBy: r.lowerBound)
//        let end = <#T##String.CharacterView corresponding to `start`##String.CharacterView#>.index(start, offsetBy: r.upperBound - r.lowerBound)
        let end = characters.index(start, offsetBy: r.upperBound - r.lowerBound)
        return String(self[Range(start..<end)])
    }

    func size(_ font: UIFont) -> CGSize {
        #if swift(>=4)
        return NSAttributedString(string: self, attributes: [NSAttributedStringKey.font: font]).size()
        #else
        return NSAttributedString(string: self, attributes: [NSFontAttributeName: font]).size()
        #endif
    }
    
    func width(_ font: UIFont) -> CGFloat {
        return size(font).width
    }
    
    func height(_ font: UIFont) -> CGFloat {
        return size(font).height
    }
    
    func trim() -> String {
        return trimmingCharacters(in: CharacterSet.whitespaces)
    }
    
    func fittingSubstring(_ width: CGFloat, font: UIFont) -> String {
        for i in stride(from: characters.count, to: 0, by: -1) {
            let substr = self[0..<i]
            if substr.width(font) <= width {
                return substr
            }
        }
        return ""
    }

    func truncate(_ width: CGFloat, font: UIFont) -> String {
        let ellipsis = "..."
        let substr = fittingSubstring(width - ellipsis.width(font), font: font)
        if substr.characters.count != characters.count {
            return "\(substr.trim())\(ellipsis)"
        } else {
            return self
        }
    }
    
    // TODO Doesn't work - why?
//    func fittingSubstring(width: CGFloat, font: UIFont) -> String {
//        let fontRef = CTFontCreateWithName(font.fontName, font.pointSize, nil)
//        
//        let attributes: [String: AnyObject] = [String(kCTFontAttributeName): fontRef]
////        let attributes: [String: AnyObject] = [NSFontAttributeName : fontRef]
//        
//        let attributedString = NSAttributedString(string: self, attributes: attributes)
//        
//        let frameSetterRef = CTFramesetterCreateWithAttributedString(attributedString)
//        
//        var characterFitRange = CFRangeMake(0, 0)
//        CTFramesetterSuggestFrameSizeWithConstraints(frameSetterRef, CFRangeMake(0, 0), nil, CGSizeMake(width, font.lineHeight), &characterFitRange)
//        
//        let characterCount = characterFitRange.length
//        
//        return substringToIndex(startIndex.advancedBy(characterCount))
//    }
}
