//
//  RidesClient.swift
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


import Foundation

/// API client for the Uber Rides API.
@objc(UBSDKRidesClient) public class RidesClient: NSObject {
    
    /// Application client ID. Required for every instance of RidesClient.
    var clientID: String = Configuration.getClientID()
    
    /// The Access Token Identifier. The identifier to use for looking up this client's accessToken
    let accessTokenIdentifier: String
    
    /// The Keychain Access Group. The access group to use when looking up this client's accessToken
    let keychainAccessGroup: String
    
    /// NSURLSession used to make requests to Uber API. Default session configuration unless otherwise initialized.
    var session: NSURLSession
    
    /**
     Initializer for the RidesClient. The RidesClient handles making reqeusts to the API
     for you.
     
     - parameter accessTokenIdentifier: The accessTokenIdentifier to use. This identifier
     is used (along with keychainAccessGroup) to fetch the appropriate AccessToken. Defaults
     to the value set in your Configuration struct
     - parameter sessionConfiguration:  Configuration to use for NSURLSession. Defaults to defaultSessionConfiguration.
     - parameter keychainAccessGroup:   The keychain access group to use. Uses this group
     (along with the accessTokenIdentifier) to fetch the appropriate AccessToken. Defaults
     to the value set in yoru Configuration struct
     
     - returns: An initialized RidesClient

     */
    @objc public init(accessTokenIdentifier: String, sessionConfiguration: NSURLSessionConfiguration, keychainAccessGroup: String) {
            self.accessTokenIdentifier = accessTokenIdentifier
            self.keychainAccessGroup = keychainAccessGroup
            self.session = NSURLSession(configuration: sessionConfiguration)
    }
    
    /**
     Initializer for the RidesClient. The RidesClient handles making reqeusts to the API
     for you.
     By default, uses NSURLSessionConfiguration.defaultSessionConfiguration() for the URL requests
     
     - parameter accessTokenIdentifier: Initializer for the RidesClient. The RidesClient handles making reqeusts to the API
     for you.
     By default, it is initialized using the keychainAccessGroup default from your Configuration object
     Also uses NSURLSessionConfiguration.defaultSessionConfiguration() for the URL requests
     - parameter keychainAccessGroup:   The keychain access group to use. Uses this group
     (along with the accessTokenIdentifier) to fetch the appropriate AccessToken. Defaults
     to the value set in yoru Configuration struct
     
     - returns: An initialized RidesClient
     */
    @objc public convenience init(accessTokenIdentifier: String, keychainAccessGroup: String) {
        self.init(accessTokenIdentifier: accessTokenIdentifier,
            sessionConfiguration: NSURLSessionConfiguration.defaultSessionConfiguration(),
            keychainAccessGroup: keychainAccessGroup)
    }
    
    /**
     Initializer for the RidesClient. The RidesClient handles making reqeusts to the API
     for you.
     By default, it is initialized using the keychainAccessGroup default from your Configuration object
     
     - parameter accessTokenIdentifier: The accessTokenIdentifier to use. This identifier
     is used (along with keychainAccessGroup) to fetch the appropriate AccessToken
     - parameter sessionConfiguration:   Configuration to use for NSURLSession. Defaults to defaultSessionConfiguration.
     
     - returns: An initialized RidesClient
     */
    @objc public convenience init(accessTokenIdentifier: String, sessionConfiguration: NSURLSessionConfiguration) {
        self.init(accessTokenIdentifier: accessTokenIdentifier,
            sessionConfiguration: sessionConfiguration,
            keychainAccessGroup: Configuration.getDefaultKeychainAccessGroup())
    }
    
    /**
     Initializer for the RidesClient. The RidesClient handles making reqeusts to the API
     for you.
     By default, it is initialized using the keychainAccessGroup default from your Configuration object
     Also uses NSURLSessionConfiguration.defaultSessionConfiguration() for the URL requests
     
     - parameter accessTokenIdentifier: The accessTokenIdentifier to use. This identifier
     is used (along with keychainAccessGroup) to fetch the appropriate AccessToken
     
     - returns: An initialized RidesClient
     */
    @objc public convenience init(accessTokenIdentifier: String) {
        self.init(accessTokenIdentifier: accessTokenIdentifier,
            sessionConfiguration: NSURLSessionConfiguration.defaultSessionConfiguration(),
            keychainAccessGroup: Configuration.getDefaultKeychainAccessGroup())
    }
    
    /**
     Initializer for the RidesClient. The RidesClient handles making reqeusts to the API
     for you. 
     By default, it is initialized using the accessTokenIdentifier & keychainAccessGroup
     defaults from your Configuration object
     Also uses NSURLSessionConfiguration.defaultSessionConfiguration() for the URL requests
     
     - returns: An initialized RidesClient
     */
    @objc public convenience override init() {
        self.init(accessTokenIdentifier: Configuration.getDefaultAccessTokenIdentifier(),
            sessionConfiguration: NSURLSessionConfiguration.defaultSessionConfiguration(),
            keychainAccessGroup: Configuration.getDefaultKeychainAccessGroup())
    }
    
    
    
    /**
     Retrieves the token used by this rides client.
     
     Currently pulls from the keychain each time.
     
     - returns: an AccessToken object, or nil if one can't be located
     */
    @objc public func getAccessToken() -> AccessToken? {
        guard let accessToken = TokenManager.fetchToken(accessTokenIdentifier, accessGroup: keychainAccessGroup) else {
            return nil
        }
        return accessToken
    }
}
