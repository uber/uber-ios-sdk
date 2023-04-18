//
//  Ride.swift
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

// MARK: Par

/**
 *  Contains the status of an ongoing/completed trip created using the Ride Request endpoint
 */
@objc(UBSDKPar) public class Par: NSObject, Decodable {
    
    /// An identifier used for profile sharing
    @objc public private(set) var requestUri: String?
    
    /// Lifetime of the request_uri
    @objc public private(set) var expiresIn: NSNumber?

    enum CodingKeys: String, CodingKey {
        case requestUri = "request_uri"
        case expiresIn  = "expires_in"
    }
    
    public required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        requestUri = try container.decodeIfPresent(String.self, forKey: .requestUri)
        if let expiration = try container.decodeIfPresent(Int64.self, forKey: .expiresIn) {
            expiresIn = NSNumber(value: expiration)
        } else {
            expiresIn = nil
        }
    }
}
