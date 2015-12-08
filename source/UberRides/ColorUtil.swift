//
//  ColorUtil.swift
//  UberRides
//
//  Copyright © 2015 Uber Technologies, Inc. All rights reserved.
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.


import Foundation

@objc internal enum UberButtonColor: Int {
    case UberBlack
    case UberWhite
    case BlackHighlighted
    case WhiteHighlighted
}

private func hexCodeFromColor(color: UberButtonColor) -> String {
    switch color {
    case .UberBlack:
        return "09091A"
    case .UberWhite:
        return "C0C0C8"
    case .BlackHighlighted:
        return "222231"
    case .WhiteHighlighted:
        return "CDCDD3"
    }
}

// convert hex color code into UIColor
internal func uberUIColor(color: UberButtonColor) -> UIColor {
    let hexCode = hexCodeFromColor(color)
    let scanner = NSScanner(string: hexCode)
    var color: UInt32 = 0;
    scanner.scanHexInt(&color)
    
    let mask = 0x000000FF
    
    let redValue = CGFloat(Int(color >> 16)&mask)/255.0
    let greenValue = CGFloat(Int(color >> 8)&mask)/255.0
    let blueValue = CGFloat(Int(color)&mask)/255.0
    
    return UIColor(red: redValue, green: greenValue, blue: blueValue, alpha: 1.0)
}
