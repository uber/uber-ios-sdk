//
//  AuthorizationCodeResponseParser.swift
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

/// @mockable
protocol AuthorizationCodeResponseParsing {
    func isValidResponse(url: URL, matching redirectURI: String) -> Bool
    func callAsFunction(url: URL) -> Result<Client, UberAuthError>
}

///
/// A struct that validates and extracts values from a url containing an authorization code response
///
struct AuthorizationCodeResponseParser: AuthorizationCodeResponseParsing {
    
    init() {}
    
    /// Determines whether the provided url corresponds to an authorization code response
    /// by verifying that the url matches the expected redirect URI
    ///
    /// - Parameters:
    ///   - url: The url to parse
    ///   - redirectURI: The expected redirect url
    /// - Returns: A boolean indicating whether or not the URLs match
    func isValidResponse(url: URL, matching redirectURI: String) -> Bool {
        guard let components = URLComponents(url: url, resolvingAgainstBaseURL: false),
              let expectedComponents = URLComponents(string: redirectURI) else {
            return false
        }

        // Verify incoming scheme matches redirect_uri scheme
        guard let scheme = components.scheme?.lowercased(),
              let expectedScheme = expectedComponents.scheme?.lowercased(),
              scheme == expectedScheme else {
            return false
        }
        
        // Verify incoming host matches redirect_uri host
        guard let scheme = components.host?.lowercased(),
              let expectedScheme = expectedComponents.host?.lowercased(),
              scheme == expectedScheme else {
            return false
        }
                
        return true
    }
    
    /// Parses the provided url and attempts to pull an authorization code  or an error
    /// from the query parameters
    ///
    /// - Parameter url: The url to parse
    /// - Returns: A Result containing a client object built from the parsed values
    func callAsFunction(url: URL) -> Result<Client, UberAuthError> {
        guard let components = URLComponents(url: url, resolvingAgainstBaseURL: false) else {
            return .failure(.invalidResponse)
        }
        
        if let authorizationCode = components.queryItems?.first(where: {
            $0.name == "code"
        })?.value {
            return .success(
                Client(authorizationCode: authorizationCode)
            )
        }
        
        let error: UberAuthError
        if let errorString = components.queryItems?.first(where: { $0.name == "error" })?.value,
           let oAuthError = OAuthError(rawValue: errorString) {
            error = .oAuth(oAuthError)
        } else {
            error = .invalidAuthCode
        }
        
        return .failure(error)
    }
}

