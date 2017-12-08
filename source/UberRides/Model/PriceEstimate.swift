//
//  PriceEstimate.swift
//  UberRides
//
//  Copyright © 2015 Uber Technologies, Inc. All rights reserved.
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

// MARK: PriceEstimates

/**
*  Internal object that contains a list of price estimates for Uber products.
*/
struct PriceEstimates: Codable {
    var list: [PriceEstimate]?

    enum CodingKeys: String, CodingKey {
        case list = "prices"
    }
}

// MARK: PriceEstimate

/**
*  Contains information about estimated price range for each Uber product offered at a location.
*/
@objc(UBSDKPriceEstimate) public class PriceEstimate: NSObject, Codable {
    
    /// ISO 4217 currency code.
    @objc public private(set) var currencyCode: String?

    /// Expected activity distance (in miles).
    @nonobjc public private(set) var distance: Double?

    /// Expected activity distance (in miles).
    @objc(distance) public var objc_distance: NSNumber? {
        if let distance = distance {
            return NSNumber(value: distance)
        } else {
            return nil
        }
    }

    /// Expected activity duration (in seconds).
    @nonobjc public private(set) var duration: Int?

    /// Expected activity duration (in seconds).
    @objc(duration) public var objc_duration: NSNumber? {
        if let duration = duration {
            return NSNumber(value: duration)
        } else {
            return nil
        }
    }

    /// A formatted string representing the estimate in local currency. Could be range, single number, or "Metered" for TAXI.
    @objc public private(set) var estimate: String?

    /// Upper bound of the estimated price.
    @nonobjc public private(set) var highEstimate: Int?

    /// Upper bound of the estimated price.
    @objc(highEstimate) public var objc_highEstimate: NSNumber? {
        if let highEstimate = highEstimate {
            return NSNumber(value: highEstimate)
        } else {
            return nil
        }
    }

    /// Lower bound of the estimated price.
    @nonobjc public private(set) var lowEstimate: Int?

    /// Lower bound of the estimated price.
    @objc(lowEstimate) public var objc_lowEstimate: NSNumber? {
        if let lowEstimate = lowEstimate {
            return NSNumber(value: lowEstimate)
        } else {
            return nil
        }
    }

    /// Display name of product. Ex: "UberBLACK".
    @objc public private(set) var name: String?

    /// Unique identifier representing a specific product for a given latitude & longitude.
    @objc public private(set) var productID: String?

    /// The unique identifier of the surge session for a user. Nil for no surge.
    @objc public private(set) var surgeConfirmationID: String?

    /// The URL a user must visit to accept surge pricing.
    @objc public private(set) var surgeConfirmationURL: URL?

    /// Expected surge multiplier (active if surge is greater than 1).
    @nonobjc public private(set) var surgeMultiplier: Double?

    /// Expected surge multiplier (active if surge is greater than 1).
    @objc(surgeMultiplier) public var objc_surgeMultiplier: NSNumber? {
        if let surgeMultiplier = surgeMultiplier {
            return NSNumber(value: surgeMultiplier)
        } else {
            return nil
        }
    }

    enum CodingKeys: String, CodingKey {
        case currencyCode         = "currency_code"
        case distance             = "distance"
        case duration             = "duration"
        case estimate             = "estimate"
        case highEstimate         = "high_estimate"
        case lowEstimate          = "low_estimate"
        case name                 = "display_name"
        case productID            = "product_id"
        case surgeConfirmationID  = "surge_confirmation_id"
        case surgeConfirmationURL = "surge_confirmation_href"
        case surgeMultiplier      = "surge_multiplier"
    }

    public required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        currencyCode = try container.decodeIfPresent(String.self, forKey: .currencyCode)
        distance = try container.decodeIfPresent(Double.self, forKey: .distance)
        duration = try container.decodeIfPresent(Int.self, forKey: .duration)
        estimate = try container.decodeIfPresent(String.self, forKey: .estimate)
        highEstimate = try container.decodeIfPresent(Int.self, forKey: .highEstimate)
        lowEstimate = try container.decodeIfPresent(Int.self, forKey: .lowEstimate)
        name = try container.decodeIfPresent(String.self, forKey: .name)
        productID = try container.decodeIfPresent(String.self, forKey: .productID)
        surgeConfirmationID = try container.decodeIfPresent(String.self, forKey: .surgeConfirmationID)
        surgeConfirmationURL = try container.decodeIfPresent(URL.self, forKey: .surgeConfirmationURL)
        surgeMultiplier = try container.decodeIfPresent(Double.self, forKey: .surgeMultiplier)
    }
}
