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

@objc(UBSDKUpfrontFare) public class UpfrontFare: NSObject, Codable {
    /// A unique upfront fare identifier.
    @objc public private(set) var fareID: String

    /// The total upfront fare value.
    @objc public private(set) var value: Double

    /// ISO 4217 currency code.
    @objc public private(set) var currencyCode: String

    /// Formatted string of estimate in local currency.
    @objc public private(set) var display: String

    /// The upfront fare expiration time
    @objc public private(set) var expiresAt: Date

    /// The components that make up the upfront fare
    @objc public private(set) var breakdown: [UpfrontFareComponent]

    enum CodingKeys: String, CodingKey {
        case fareID = "fare_id"
        case value = "value"
        case currencyCode = "currency_code"
        case display = "display"
        case expiresAt = "expires_at"
        case breakdown = "breakdown"
    }

    public required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        fareID = try container.decode(String.self, forKey: .fareID)
        value = try container.decode(Double.self, forKey: .value)
        currencyCode = try container.decode(String.self, forKey: .currencyCode)
        display = try container.decode(String.self, forKey: .display)
        expiresAt = try container.decode(Date.self, forKey: .expiresAt)
        breakdown = try container.decode([UpfrontFareComponent].self, forKey: .breakdown)
    }
}

@objc(UBSDKUpfrontFareComponent) public class UpfrontFareComponent: NSObject, Codable {
    /// Upfront fare type
    @objc public private(set) var type: UpfrontFareComponentType

    /// Value of the upfront fare component
    @objc public private(set) var value: Double

    /// A string that can be displayed to the user representing this portion of the fare
    @objc public private(set) var name: String

    public required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        type = try container.decode(UpfrontFareComponentType.self, forKey: .type)
        value = try container.decode(Double.self, forKey: .value)
        name = try container.decode(String.self, forKey: .name)
    }
}

@objc(UBSDKUpfrontFareComponentType) public enum UpfrontFareComponentType: Int, Codable {
    /// Base fare
    case baseFare
    /// Promotion adjustment
    case promotion
    /// Unknown case.
    case unknown

    public init(from decoder: Decoder) throws {
        let string = try decoder.singleValueContainer().decode(String.self).lowercased()
        switch string.lowercased() {
        case "base_fare":
            self = .baseFare
        case "promotion":
            self = .promotion
        default:
            self = .unknown
        }
    }
}
