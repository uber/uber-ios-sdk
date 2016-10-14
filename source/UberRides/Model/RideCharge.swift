//
//  RideCharge.swift
//  UberRides
//
//  Copyright © 2016 Uber Technologies, Inc. All rights reserved.
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

import ObjectMapper

// MARK: RideCharge

/**
 *  Describes the charges made against the rider in a ride receipt.
 */
@objc(UBSDKRideCharge) open class RideCharge: NSObject {
    
    /// The amount of the charge.
    open fileprivate(set) var amount: Float = 0.0
    
    /// The name of the charge.
    open fileprivate(set) var name: String?
    
    /// The type of the charge.
    open fileprivate(set) var type: String?
    
    public required init?(_ map: Map) {
    }
}

extension RideCharge: UberModel {
    public func mapping(_ map: Map) {
        amount <- map["amount"]
        name   <- map["name"]
        type   <- map["type"]
    }
}
