//
//  RideRequestLocation.swift
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

// MARK: RideRequestLocation

/**
 *  Location of a pickup or destination in a ride request.
 */
@objc(UBSDKRideRequestLocation) open class RideRequestLocation: NSObject {
    
    /// The current bearing in degrees for a moving location.
    open fileprivate(set) var bearing: Int = 0
    
    /// ETA is only available when the trips is accepted or arriving.
    open fileprivate(set) var eta: Int = 0
    
    /// The latitude of the location.
    open fileprivate(set) var latitude: Double = 0
    
    /// The longitude of the location.
    open fileprivate(set) var longitude: Double = 0
    
    public required init?(map: Map) {
    }
}

extension RideRequestLocation: UberModel {
    public func mapping(map: Map) {
        bearing   <- map["bearing"]
        eta       <- map["eta"]
        latitude  <- map["latitude"]
        longitude <- map["longitude"]
    }
}
