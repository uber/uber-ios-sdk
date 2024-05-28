//
//  AccessToken.swift
//  UberAuth
//
//  Copyright © 2024 Uber Technologies, Inc. All rights reserved.
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

///
/// The Access Token response for the authorization code grant flow as
/// defined by the OAuth 2.0 standard.
/// https://datatracker.ietf.org/doc/html/rfc6749#section-5.1
///
public struct AccessToken: Codable, Equatable {
    
    public let tokenString: String?
    
    public let refreshToken: String?
    
    public let tokenType: String?
    
    public let expiresIn: Int?
    
    public let scope: [String]?
    
    // MARK: Initializers
    
    public init(tokenString: String? = nil,
                refreshToken: String? = nil,
                tokenType: String? = nil,
                expiresIn: Int? = nil,
                scope: [String]? = nil) {
        self.tokenString = tokenString
        self.refreshToken = refreshToken
        self.tokenType = tokenType
        self.expiresIn = expiresIn
        self.scope = scope
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let tokenString = try container.decode(String.self, forKey: .tokenString)
        let tokenType = try container.decode(String.self, forKey: .tokenType)
        let expiresIn = try container.decodeIfPresent(Int.self, forKey: .expiresIn)
        let refreshToken = try container.decodeIfPresent(String.self, forKey: .refreshToken)
        
        let scope: [String]?
        if let scopeString = try? container.decodeIfPresent(String.self, forKey: .scope) {
            scope = (scopeString ?? "")
                .split(separator: " ")
                .map(String.init)
        }
        else {
            scope = try? container.decodeIfPresent([String].self, forKey: .scope)
        }
        
        self = AccessToken(
            tokenString: tokenString,
            refreshToken: refreshToken,
            tokenType: tokenType,
            expiresIn: expiresIn,
            scope: scope
        )
    }
    
    enum CodingKeys: String, CodingKey {
        case tokenString = "access_token"
        case tokenType = "token_type"
        case expiresIn = "expires_in"
        case refreshToken = "refresh_token"
        case scope
    }
}

///
/// Initializers to build access tokens from various responses
///
extension AccessToken {
    
    public init(jsonData: Data) throws {
        guard let responseDictionary = (try? JSONSerialization.jsonObject(with: jsonData, options: [])) as? [String: Any] else {
            throw UberAuthenticationErrorFactory.errorForType(ridesAuthenticationErrorType: .invalidResponse)
        }
        self = try AccessToken(oAuthDictionary: responseDictionary)
    }
    
    /// Builds an AccessToken from the provided JSON data
    ///
    /// - Throws: UberAuthenticationError
    /// - Parameter jsonData: The JSON Data to parse the token from
    /// - Returns: An initialized AccessToken
    public init(oAuthDictionary: [String: Any]) throws {
        guard let tokenString = oAuthDictionary["access_token"] as? String else {
            throw UberAuthenticationErrorFactory.errorForType(ridesAuthenticationErrorType: .invalidResponse)
        }
        self.tokenString = tokenString
        self.refreshToken = oAuthDictionary["refresh_token"] as? String
        self.tokenType = oAuthDictionary["token_type"] as? String
        self.expiresIn = {
            if let expiresIn = oAuthDictionary["expires_in"] as? Int { return expiresIn }
            if let expiresIn = oAuthDictionary["expires_in"] as? String,
               let expiresInInt = Int(expiresIn) {
                return expiresInInt
            }
            return 0
        }()
        self.scope = ((oAuthDictionary["scope"] as? String) ?? "")
            .components(separatedBy: " ")
            .flatMap { $0.components(separatedBy: "+") }
    }
    
    /// Builds an AccessToken from the provided redirect URL
    ///
    /// - Throws: UberAuthenticationError
    /// - Parameter url: The URL to parse the token from
    /// - Returns: An initialized AccessToken, or nil if one couldn't be created
    public init(redirectURL: URL) throws {
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
        
        self = try AccessToken(oAuthDictionary: queryDictionary)
    }
}


extension AccessToken: CustomStringConvertible {
    
    public var description: String {
        return """
        Token String: \(tokenString ?? "nil")
        Refresh Token: \(refreshToken ?? "nil")
        Token Type: \(tokenType ?? "nil")
        Expires In: \(expiresIn ?? -1)
        Scopes: \(scope?.joined(separator: ", ") ?? "nil")
        """
    }
}
