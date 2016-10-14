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

import ObjectMapper

// MARK: PriceEstimates

/**
*  Internal object that contains a list of price estimates for Uber products.
*/
struct PriceEstimates {
    var list: [PriceEstimate]?
    init?(_ map: Map) {
    }
}

extension PriceEstimates: UberModel {
    mutating func mapping(_ map: Map) {
        list <- map["prices"]
    }
}

// MARK: PriceEstimate

/**
*  Contains information about estimated price range for each Uber product offered at a location.
*/
@objc(UBSDKPriceEstimate) open class PriceEstimate: NSObject {
    
    /// ISO 4217 currency code.
    open fileprivate(set) var currencyCode: String?
    
    /// Expected activity distance (in miles).
    open fileprivate(set) var distance: Double = 0.0
    
    /// Expected activity duration (in seconds).
    open fileprivate(set) var duration: Int = 0
    
    /// A formatted string representing the estimate in local currency. Could be range, single number, or "Metered" for TAXI.
    open fileprivate(set) var estimate: String?
    
    /// Upper bound of the estimated price.
    open fileprivate(set) var highEstimate: Int = 0
    
    /// Lower bound of the estimated price.
    open fileprivate(set) var lowEstimate: Int = 0
    
    /// Display name of product. Ex: "UberBLACK".
    open fileprivate(set) var name: String?
    
    /// Unique identifier representing a specific product for a given latitude & longitude.
    open fileprivate(set) var productID: String?
    
    /// The unique identifier of the surge session for a user. Nil for no surge.
    open fileprivate(set) var surgeConfirmationID: String?
    
    /// The URL a user must visit to accept surge pricing.
    open fileprivate(set) var surgeConfirmationURL: String?
    
    /// Expected surge multiplier (active if surge is greater than 1).
    open fileprivate(set) var surgeMultiplier: Double = 1.0
    
    public required init?(_ map: Map) {
    }
}

extension PriceEstimate: UberModel {
    public func mapping(_ map: Map) {
        currencyCode         <- map["currency_code"]
        distance             <- map["distance"]
        duration             <- map["duration"]
        estimate             <- map["estimate"]
        highEstimate         <- map["high_estimate"]
        lowEstimate          <- map["low_estimate"]
        name                 <- map["display_name"]
        productID            <- map["product_id"]
        surgeConfirmationID  <- map["surge_confirmation_id"]
        surgeConfirmationURL <- map["surge_confirmation_href"]
        surgeMultiplier      <- map["surge_multiplier"]
    }
}
