//
//  UserProfile.swift
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

// MARK: UserProfile

/**
*  Information regarding an Uber user.
*/
@objc(UBSDKUserProfile) public class UserProfile: NSObject, Codable {
    /// First name of the Uber user.
    @objc public private(set) var firstName: String?
    
    /// Last name of the Uber user.
    @objc public private(set) var lastName: String?
    
    /// Email address of the Uber user.
    @objc public private(set) var email: String?
    
    /// Image URL of the Uber user.
    @objc public private(set) var picturePath: String?
    
    /// Promo code of the Uber user.
    @objc public private(set) var promoCode: String?

    /// Unique identifier of the Uber user. Deprecated, use riderID instead.
    @available(*, deprecated, message:"use riderID instead")
    @objc public var UUID: String? {
        // This implementation gets rid of the deprecated warning while compiling this SDK.
        return _UUID
    }
    private let _UUID: String?

    /// Unique identifier of the Uber user.
    @objc public private(set) var riderID: String?

    enum CodingKeys: String, CodingKey {
        case firstName   = "first_name"
        case lastName    = "last_name"
        case email       = "email"
        case picturePath = "picture"
        case promoCode   = "promo_code"
        case _UUID        = "uuid"
        case riderID     = "rider_id"
    }

    public required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        firstName = try container.decodeIfPresent(String.self, forKey: .firstName)
        lastName = try container.decodeIfPresent(String.self, forKey: .lastName)
        email = try container.decodeIfPresent(String.self, forKey: .email)
        picturePath = try container.decodeIfPresent(String.self, forKey: .picturePath)
        promoCode = try container.decodeIfPresent(String.self, forKey: .promoCode)
        _UUID = try container.decodeIfPresent(String.self, forKey: ._UUID)
        riderID = try container.decodeIfPresent(String.self, forKey: .riderID)
    }
}
