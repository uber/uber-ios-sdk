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
    static let loginTypeKey = "login_type"
    static let scopesKey = "scope"
    static let sdkKey = "sdk"
    static let sdkVersionKey = "sdk_version"
    
    static let sdkValue = "ios"
    
    static func buildQueryParameters(scopes: [RidesScope]) -> [NSURLQueryItem] {
        var queryItems = [NSURLQueryItem]()
        
        queryItems.append(NSURLQueryItem(name: appNameKey, value: Configuration.getAppDisplayName()))
        queryItems.append(NSURLQueryItem(name: callbackURIKey, value: Configuration.getCallbackURIString(.Native)))
        queryItems.append(NSURLQueryItem(name: clientIDKey, value: Configuration.getClientID()))
        queryItems.append(NSURLQueryItem(name: loginTypeKey, value: Configuration.regionString))
        queryItems.append(NSURLQueryItem(name: scopesKey, value: scopes.toRidesScopeString()))
        queryItems.append(NSURLQueryItem(name: sdkKey, value: sdkValue))
        queryItems.append(NSURLQueryItem(name: sdkVersionKey, value: Configuration.sdkVersion))
        
        return queryItems
    }
    
    static func shouldHandleRedirectURL(URL: NSURL, type: CallbackURIType) -> Bool {
        guard let redirectURLComponents = NSURLComponents(URL: URL, resolvingAgainstBaseURL: false),
        expectedURLComponents = NSURLComponents(string: Configuration.getCallbackURIString(type)) else {
            return false
        }

        let isRedirectURL = (redirectURLComponents.scheme?.lowercaseString == expectedURLComponents.scheme?.lowercaseString) &&
            (redirectURLComponents.host?.lowercaseString == expectedURLComponents.host?.lowercaseString)
        
        var isLoginError = false
        if let loginURLComponents = NSURLComponents(string: OAuth.regionHostString()),
            path = redirectURLComponents.path {
            
            isLoginError = (loginURLComponents.host == redirectURLComponents.host) && path.containsString("errors")
        }
        
        return isRedirectURL || isLoginError
    }
}
