//
//  TimeEstimate.swift
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

// MARK: TimeEstimates

/**
*  Internal object that contains a list of ETAs for Uber products.
*/
struct TimeEstimates: Codable {
    var list: [TimeEstimate]?

    enum CodingKeys: String, CodingKey {
        case list = "times"
    }
}

// MARK: TimeEstimate

/**
*  Contains information regarding the ETA of an Uber product.
*/
@objc(UBSDKTimeEstimate) public class TimeEstimate: NSObject, Codable {
    /// Unique identifier representing a specific product for a given latitude & longitude.
    @objc public private(set) var productID: String?
    
    /// Display name of product. Ex: "UberBLACK".
    @objc public private(set) var name: String?
    
    /// ETA for the product (in seconds).
    @nonobjc public private(set) var estimate: Int?

    /// ETA for the product (in seconds).
    @objc(estimate) public var objc_estimate: NSNumber? {
        if let estimate = estimate {
            return NSNumber(value: estimate)
        } else {
            return nil
        }
    }

    enum CodingKeys: String, CodingKey {
        case productID = "product_id"
        case name      = "display_name"
        case estimate  = "estimate"
    }

    public required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        productID = try container.decodeIfPresent(String.self, forKey: .productID)
        name = try container.decodeIfPresent(String.self, forKey: .name)
        estimate = try container.decodeIfPresent(Int.self, forKey: .estimate)
    }
}
