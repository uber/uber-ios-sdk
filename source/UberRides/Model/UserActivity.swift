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

import CoreLocation
import UberCore

// MARK: TripHistory

/**
*  User's lifetime trip activity with Uber.
*/
@objc(UBSDKTripHistory) public class TripHistory: NSObject, Decodable {
    /// Position in pagination.
    @objc public private(set) var offset: Int
    
    /// Number of items retrieved.
    @objc public private(set) var limit: Int
    
    /// Total number of items available.
    @objc public private(set) var count: Int
    
    /// Array of trip information.
    @objc public private(set) var history: [UserActivity]

    enum CodingKeys: String, CodingKey {
        case offset  = "offset"
        case limit   = "limit"
        case count   = "count"
        case history = "history"
    }

    public required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        offset = try container.decode(Int.self, forKey: .offset)
        limit = try container.decode(Int.self, forKey: .limit)
        count = try container.decode(Int.self, forKey: .count)
        history = try container.decode([UserActivity].self, forKey: .history)
    }
}

// MARK: UserActivity

/**
*  Information regarding an Uber trip in a user's activity history.
*/
@objc(UBSDKUserActivity) public class UserActivity: NSObject, Decodable {
    /// Status of the activity. Only returns completed for now.
    @objc public private(set) var status: RideStatus
    
    /// Length of activity in miles.
    @nonobjc public private(set) var distance: Double?

    /// Length of activity in miles.
    @objc(distance) public var objc_distance: NSNumber? {
        if let distance = distance {
            return NSNumber(value: distance)
        } else {
            return nil
        }
    }
    
    /// Represents timestamp of activity request time in current locale.
    @objc public private(set) var requestTime: Date?
    
    /// Represents timestamp of activity start time in current locale.
    @objc public private(set) var startTime: Date?
    
    /// Represents timestamp of activity end time in current locale.
    @objc public private(set) var endTime: Date?
    
    /// City that activity started in.
    @objc public private(set) var startCity: TripCity?
    
    /// Unique activity identifier.
    @objc public private(set) var requestID: String?
    
    /// Unique identifier representing a specific product for a given latitude & longitude.
    @objc public private(set) var productID: String?

    enum CodingKeys: String, CodingKey {
        case distance    = "distance"
        case requestTime = "request_time"
        case startTime   = "start_time"
        case endTime     = "end_time"
        case startCity   = "start_city"
        case requestID   = "request_id"
        case productID   = "product_id"
        case status      = "status"
    }
    public required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        distance = try container.decodeIfPresent(Double.self, forKey: .distance)
        requestTime = try container.decodeIfPresent(Date.self, forKey: .requestTime)
        startTime = try container.decodeIfPresent(Date.self, forKey: .startTime)
        endTime = try container.decodeIfPresent(Date.self, forKey: .endTime)
        startCity = try container.decodeIfPresent(TripCity.self, forKey: .startCity)
        requestID = try container.decodeIfPresent(String.self, forKey: .requestID)
        productID = try container.decodeIfPresent(String.self, forKey: .productID)
        status = try container.decodeIfPresent(RideStatus.self, forKey: .status) ?? .unknown
    }
}

// MARK: TripCity

/**
*  Information relating to a city in a trip activity.
*/
@objc(UBSDKTripCity) public class TripCity: NSObject, Decodable {
    /// Latitude of city location.
    /// - Warning: Deprecated. Use `location` instead.
    @nonobjc public var latitude: Double? {
        return location?.coordinate.latitude
    }

    /// Latitude of city location.
    /// - Warning: Deprecated. Use `location` instead.
    @objc(latitude) public var objc_latitude: NSNumber? {
        if let latitude = latitude {
            return NSNumber(value: latitude)
        } else {
            return nil
        }
    }

    /// Longitude of city location.
    /// - Warning: Deprecated. Use `location` instead.
    @nonobjc public var longitude: Double? {
        return location?.coordinate.longitude
    }

    /// Longitude of city location.
    /// - Warning: Deprecated. Use `location` instead.
    @objc(longitude) public var objc_longitude: NSNumber? {
        if let longitude = longitude {
            return NSNumber(value: longitude)
        } else {
            return nil
        }
    }

    /// City location
    @objc public private(set) var location: CLLocation?
    
    /// Display name of city.
    @objc public private(set) var name: String?

    enum CodingKeys: String, CodingKey {
        case latitude  = "latitude"
        case longitude = "longitude"
        case name      = "display_name"
    }

    public required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        if let latitude = try container.decodeIfPresent(Double.self, forKey: .latitude),
           let longitude = try container.decodeIfPresent(Double.self, forKey: .longitude) {
            location = CLLocation(latitude: latitude, longitude: longitude)
        }
        name = try container.decodeIfPresent(String.self, forKey: .name)
    }
}
