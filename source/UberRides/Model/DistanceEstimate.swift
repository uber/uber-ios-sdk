//
//  DistanceEstimate.swift
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

// MARK: DistanceEstimate

/**
 *  Estimate information on an Uber trip.
 */
@objc(UBSDKDistanceEstimate) open class DistanceEstimate: NSObject {
    
    /// Expected activity distance.
    open fileprivate(set) var distance: Double = 0.0
    
    /// The unit of distance (mile or km).
    open fileprivate(set) var distanceUnit: String?
    
    /// Expected activity duration (in seconds).
    open fileprivate(set) var duration: Int = 0
    
    public required init?(map: Map) {
    }
}

extension DistanceEstimate: UberModel {
    public func mapping(map: Map) {
        distance     <- map["distance_estimate"]
        distanceUnit <- map["distance_unit"]
        duration     <- map["duration_estimate"]
    }
}
