//
//  ColorUtil.swift
//  Rides
//
//  Copyright © 2015 Uber Technologies, Inc. All rights reserved.
//

import Foundation

internal enum UberButtonColor {
    case uberBlack
    case uberWhite
    case blackHighlighted
    case whiteHighlighted
}

private func encodeColor(color: UberButtonColor) -> String {
    switch color {
    case .uberBlack:
        return "09091A"
    case .uberWhite:
        return "C0C0C8"
    case .blackHighlighted:
        return "222231"
    case .whiteHighlighted:
        return "CDCDD3"
    }
}

// convert hex color code into UIColor
internal func uberUIColor(color: UberButtonColor) -> UIColor {
    let hexCode = encodeColor(color)
    let scanner = NSScanner(string: hexCode)
    var color: UInt32 = 0;
    scanner.scanHexInt(&color)
    
    let mask = 0x000000FF
    
    let redValue = CGFloat(Int(color >> 16)&mask)/255.0
    let greenValue = CGFloat(Int(color >> 8)&mask)/255.0
    let blueValue = CGFloat(Int(color)&mask)/255.0
    
    return UIColor(red: redValue, green: greenValue, blue: blueValue, alpha: 1.0)
}
