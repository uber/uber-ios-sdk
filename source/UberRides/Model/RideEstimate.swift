//
//  RideEstimate.swift
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

// MARK: RideEstimate

/**
 *  Contains estimates for a desired ride request.
 */
@objc(UBSDKRideEstimate) public class RideEstimate: NSObject, Codable {

    /// Details of the estimated fare.
    @objc public private(set) var priceEstimate: PriceEstimate?
    
    /// Details of the estimated distance.
    @objc public private(set) var distanceEstimate: DistanceEstimate?

    /// The estimated time of vehicle arrival in minutes.
    @nonobjc public private(set) var pickupEstimate: Int?

    /// The estimated time of vehicle arrival in minutes. UBSDKEstimateUnavailable if there are no cars available.
    @objc(pickupEstimate) public var objc_pickupEstimate: NSNumber? {
        if let pickupEstimate = pickupEstimate {
            return NSNumber(value: pickupEstimate)
        } else {
            return nil
        }
    }

    /// Upfront Fare for the Ride Estimate. 
    @objc public private(set) var fare: UpfrontFare?

    enum CodingKeys: String, CodingKey {
        case priceEstimate    = "estimate"
        case distanceEstimate = "trip"
        case pickupEstimate   = "pickup_estimate"
        case fare = "fare"
    }

    public required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        priceEstimate = try container.decodeIfPresent(PriceEstimate.self, forKey: .priceEstimate)
        distanceEstimate = try container.decodeIfPresent(DistanceEstimate.self, forKey: .distanceEstimate)
        pickupEstimate = try container.decodeIfPresent(Int.self, forKey: .pickupEstimate)
        pickupEstimate = pickupEstimate != -1 ? pickupEstimate : nil
        fare = try container.decodeIfPresent(UpfrontFare.self, forKey: .fare)
    }
}
