//
//  AuthenticationURLUtility.swift
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

class AuthenticationURLUtility {
    
    static let appNameKey = "third_party_app_name"
    static let callbackURIKey = "callback_uri_string"
    static let clientIDKey = "client_id"
    static let scopesKey = "scope"
    static let sdkKey = "sdk"
    static let sdkVersionKey = "sdk_version"
    
    static let sdkValue = "ios"
    
    static func buildQueryParameters(_ scopes: [UberScope]) -> [URLQueryItem] {
        var queryItems = [URLQueryItem]()
        
        queryItems.append(URLQueryItem(name: appNameKey, value: Configuration.shared.appDisplayName))
        queryItems.append(URLQueryItem(name: callbackURIKey, value: Configuration.shared.getCallbackURI(for: .native).absoluteString))
        queryItems.append(URLQueryItem(name: clientIDKey, value: Configuration.shared.clientID))
        queryItems.append(URLQueryItem(name: scopesKey, value: scopes.toUberScopeString()))
        queryItems.append(URLQueryItem(name: sdkKey, value: sdkValue))
        queryItems.append(URLQueryItem(name: sdkVersionKey, value: Configuration.shared.sdkVersion))
        
        return queryItems
    }
    
    static func shouldHandleRedirectURL(_ URL: Foundation.URL) -> Bool {
        guard let redirectURLComponents = URLComponents(url: URL, resolvingAgainstBaseURL: false),
        let expectedURLComponents = URLComponents(string: Configuration.shared.getCallbackURI(for: .general).absoluteString) else {
            return false
        }

        let isRedirectURL = (redirectURLComponents.scheme?.lowercased() == expectedURLComponents.scheme?.lowercased()) &&
            (redirectURLComponents.host?.lowercased() == expectedURLComponents.host?.lowercased())
        
        var isLoginError = false
        if let loginURLComponents = URLComponents(string: OAuth.regionHost) {
            
            isLoginError = (loginURLComponents.host == redirectURLComponents.host) && redirectURLComponents.path.contains("errors")
        }
        
        return isRedirectURL || isLoginError
    }
}
