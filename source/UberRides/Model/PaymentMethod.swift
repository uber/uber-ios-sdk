//
//  PaymentMethod.swift
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

// MARK: PaymentMethods

/**
 *  Internal struct for handling a list of payment methods
 */
struct PaymentMethods: Codable {
    var lastUsed: String?
    var list: [PaymentMethod]?

    enum CodingKeys: String, CodingKey {
        case lastUsed = "last_used"
        case list     = "payment_methods"
    }
}
// MARK: PaymentMethod

@objc(UBSDKPaymentMethod) public class PaymentMethod: NSObject, Codable {
    
    /// The account identification or description associated with the payment method.
    @objc public private(set) var paymentDescription: String?
    
    /// Unique identifier of the payment method.
    @objc public private(set) var methodID: String?
    
    /// The type of the payment method. See https://developer.uber.com/docs/v1-payment-methods.
    @objc public private(set) var type: String?

    enum CodingKeys: String, CodingKey {
        case paymentDescription = "description"
        case methodID           = "payment_method_id"
        case type               = "type"
    }

    public required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        paymentDescription = try container.decodeIfPresent(String.self, forKey: .paymentDescription)
        methodID = try container.decodeIfPresent(String.self, forKey: .methodID)
        type = try container.decodeIfPresent(String.self, forKey: .type)
    }
}
