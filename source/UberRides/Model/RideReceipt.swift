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
    @objc public private(set) var chargeAdjustments: [RideCharge]?
    
    /// ISO 4217
    @objc public private(set) var currencyCode: String?
    
    /// Distance of the trip charged.
    @objc public private(set) var distance: String?
    
    /// The localized unit of distance.
    @objc public private(set) var distanceLabel: String?
    
    /// Time duration of the trip. Use only the hour, minute, and second components.
    @objc public private(set) var duration: DateComponents?
    
    /// Unique identifier representing a Request.
    @objc public private(set) var requestID: String?
    
    /// The summation of the normal fare and surge charge amount.
    @objc public private(set) var subtotal: String?
    
    /// The total amount charged to the users payment method. This is the the subtotal (split if applicable) with taxes included.
    @objc public private(set) var totalCharged: String?
    
    /// The total amount still owed after attempting to charge the user. May be 0 if amount was paid in full.
    @nonobjc public private(set) var totalOwed: Double?

    /// The total amount still owed after attempting to charge the user. May be 0 if amount was paid in full.
    @objc(totalOwed) public var objc_totalOwed: NSNumber? {
        if let totalOwed = totalOwed {
            return NSNumber(value: totalOwed)
        } else {
            return nil
        }
    }

    /// The fare after credits and refunds have been applied.
    @objc public private(set) var totalFare: String?

    enum CodingKeys: String, CodingKey {
        case chargeAdjustments = "charge_adjustments"
        case currencyCode      = "currency_code"
        case distance          = "distance"
        case distanceLabel     = "distance_label"
        case duration          = "duration"
        case requestID         = "request_id"
        case subtotal          = "subtotal"
        case totalCharged      = "total_charged"
        case totalOwed         = "total_owed"
        case totalFare         = "total_fare"
    }

    public required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        chargeAdjustments = try container.decodeIfPresent([RideCharge].self, forKey: .chargeAdjustments)
        currencyCode = try container.decodeIfPresent(String.self, forKey: .currencyCode)
        distance = try container.decodeIfPresent(String.self, forKey: .distance)
        distanceLabel = try container.decodeIfPresent(String.self, forKey: .distanceLabel)
        requestID = try container.decodeIfPresent(String.self, forKey: .requestID)
        subtotal = try container.decodeIfPresent(String.self, forKey: .subtotal)
        totalCharged = try container.decodeIfPresent(String.self, forKey: .totalCharged)
        totalOwed = try container.decodeIfPresent(Double.self, forKey: .totalOwed) ?? 0.0
        totalFare = try container.decodeIfPresent(String.self, forKey: .totalFare)

        let durationString = try container.decodeIfPresent(String.self, forKey: .duration)
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "HH:mm:ss"
        dateFormatter.calendar = Calendar.current
        var date = Date(timeIntervalSince1970: 0)
        if let durationString = durationString,
           let dateFromDuration = dateFormatter.date(from: durationString) {
            date = dateFromDuration
        }
        duration = Calendar.current.dateComponents(in: TimeZone.current, from: date)
    }
}
