//
//  AccessToken.swift
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

import ObjectMapper

/// Stores information about an access token used for authorizing requests.
@objc(UBSDKAccessToken) public class AccessToken: NSObject, NSCoding, UberModel {
    
    /// String containing the bearer token.
    public private(set) var tokenString: String?
    
    /// String containing the refresh token.
    public private(set) var refreshToken: String?
    
    /// The expiration date for this access token
    public private(set) var expirationDate: NSDate?
    
    /// The scopes this token is valid for
    public private(set) var grantedScopes: [RidesScope]?
    
    /**
     Initializes an AccessToken with the provided tokenString
     
     - parameter tokenString: The tokenString to use for this AccessToken
     
     - returns: an initialized AccessToken object
     */
    @objc public init(tokenString: String) {
        super.init()
        self.tokenString = tokenString
    }
    
    /**
     Initializer to build an accessToken from the provided NSCoder. Allows for 
     serialization of an AccessToken
     
     - parameter decoder: The NSCoder to decode the AcccessToken from
     
     - returns: An initialized AccessToken, or nil if something went wrong
     */
    @objc public required init?(coder decoder: NSCoder) {
        super.init()
        guard let token = decoder.decodeObjectForKey("tokenString") as? String else {
            return nil
        }
        tokenString = token
        refreshToken = decoder.decodeObjectForKey("refreshToken") as? String
        expirationDate = decoder.decodeObjectForKey("expirationDate") as? NSDate
        if let scopesString = decoder.decodeObjectForKey("grantedScopes") as? String {
            grantedScopes = scopesString.toRidesScopesArray()
        }
    }

    /**
     Required initializer for ObjectMapper
     
     - parameter map: The Map to build an AccessToken from
     
     - returns: An initialized AccessToken, or nil if someting went wrong
     */
    public required init?(_ map: Map) {
    }
    
    /**
     Encodes the AccessToken. Required to allow for serialization
     
     - parameter coder: The NSCoder to encode the access token on
     */
    @objc public func encodeWithCoder(coder: NSCoder) {
        coder.encodeObject(self.tokenString, forKey: "tokenString")
        coder.encodeObject(self.refreshToken, forKey:  "refreshToken")
        coder.encodeObject(self.expirationDate, forKey: "expirationDate")
        coder.encodeObject(self.grantedScopes?.toRidesScopeString(), forKey: "grantedScopes")
    }
    
    /**
     Mapping function used by ObjectMapper. Builds an AccessToken using the provided
     Map data
     
     - parameter map: The Map to use for populatng this AccessToken.
     */
    public func mapping(map: Map) {
        tokenString         <- map["access_token"]
        refreshToken        <- map["refresh_token"]
        expirationDate <- (map["expiration_date"], DateTransform())
        var scopesString = String()
        scopesString <- map["scope"]
        grantedScopes = scopesString.toRidesScopesArray()
    }
}
