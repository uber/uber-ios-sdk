//
//  Vehicle.swift
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

// MARK: Vehicle

/**
 *  Contains information for an Uber driver's car.
 */
@objc(UBSDKVehicle) open class Vehicle: NSObject {
    
    /// The license plate number of the vehicle.
    open fileprivate(set) var licensePlate: String?
    
    /// The vehicle make or brand.
    open fileprivate(set) var make: String?
    
    /// The vehicle model or type.
    open fileprivate(set) var model: String?
    
    /// The URL to a stock photo of the vehicle (may be null).
    open fileprivate(set) var pictureURL: String?
    
    public required init?(_ map: Map) {
    }
}

extension Vehicle: UberModel {
    public func mapping(_ map: Map) {
        make         <- map["make"]
        model        <- map["model"]
        licensePlate <- map["license_plate"]
        pictureURL   <- map["picture_url"]
    }
}
