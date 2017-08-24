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

// MARK: RideEstimate

/**
 *  Contains estimates for a desired ride request.
 */
@objc(UBSDKRideEstimate) public class RideEstimate: NSObject, Codable {
    
    /// Details of the estimated fare. If end location omitted, only the minimum is returned.
    @objc public private(set) var priceEstimate: PriceEstimate?
    
    /// Details of the estimated distance. Nil if end location is omitted.
    @objc public private(set) var distanceEstimate: DistanceEstimate?
    
    /// The estimated time of vehicle arrival in minutes. -1 if there are no cars available.
    @objc public private(set) var pickupEstimate: Int

    enum CodingKeys: String, CodingKey {
        case priceEstimate    = "price"
        case distanceEstimate = "trip"
        case pickupEstimate   = "pickup_estimate"
    }

    public required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        priceEstimate = try container.decodeIfPresent(PriceEstimate.self, forKey: .priceEstimate)
        distanceEstimate = try container.decodeIfPresent(DistanceEstimate.self, forKey: .distanceEstimate)
        pickupEstimate = try container.decodeIfPresent(Int.self, forKey: .pickupEstimate) ?? -1
    }
}
