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

public struct AccessToken: Codable, Equatable {
    
    public let accessToken: String?
    
    public let refreshToken: String?
    
    public let tokenType: String?
    
    public let expiresIn: Int?
    
    public let scope: [String]?
    
    // MARK: Initializers
    
    public init(accessToken: String? = nil,
                refreshToken: String? = nil,
                tokenType: String? = nil,
                expiresIn: Int? = nil,
                scope: [String]? = nil) {
        self.accessToken = accessToken
        self.refreshToken = refreshToken
        self.tokenType = tokenType
        self.expiresIn = expiresIn
        self.scope = scope
    }
}

extension AccessToken: CustomStringConvertible {
    
    public var description: String {
        return """
        Access Token: \(accessToken ?? "nil")
        Refresh Token: \(refreshToken ?? "nil")
        Token Type: \(tokenType ?? "nil")
        Expires In: \(expiresIn ?? -1)
        Scopes: \(scope?.joined(separator: ", ") ?? "nil")
        """
    }
}
