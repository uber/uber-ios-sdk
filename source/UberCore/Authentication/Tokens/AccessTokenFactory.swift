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
@objc(UBSDKAccessTokenFactory) public class AccessTokenFactory: NSObject {
    /**
     Builds an AccessToken from the provided redirect URL
     
     - throws: UberAuthenticationError
     - parameter url: The URL to parse the token from
     - returns: An initialized AccessToken, or nil if one couldn't be created
     */
    public static func createAccessToken(fromRedirectURL redirectURL: URL) throws -> AccessToken {
        guard var components = URLComponents(url: redirectURL, resolvingAgainstBaseURL: false) else {
            throw UberAuthenticationErrorFactory.errorForType(ridesAuthenticationErrorType: .invalidResponse)
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
            throw UberAuthenticationErrorFactory.errorForType(ridesAuthenticationErrorType: .invalidRequest)
        }
        var queryDictionary = [String: Any]()
        for queryItem in queryItems {
            guard let value = queryItem.value else {
                continue
            }
            queryDictionary[queryItem.name] = value
        }
        
        return try createAccessToken(from: queryDictionary)
    }
    
    /**
     Builds an AccessToken from the provided JSON data
     
     - throws: UberAuthenticationError
     - parameter jsonData: The JSON Data to parse the token from
     - returns: An initialized AccessToken
     */
    public static func createAccessToken(fromJSONData jsonData: Data) throws -> AccessToken {
        guard let responseDictionary = (try? JSONSerialization.jsonObject(with: jsonData, options: [])) as? [String: Any] else {
            throw UberAuthenticationErrorFactory.errorForType(ridesAuthenticationErrorType: .invalidResponse)
        }
        return try createAccessToken(from: responseDictionary)
    }
    
    private static func createAccessToken(from oauthResponseDictionary: [String: Any]) throws -> AccessToken {
        if let error = oauthResponseDictionary["error"] as? String {
            guard let error = UberAuthenticationErrorFactory.createRidesAuthenticationError(rawValue: error) else {
                throw UberAuthenticationErrorFactory.errorForType(ridesAuthenticationErrorType: .invalidRequest)
            }
            throw error
        } else if let token = AccessToken(oauthDictionary: oauthResponseDictionary) {
            return token
        }
        throw UberAuthenticationErrorFactory.errorForType(ridesAuthenticationErrorType: .invalidResponse)
    }
}
