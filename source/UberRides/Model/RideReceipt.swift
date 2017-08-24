//
//  RideReceipt.swift
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

// MARK: RideReceipt

/**
 *  Get the receipt information of a completed request that was made with the request endpoint.
 */
@objc(UBSDKRideReceipt) public class RideReceipt: NSObject, Codable {
    
    /// Adjustments made to the charges such as promotions, and fees.
    @objc public private(set) var chargeAdjustments: [RideCharge]
    
    /// Describes the charges made against the rider.
    @objc public private(set) var charges: [RideCharge]
    
    /// ISO 4217
    @objc public private(set) var currencyCode: String
    
    /// Distance of the trip charged.
    @objc public private(set) var distance: String
    
    /// The localized unit of distance.
    @objc public private(set) var distanceLabel: String
    
    /// Time duration of the trip in ISO 8601 HH:MM:SS format.
    @objc public private(set) var duration: String // TODO
    
    /// The summation of the charges array.
    @objc public private(set) var normalFare: String
    
    /// Unique identifier representing a Request.
    @objc public private(set) var requestID: String
    
    /// The summation of the normal fare and surge charge amount.
    @objc public private(set) var subtotal: String
    
    /// Describes the surge charge. May be null if surge pricing was not in effect.
    @objc public private(set) var surgeCharge: RideCharge?
    
    /// The total amount charged to the users payment method. This is the the subtotal (split if applicable) with taxes included.
    @objc public private(set) var totalCharged: String
    
    /// The total amount still owed after attempting to charge the user. May be 0 if amount was paid in full.
    @objc public private(set) var totalOwed: Double

    enum CodingKeys: String, CodingKey {
        case chargeAdjustments = "charge_adjustments"
        case charges           = "charges"
        case currencyCode      = "currency_code"
        case distance          = "distance"
        case distanceLabel     = "distance_label"
        case duration          = "duration"
        case normalFare        = "normal_fare"
        case requestID         = "request_id"
        case subtotal          = "subtotal"
        case surgeCharge       = "surge_charge"
        case totalCharged      = "total_charged"
        case totalOwed         = "total_owed"
    }

    public required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        chargeAdjustments = try container.decode([RideCharge].self, forKey: .chargeAdjustments)
        charges = try container.decode([RideCharge].self, forKey: .charges)
        currencyCode = try container.decode(String.self, forKey: .currencyCode)
        distance = try container.decode(String.self, forKey: .distance)
        distanceLabel = try container.decode(String.self, forKey: .distanceLabel)
        duration = try container.decode(String.self, forKey: .duration)
        normalFare = try container.decode(String.self, forKey: .normalFare)
        requestID = try container.decode(String.self, forKey: .requestID)
        subtotal = try container.decode(String.self, forKey: .subtotal)
        surgeCharge = try container.decodeIfPresent(RideCharge.self, forKey: .surgeCharge)
        totalCharged = try container.decode(String.self, forKey: .totalCharged)
        totalOwed = try container.decodeIfPresent(Double.self, forKey: .totalOwed) ?? 0.0
    }
}
