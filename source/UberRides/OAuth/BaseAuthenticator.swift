//
//  BaseAuthenticator.swift
//  UberRides
//
//  Copyright © 2016 Uber Technologies, Inc. All rights reserved.
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

import UIKit

/// Base class for authorization flows that use the LoginView.
@objc(UBSDKBaseAuthenticator) public class BaseAuthenticator: NSObject, UberAuthenticating {
    
    /// Optional identifier for saving the access token in keychain
    public var accessTokenIdentifier: String?
    
    /// Optional access group for saving the access token in keychain
    public var keychainAccessGroup: String?
    
    /// Completion block for when login has completed
    public var loginCompletion: ((accessToken: AccessToken?, error: NSError?) -> Void)?
    
    /// Scopes to request during login
    public var scopes: [RidesScope]
    
    /// The Callback URL Type to use for this authentication method
    public var callbackURIType: CallbackURIType = .General
    
    init(scopes: [RidesScope]) {
        self.scopes = scopes
        super.init()
    }
    
    func handleRedirectRequest(request: NSURLRequest) -> Bool {
        var didHandleRedirect = false
        if let url = request.URL where AuthenticationURLUtility.shouldHandleRedirectURL(url, type: callbackURIType) {
            do {
                let accessToken = try AccessTokenFactory.createAccessTokenFromRedirectURL(url)
                
                let tokenIdentifier = accessTokenIdentifier ?? Configuration.getDefaultAccessTokenIdentifier()
                let accessGroup = keychainAccessGroup ?? Configuration.getDefaultKeychainAccessGroup()
                var error: NSError?
                let success = TokenManager.saveToken(accessToken, tokenIdentifier: tokenIdentifier, accessGroup: accessGroup)
                if !success {
                    error = RidesAuthenticationErrorFactory.errorForType(ridesAuthenticationErrorType: .UnableToSaveAccessToken)
                    print("Error: access token failed to save to keychain")
                }
                loginCompletion?(accessToken: accessToken, error: error)
            } catch let ridesError as NSError {
                loginCompletion?(accessToken: nil, error: ridesError)
            } catch {
                loginCompletion?(accessToken: nil, error: RidesAuthenticationErrorFactory.errorForType(ridesAuthenticationErrorType: .InvalidResponse))
            }
            didHandleRedirect = true
        }
        
        return didHandleRedirect
    }
    
    func login() {
        fatalError("login() is abstract. Please subclass and provide an implementation.")
    }
}
