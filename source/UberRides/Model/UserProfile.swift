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

import ObjectMapper

// MARK: UserProfile

/**
*  Information regarding an Uber user.
*/
@objc(UBSDKUserProfile) open class UserProfile: NSObject {
    /// First name of the Uber user.
    open fileprivate(set) var firstName: String?
    
    /// Last name of the Uber user.
    open fileprivate(set) var lastName: String?
    
    /// Email address of the Uber user.
    open fileprivate(set) var email: String?
    
    /// Image URL of the Uber user.
    open fileprivate(set) var picturePath: String?
    
    /// Promo code of the Uber user.
    open fileprivate(set) var promoCode: String?
    
    /// Unique identifier of the Uber user.
    open fileprivate(set) var UUID: String?
    
    public required init?(_ map: Map) {
    }
}

extension UserProfile: UberModel {
    public func mapping(_ map: Map) {
        firstName   <- map["first_name"]
        lastName    <- map["last_name"]
        email       <- map["email"]
        picturePath <- map["picture"]
        promoCode   <- map["promo_code"]
        UUID        <- map["uuid"]
    }
}
