//
//  Ride.swift
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

// MARK: Ride

/**
 *  Contains the status of an ongoing/completed trip created using the Ride Request endpoint
 */
@objc(UBSDKRide) open class Ride: NSObject {
    
    /// Contains the information about the destination of the trip, if one has been set.
    open fileprivate(set) var destination: RideRequestLocation?
    
    /// The object that contains driver details. Only non-null during an ongoing trip.
    open fileprivate(set) var driver: Driver?
    
    /// The object that contains the location information of the vehicle and driver.
    open fileprivate(set) var driverLocation: RideRequestLocation?
    
    /// The estimated time of vehicle arrival in minutes.
    open fileprivate(set) var eta: Int = 0
    
    /// The object containing the information about the pickup for the trip.
    open fileprivate(set) var pickup: RideRequestLocation?
    
    /// The unique ID of the Request.
    open fileprivate(set) var requestID: String?
    
    /// The status of the Request indicating state.
    open fileprivate(set) var status: RideStatus?
    
    /// The surge pricing multiplier used to calculate the increased price of a Request.
    open fileprivate(set) var surgeMultiplier: Double = 1.0
    
    /// The object that contains vehicle details. Only non-null during an ongoing trip.
    open fileprivate(set) var vehicle: Vehicle?
    
    public required init?(map: Map) {
    }
}

extension Ride: UberModel {
    public func mapping(map: Map) {
        destination     <- map["destination"]
        driver          <- map["driver"]
        driverLocation  <- map["location"]
        eta             <- map["eta"]
        pickup          <- map["pickup"]
        requestID       <- map["request_id"]
        surgeMultiplier <- map["surge_multiplier"]
        vehicle         <- map["vehicle"]
        
        status = .unknown
        if let value = map["status"].currentValue as? String {
            status = RideStatusFactory.convertRideStatus(value)
        }
    }
}
