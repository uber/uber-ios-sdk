//
//  UserActivity.swift
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

// MARK: TripHistory

/**
*  User's lifetime trip activity with Uber.
*/
@objc(UBSDKTripHistory) open class TripHistory: NSObject {
    /// Position in pagination.
    open fileprivate(set) var offset: Int = 0
    
    /// Number of items retrieved.
    open fileprivate(set) var limit: Int = 0
    
    /// Total number of items available.
    open fileprivate(set) var count: Int = 0
    
    /// Array of trip information.
    open fileprivate(set) var history: [UserActivity]?
    
    public required init?(_ map: Map) {
    }
}

extension TripHistory: UberModel {
    public func mapping(_ map: Map) {
        offset  <- map["offset"]
        limit   <- map["limit"]
        count   <- map["count"]
        history <- map["history"]
    }
}

// MARK: UserActivity

/**
*  Information regarding an Uber trip in a user's activity history.
*/
@objc(UBSDKUserActivity) open class UserActivity: NSObject {
    /// Status of the activity. Only returns completed for now.
    open fileprivate(set) var status: RideStatus?
    
    /// Length of activity in miles.
    open fileprivate(set) var distance: Float = 0.0
    
    /// Represents timestamp of activity request time in current locale.
    open fileprivate(set) var requestTime: Date?
    
    /// Represents timestamp of activity start time in current locale.
    open fileprivate(set) var startTime: Date?
    
    /// Represents timestamp of activity end time in current locale.
    open fileprivate(set) var endTime: Date?
    
    /// City that activity started in.
    open fileprivate(set) var startCity: TripCity?
    
    /// Unique activity identifier.
    open fileprivate(set) var requestID: String?
    
    /// Unique identifier representing a specific product for a given latitude & longitude.
    open fileprivate(set) var productID: String?
    
    public required init?(_ map: Map) {
    }
}

extension UserActivity: UberModel {
    public func mapping(_ map: Map) {
        distance    <- map["distance"]
        requestTime <- (map["request_time"], DateTransform())
        startTime   <- (map["start_time"], DateTransform())
        endTime     <- (map["end_time"], DateTransform())
        startCity   <- map["start_city"]
        requestID   <- map["request_id"]
        productID   <- map["product_id"]
        
        status = .unknown
        if let value = map["status"].currentValue as? String {
            status = RideStatusFactory.convertRideStatus(value)
        }
    }
}

// MARK: TripCity

/**
*  Information relating to a city in a trip activity.
*/
@objc(UBSDKTripCity) open class TripCity : NSObject {
    /// Latitude of city location.
    open fileprivate(set) var latitude: Float = 0.0
    
    /// Longitude of city location.
    open fileprivate(set) var longitude: Float = 0.0
    
    /// Display name of city.
    open fileprivate(set) var name: String?
    
    public required init?(_ map: Map) {
    }
}

extension TripCity: Mappable {
    public func mapping(_ map: Map) {
        latitude  <- map["latitude"]
        longitude <- map["longitude"]
        name      <- map["display_name"]
    }
}
