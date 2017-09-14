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

// MARK: UberProducts

/**
*  Internal object that contains a list of Uber products.
*/
struct UberProducts: Codable {
    var list: [UberProduct]?

    enum CodingKeys: String, CodingKey {
        case list = "products"
    }
}

// MARK: UberProduct

/**
*  Contains information for a single Uber product.
*/
@objc(UBSDKUberProduct) public class UberProduct: NSObject, Codable {
    /// Unique identifier representing a specific product for a given latitude & longitude.
    @objc public private(set) var productID: String
    
    /// Display name of product. Ex: "UberBLACK".
    @objc public private(set) var name: String
    
    /// Description of product. Ex: "The original Uber".
    @objc public private(set) var details: String
    
    /// Capacity of product. Ex: 4, for a product that fits 4.
    @objc public private(set) var capacity: Int
    
    /// Path of image URL representing the product.
    @objc public private(set) var imagePath: URL
    
    /// The basic price details. See `PriceDetails` for structure.
    @objc public private(set) var priceDetails: PriceDetails?

    enum CodingKeys: String, CodingKey {
        case productID    = "product_id"
        case name         = "display_name"
        case details      = "description"
        case capacity     = "capacity"
        case imagePath    = "image"
        case priceDetails = "price_details"
    }

    public required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        productID = try container.decode(String.self, forKey: .productID)
        name = try container.decode(String.self, forKey: .name)
        details = try container.decode(String.self, forKey: .details)
        capacity = try container.decode(Int.self, forKey: .capacity)
        imagePath = try container.decode(URL.self, forKey: .imagePath)
        priceDetails = try container.decodeIfPresent(PriceDetails.self, forKey: .priceDetails)
    }
}

// MARK: PriceDetails

/**
*  Contains basic price details for an Uber product.
*/
@objc(UBSDKPriceDetails) public class PriceDetails: NSObject, Codable {
    /// Unit of distance used to calculate fare (mile or km).
    @objc public private(set) var distanceUnit: String?
    
    /// ISO 4217 currency code.
    @objc public private(set) var currencyCode: String?
    
    /// The charge per minute (if applicable).
    @objc public private(set) var costPerMinute: Double = -1
    
    /// The charge per distance unit (if applicable).
    @objc public private(set) var costPerDistance: Double = -1
    
    /// The base price.
    @objc public private(set) var baseFee: Double = 0
    
    /// The minimum price of a trip.
    @objc public private(set) var minimumFee: Double = 0
    
    /// The fee if a rider cancels the trip after a grace period.
    @objc public private(set) var cancellationFee: Double = 0
    
    /// Array containing additional fees added to the price. See `ServiceFee`.
    @objc public private(set) var serviceFees: [ServiceFee]?

    enum CodingKeys: String, CodingKey {
        case distanceUnit    = "distance_unit"
        case currencyCode    = "currency_code"
        case costPerMinute   = "cost_per_minute"
        case costPerDistance = "cost_per_distance"
        case baseFee         = "base"
        case minimumFee      = "minimum"
        case cancellationFee = "cancellation_fee"
        case serviceFees     = "service_fees"
    }
}

// MARK: ServiceFee

/**
*  Contains information for additional fees that can be added to the price of an Uber product.
*/
public class ServiceFee: NSObject, Codable {
    /// The name of the service fee.
    @objc public private(set) var name: String?
    
    /// The amount of the service fee.
    @objc public private(set) var fee: Double = 0.0

    enum CodingKeys: String, CodingKey {
        case name = "name"
        case fee  = "fee"
    }
}
