//
//  NativeAuthenticator.swift
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

import Foundation

/**
 * UberAuthenticating object for authenticating a user via the Native Uber app
 */
@objc(UBSSONativeAuthenticator) open class NativeAuthenticator: BaseAuthenticator {
    
    /// The completion block to call when the deeplink is completed. Bool indicates if the deeplink was successful
    open var deeplinkCompletion: ((NSError?) -> ())?

    
    var deeplink: Deeplinking
    
    /**
     Creates a NativeAuthenticator using the provided scopes
     
     - parameter request: the URL request.
     
     - returns: true if a redirect was handled, false otherwise.
     */
    @objc public override init(scopes: [RidesScope]) {
        deeplink = AuthenticationDeeplink(scopes: scopes)
        super.init(scopes: scopes)
        callbackURIType = .native
    }
    
    override func login() {
        deeplink.execute { error in
            
            if let error = error , error.code == DeeplinkErrorType.unableToFollow.rawValue {
                self.loginCompletion?(nil, RidesAuthenticationErrorFactory.errorForType(ridesAuthenticationErrorType: .invalidRequest))
            } else if let _ = error {
                self.loginCompletion?(nil, RidesAuthenticationErrorFactory.errorForType(ridesAuthenticationErrorType: .unavailable))
            }
            self.deeplinkCompletion?(error)
        }
    }
}
