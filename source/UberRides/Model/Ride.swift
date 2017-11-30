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

// MARK: Ride

import CoreLocation

/**
 *  Contains the status of an ongoing/completed trip created using the Ride Request endpoint
 */
@objc(UBSDKRide) public class Ride: NSObject, Decodable {
    
    /// Contains the information about the destination of the trip, if one has been set.
    @objc public private(set) var destination: RideRequestLocation?
    
    /// The object that contains driver details. Only non-null during an ongoing trip.
    @objc public private(set) var driver: Driver?
    
    /// The object that contains the location information of the vehicle and driver.
    @objc public private(set) var driverLocation: RideRequestLocation?
    
    /// The object containing the information about the pickup for the trip.
    @objc public private(set) var pickup: RideRequestLocation?
    
    /// The unique ID of the Request.
    @objc public private(set) var requestID: String?

    /// The ID of the product
    @objc public private(set) var productID: String?
    
    /// The status of the Request indicating state.
    @objc public private(set) var status: RideStatus
    
    /// The surge pricing multiplier used to calculate the increased price of a Request.
    @nonobjc public private(set) var surgeMultiplier: Double?

    /// The surge pricing multiplier used to calculate the increased price of a Request.
    @objc(surgeMultiplier) public var objc_surgeMultiplier: NSNumber? {
        if let surgeMultiplier = surgeMultiplier {
            return NSNumber(value: surgeMultiplier)
        } else {
            return nil
        }
    }

    /// The object that contains vehicle details. Only non-null during an ongoing trip.
    @objc public private(set) var vehicle: Vehicle?

    /// True if the ride is an UberPOOL ride. False otherwise.
    @nonobjc public private(set) var isShared: Bool?

    /// True if the ride is an UberPOOL ride. False otherwise.
    @objc(isShared) public var objc_isShared: NSNumber? {
        if let isShared = isShared {
            return NSNumber(value: isShared)
        } else {
            return nil
        }
    }

    enum CodingKeys: String, CodingKey {
        case destination     = "destination"
        case driver          = "driver"
        case driverLocation  = "location"
        case pickup          = "pickup"
        case requestID       = "request_id"
        case productID       = "product_id"
        case surgeMultiplier = "surge_multiplier"
        case vehicle         = "vehicle"
        case status          = "status"
        case isShared        = "shared"
    }

    public required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        destination = try container.decodeIfPresent(RideRequestLocation.self, forKey: .destination)
        driver = try container.decodeIfPresent(Driver.self, forKey: .driver)
        driverLocation = try container.decodeIfPresent(RideRequestLocation.self, forKey: .driverLocation)
        pickup = try container.decodeIfPresent(RideRequestLocation.self, forKey: .pickup)
        requestID = try container.decodeIfPresent(String.self, forKey: .requestID)
        productID = try container.decodeIfPresent(String.self, forKey: .productID)
        surgeMultiplier = try container.decodeIfPresent(Double.self, forKey: .surgeMultiplier) ?? 1.0
        vehicle = try container.decodeIfPresent(Vehicle.self, forKey: .vehicle)
        status = try container.decodeIfPresent(RideStatus.self, forKey: .status) ?? .unknown
        isShared = try container.decodeIfPresent(Bool.self, forKey: .isShared)
    }
}
