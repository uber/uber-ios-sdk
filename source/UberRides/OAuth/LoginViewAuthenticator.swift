//
//  LoginViewAuthenticator.swift
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
@objc open class LoginViewAuthenticator: BaseAuthenticator {
    
    /// View controller that will present the login
    open var presentingViewController: UIViewController
    
    /// Endpoint to hit for authorization request.
    var endpoint: UberAPI {
        fatalError("Must initialize subclass")
    }
    
    @objc public init(presentingViewController: UIViewController, scopes: [RidesScope]) {
        self.presentingViewController = presentingViewController
        
        super.init(scopes: scopes)
    }
    
    override func login() {
        let oauthViewController = OAuthViewController(loginAuthenticator: self)
        let navController = UINavigationController(rootViewController: oauthViewController)
        presentingViewController.present(navController, animated: true, completion: nil)
    }
}
