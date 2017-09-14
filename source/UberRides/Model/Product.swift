//
//  Product.swift
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

// MARK: Products

/**
*  Internal object that contains a list of Uber products.
*/
struct UberProducts: Codable {
    var list: [Product]?

    enum CodingKeys: String, CodingKey {
        case list = "products"
    }
}

// MARK: Product

/**
*  Contains information for a single Uber product.
*/
@objc(UBSDKProduct) public class Product: NSObject, Codable {
    /// Unique identifier representing a specific product for a given latitude & longitude.
    @objc public private(set) var productID: String
    
    /// Display name of product. Ex: "UberBLACK".
    @objc public private(set) var name: String
    
    /// Description of product. Ex: "The original Uber".
    @objc public private(set) var productDescription: String
    
    /// Capacity of product. Ex: 4, for a product that fits 4.
    @objc public private(set) var capacity: Int
    
    /// Image URL representing the product.
    @objc public private(set) var imageURL: URL

    /// The basic price details. See `PriceDetails` for structure.
    @objc public private(set) var priceDetails: PriceDetails?

    /// Allows users to get upfront fares, instead of time + distance.
    @objc public private(set) var upfrontFareEnabled: Bool

    /// Specifies whether this product allows cash payments
    @objc public private(set) var cashEnabled: Bool

    /// Specifies whether this product allows for the pickup and drop off of other riders during the trip
    @objc public private(set) var isShared: Bool

    /// The product group that this product belongs to
    @objc public private(set) var productGroup: ProductGroup

    enum CodingKeys: String, CodingKey {
        case productID    = "product_id"
        case name         = "display_name"
        case productDescription      = "description"
        case capacity     = "capacity"
        case imageURL     = "image"
        case priceDetails = "price_details"
        case upfrontFareEnabled = "upfront_fare_enabled"
        case cashEnabled  = "cash_enabled"
        case isShared     = "shared"
        case productGroup = "product_group"
    }

    public required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        productID = try container.decode(String.self, forKey: .productID)
        name = try container.decode(String.self, forKey: .name)
        productDescription = try container.decode(String.self, forKey: .productDescription)
        capacity = try container.decode(Int.self, forKey: .capacity)
        imageURL = try container.decode(URL.self, forKey: .imageURL)
        priceDetails = try container.decodeIfPresent(PriceDetails.self, forKey: .priceDetails)
        upfrontFareEnabled = try container.decode(Bool.self, forKey: .upfrontFareEnabled)
        cashEnabled = try container.decode(Bool.self, forKey: .cashEnabled)
        isShared = try container.decode(Bool.self, forKey: .isShared)
        productGroup = try container.decode(ProductGroup.self, forKey: .productGroup)
    }
}

// MARK: PriceDetails

/**
*  Contains basic price details for an Uber product.
*/
@objc(UBSDKPriceDetails) public class PriceDetails: NSObject, Codable {
    /// Unit of distance used to calculate fare (mile or km).
    @objc public private(set) var distanceUnit: String
    
    /// ISO 4217 currency code.
    @objc public private(set) var currencyCode: String
    
    /// The charge per minute (if applicable).
    @objc public private(set) var costPerMinute: Double
    
    /// The charge per distance unit (if applicable).
    @objc public private(set) var costPerDistance: Double
    
    /// The base price.
    @objc public private(set) var baseFee: Double
    
    /// The minimum price of a trip.
    @objc public private(set) var minimumFee: Double
    
    /// The fee if a rider cancels the trip after a grace period.
    @objc public private(set) var cancellationFee: Double
    
    /// Array containing additional fees added to the price. See `ServiceFee`.
    @objc public private(set) var serviceFees: [ServiceFee]

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

    public required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        distanceUnit = try container.decode(String.self, forKey: .distanceUnit)
        currencyCode = try container.decode(String.self, forKey: .currencyCode)
        costPerMinute = try container.decode(Double.self, forKey: .costPerMinute)
        costPerDistance = try container.decode(Double.self, forKey: .costPerDistance)
        baseFee = try container.decode(Double.self, forKey: .baseFee)
        minimumFee = try container.decode(Double.self, forKey: .minimumFee)
        cancellationFee = try container.decode(Double.self, forKey: .cancellationFee)
        serviceFees = try container.decode([ServiceFee].self, forKey: .serviceFees)
    }
}

// MARK: ServiceFee

/**
*  Contains information for additional fees that can be added to the price of an Uber product.
*/
@objc(UBSDKServiceFee) public class ServiceFee: NSObject, Codable {
    /// The name of the service fee.
    @objc public private(set) var name: String
    
    /// The amount of the service fee.
    @objc public private(set) var fee: Double

    enum CodingKeys: String, CodingKey {
        case name = "name"
        case fee  = "fee"
    }

    public required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        name = try container.decode(String.self, forKey: .name)
        fee = try container.decode(Double.self, forKey: .fee)
    }
}

/// Uber Product Category
@objc(UBSDKProductGroup) public enum ProductGroup: Int, Codable {
    /// Shared rides products (eg, UberPOOL)
    case rideshare
    /// UberX
    case uberX
    /// UberXL
    case uberXL
    /// UberBLACK
    case uberBlack
    /// UberSUV
    case suv
    /// 3rd party taxis
    case taxi
    /// Unknown product group
    case unknown

    public init(from decoder: Decoder) throws {
        let string = try decoder.singleValueContainer().decode(String.self).lowercased()
        switch string {
        case "rideshare":
            self = .rideshare
        case "uberx":
            self = .uberX
        case "uberxl":
            self = .uberXL
        case "uberblack":
            self = .uberBlack
        case "suv":
            self = .suv
        case "taxi":
            self = .taxi
        default:
            self = .unknown
        }
    }
}
