//
//  Driver.swift
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

// MARK: Driver

/**
 *  Contains information for an Uber driver dispatched for a ride request.
 */
@objc(UBSDKDriver) open class Driver: NSObject {
    
    /// The first name of the driver.
    open fileprivate(set) var name: String?
    
    /// The URL to the photo of the driver.
    open fileprivate(set) var pictureURL: String?
    
    /// The formatted phone number for contacting the driver.
    open fileprivate(set) var phoneNumber: String?
    
    /// The driver's star rating out of 5 stars.
    open fileprivate(set) var rating: Double = 0.0
    
    public required init?(_ map: Map) {
    }
}

extension Driver: UberModel {
    public func mapping(_ map: Map) {
        name        <- map["name"]
        pictureURL  <- map["picture_url"]
        phoneNumber <- map["phone_number"]
        rating      <- map["rating"]
    }
}
