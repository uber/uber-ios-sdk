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
        
        let scopeString = try container.decodeIfPresent(String.self, forKey: .scope)
        let scope = (scopeString ?? "")
            .split(separator: " ")
            .map(String.init)
        
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
