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

import UberCore

// MARK: RideRequestLocation

/**
 *  Location of a pickup or destination in a ride request.
 */
@objc(UBSDKRideRequestLocation) public class RideRequestLocation: NSObject, Codable {
    /**
      The alias from an Uber user’s profile mapped to the pickup address (if available).
      Can be either work or home. Only exposed with a valid access token for places scope.
     */
    @objc public private(set) var alias: String?

    /// The name of the pickup place (if available). Not exposed in sandbox.
    @objc public private(set) var name: String?
    
    /// The current bearing in degrees for a moving location.
    @nonobjc public private(set) var bearing: Int?

    /// The current bearing in degrees for a moving location.
    @objc(bearing) public var objc_bearing: NSNumber? {
        if let bearing = bearing {
            return NSNumber(value: bearing)
        } else {
            return nil
        }
    }

    /// ETA is only available when the trips is accepted or arriving.
    @nonobjc public private(set) var eta: Int?

    /// ETA is only available when the trips is accepted or arriving.
    @objc(eta) public var objc_eta: NSNumber? {
        if let eta = eta {
            return NSNumber(value: eta)
        } else {
            return nil
        }
    }

    /// The latitude of the location.
    @nonobjc public private(set) var latitude: Double?

    /// The latitude of the location.
    @objc(latitude) public var objc_latitude: NSNumber? {
        if let latitude = latitude {
            return NSNumber(value: latitude)
        } else {
            return nil
        }
    }

    /// The longitude of the location.
    @nonobjc public private(set) var longitude: Double?

    /// The longitude of the location.
    @objc(longitude) public var objc_longitude: NSNumber? {
        if let longitude = longitude {
            return NSNumber(value: longitude)
        } else {
            return nil
        }
    }

    public required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        alias = try container.decodeIfPresent(String.self, forKey: .alias)
        name = try container.decodeIfPresent(String.self, forKey: .name)
        bearing = try container.decodeIfPresent(Int.self, forKey: .bearing)
        eta = try container.decodeIfPresent(Int.self, forKey: .eta)
        eta = eta != -1 ? eta : nil // Since the API returns -1, converting to an optional. 
        latitude = try container.decodeIfPresent(Double.self, forKey: .latitude)
        longitude = try container.decodeIfPresent(Double.self, forKey: .longitude)
    }
}
