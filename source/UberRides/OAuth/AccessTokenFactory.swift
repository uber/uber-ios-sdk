//
//  AccessTokenFactory.swift
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


/**
Factory class to build access tokens
*/
@objc(UBSDKAccessTokenFactory) open class AccessTokenFactory: NSObject {
    
    @objc open static func createAccessTokenFromJSONString(_ string: String) -> AccessToken? {
        return ModelMapper<AccessToken>().mapFromJSON(string as NSString)
    }
    
    /**
     Builds an AccessToken from the provided redirect URL
     
     - throws: RidesAuthenticationError
     - parameter url: The URL to parse the token from
     - returns: An initialized AccessToken, or nil if one couldn't be created
     */
    static func createAccessTokenFromRedirectURL(_ url : URL) throws -> AccessToken {
        guard var components = URLComponents(url: url, resolvingAgainstBaseURL: false) else {
            throw RidesAuthenticationErrorFactory.errorForType(ridesAuthenticationErrorType: .invalidResponse)
        }

        var finalQueryArray = [String]()
        if let existingQuery = components.query {
            finalQueryArray.append(existingQuery)
        }
        if let existingFragment = components.fragment {
            finalQueryArray.append(existingFragment)
        }
        components.fragment = nil
        components.query = finalQueryArray.joined(separator: "&")
        
        guard let queryItems = components.queryItems else {
            throw RidesAuthenticationErrorFactory.errorForType(ridesAuthenticationErrorType: .invalidRequest)
        }
        var queryDictionary = [String : String]()
        for queryItem in queryItems {
            guard let value = queryItem.value else {
                continue
            }
            queryDictionary[queryItem.name] = value
        }
        if let error = queryDictionary["error"] {
            guard let error = RidesAuthenticationErrorFactory.createRidesAuthenticationError(rawValue: error) else {
                throw RidesAuthenticationErrorFactory.errorForType(ridesAuthenticationErrorType: .invalidRequest)
            }
            throw error
        } else {
            if let expiresInString = queryDictionary["expires_in"] as String? {
                let expiresInSeconds =  TimeInterval(atof(expiresInString))
                let expirationDateSeconds = Date().timeIntervalSince1970 + expiresInSeconds
                queryDictionary["expiration_date"] = "\(expirationDateSeconds)"
                queryDictionary.removeValue(forKey: "expires_in")
            }
            if let token = AccessToken(JSON: queryDictionary) {
                return token
            }
        }
        throw RidesAuthenticationErrorFactory.errorForType(ridesAuthenticationErrorType: .invalidResponse)
    }
}
