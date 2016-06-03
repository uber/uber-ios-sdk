//
//  UberProduct.swift
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

import UIKit
import ObjectMapper

// MARK: UberProducts

/**
*  Internal object that contains a list of Uber products.
*/
struct UberProducts {
    var list: [UberProduct]?
    init?(_ map: Map){
    }
}

extension UberProducts: UberModel {
    mutating func mapping(map: Map) {
        list <- map["products"]
    }
}

// MARK: UberProduct

/**
*  Contains information for a single Uber product.
*/
@objc(UBSDKUberProduct) public class UberProduct: NSObject {
    /// Unique identifier representing a specific product for a given latitude & longitude.
    public private(set) var productID: String?
    
    /// Display name of product. Ex: "UberBLACK".
    public private(set) var name: String?
    
    /// Description of product. Ex: "The original Uber".
    public private(set) var details: String?
    
    /// Capacity of product. Ex: 4, for a product that fits 4.
    public private(set) var capacity: Int = 0
    
    /// Path of image URL representing the product.
    public private(set) var imagePath: String?
    
    /// The basic price details. See `PriceDetails` for structure.
    public private(set) var priceDetails: PriceDetails?
    
    public required init?(_ map: Map) {
    }
}

extension UberProduct : UberModel {
    public func mapping(map: Map) {
        productID    <- map["product_id"]
        name         <- map["display_name"]
        details      <- map["description"]
        capacity     <- map["capacity"]
        imagePath    <- map["image"]
        priceDetails <- map["price_details"]
    }
}

// MARK: PriceDetails

/**
*  Contains basic price details for an Uber product.
*/
@objc(UBSDKPriceDetails) public class PriceDetails : NSObject {
    /// Unit of distance used to calculate fare (mile or km).
    public private(set) var distanceUnit: String?
    
    /// ISO 4217 currency code.
    public private(set) var currencyCode: String?
    
    /// The charge per minute (if applicable).
    public private(set) var costPerMinute: Double = -1
    
    /// The charge per distance unit (if applicable).
    public private(set) var costPerDistance: Double = -1
    
    /// The base price.
    public private(set) var baseFee: Double = 0
    
    /// The minimum price of a trip.
    public private(set) var minimumFee: Double = 0
    
    /// The fee if a rider cancels the trip after a grace period.
    public private(set) var cancellationFee: Double = 0
    
    /// Array containing additional fees added to the price. See `ServiceFee`.
    public private(set) var serviceFees: [ServiceFee]?
    
    public required init?(_ map: Map) {
    }
}

extension PriceDetails : Mappable {
    public func mapping(map: Map) {
        distanceUnit    <- map["distance_unit"]
        currencyCode    <- map["currency_code"]
        costPerMinute   <- map["cost_per_minute"]
        costPerDistance <- map["cost_per_distance"]
        baseFee         <- map["base"]
        minimumFee      <- map["minimum"]
        cancellationFee <- map["cancellation_fee"]
        serviceFees     <- map["service_fees"]
    }
}

// MARK: ServiceFee

/**
*  Contains information for additional fees that can be added to the price of an Uber product.
*/
public class ServiceFee : NSObject {
    /// The name of the service fee.
    public private(set) var name: String?
    
    /// The amount of the service fee.
    public private(set) var fee: Double = 0.0
    
    public required init?(_ map: Map) {
    }
}

extension ServiceFee: Mappable {
    public func mapping(map: Map) {
        name <- map["name"]
        fee  <- map["fee"]
    }
}