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

/**
 Stores information about an access token used for authorizing requests.
 
 This class implements NSCoding, but its representation is an internal representation
 not compatible with the OAuth representation. Use an initializer if you want to serialize this
 via an OAuth representation.
 */
@objc(UBSDKAccessToken) public class AccessToken: NSObject, NSCoding {
    /// String containing the bearer token.
    @objc public private(set) var tokenString: String
    
    /// String containing the refresh token.
    @objc public private(set) var refreshToken: String?
    
    /// String containing the token type.
    @objc public private(set) var tokenType: String?
    
    /// The expiration date for this access token
    @objc public private(set) var expirationDate: Date?
    
    /// The scopes this token is valid for
    @objc public private(set) var grantedScopes: [UberScope] = []
    
    /**
     Initializes an AccessToken with the provided tokenString
     
     - parameter tokenString: The access token string
     */
    @objc public init(tokenString: String) {
        self.tokenString = tokenString
        super.init()
    }
    
    /**
     Initializes an AccessToken with the provided parameters
     
     - parameter tokenString: The access token string
     - parameter refreshToken: String containing the refresh token.
     - parameter tokenType: String containing the token type.
     - parameter expirationDate: The expiration date for this access token
     - parameter grantedScopes: The scopes this token is valid for
     */
    @objc public init(tokenString: String,
                      refreshToken: String?,
                      tokenType: String?,
                      expirationDate: Date?,
                      grantedScopes: [UberScope]) {
        self.tokenString = tokenString
        self.refreshToken = refreshToken
        self.tokenType = tokenType
        self.expirationDate = expirationDate
        self.grantedScopes = grantedScopes
        super.init()
    }
    
    /**
     Initializes an AccessToken using a dictionary with key/values matching
     the OAuth access token response.
     
     See https://tools.ietf.org/html/rfc6749#section-5.1 for more details.
     The `token_type` parameter is not required for this initializer, however is supported.
     
     - parameter oauthDictionary: A dictionary with key/values matching
     the OAuth access token response.
     */
    @objc public init?(oauthDictionary: [String: Any]) {
        guard let tokenString = oauthDictionary["access_token"] as? String else { return nil }
        self.tokenString = tokenString
        self.refreshToken = oauthDictionary["refresh_token"] as? String
        self.tokenType = oauthDictionary["token_type"] as? String
        if let expiresIn = oauthDictionary["expires_in"] as? Double {
            self.expirationDate = Date(timeIntervalSinceNow: expiresIn)
        } else if let expiresIn = oauthDictionary["expires_in"] as? String,
            let expiresInDouble = Double(expiresIn) {
            self.expirationDate = Date(timeIntervalSinceNow: expiresInDouble)
        }
        self.grantedScopes = (oauthDictionary["scope"] as? String)?.toUberScopesArray() ?? []
    }
    
    // MARK: NSCoding methods.
    
    /**
     Note for reference. It would be better if these NSCoding methods allowed for serialization/deserialization for JSON.
     However, this is used for serializing to Keychain via NSKeyedArchiver, and would take work to maintain backwards compatibility
     if this was changed. Also, the OAuth `expires_in` parameter is a relative seconds string, which can't be stored by itself.
     */
    
    /**
     Initializer to build an accessToken from the provided NSCoder. Allows for 
     serialization of an AccessToken
     
     - parameter decoder: The NSCoder to decode the AcccessToken from
     
     - returns: An initialized AccessToken, or nil if something went wrong
     */
    @objc public required init?(coder decoder: NSCoder) {
        guard let token = decoder.decodeObject(forKey: "tokenString") as? String else {
            return nil
        }
        tokenString = token
        refreshToken = decoder.decodeObject(forKey: "refreshToken") as? String
        tokenType = decoder.decodeObject(forKey: "tokenType") as? String
        expirationDate = decoder.decodeObject(forKey: "expirationDate") as? Date
        if let scopesString = decoder.decodeObject(forKey: "grantedScopes") as? String {
            grantedScopes = scopesString.toUberScopesArray()
        }
        super.init()
    }
    
    /**
     Encodes the AccessToken. Required to allow for serialization
     
     - parameter coder: The NSCoder to encode the access token on
     */
    @objc public func encode(with coder: NSCoder) {
        coder.encode(self.tokenString, forKey: "tokenString")
        coder.encode(self.refreshToken, forKey:  "refreshToken")
        coder.encode(self.tokenType, forKey:  "tokenType")
        coder.encode(self.expirationDate, forKey: "expirationDate")
        coder.encode(self.grantedScopes.toUberScopeString(), forKey: "grantedScopes")
    }
}
