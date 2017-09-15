//
//  LoginView.swift
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
import WebKit

/// Login Web View class. Wrapper around a WKWebView to handle Login flow for Implicit Grant
@objc(UBSDKLoginView) public class LoginView: UIView {
    
    @objc public var loginAuthenticator: LoginViewAuthenticator
    
    var clientID = Configuration.shared.clientID
    let webView: WKWebView
    
    //MARK: Initializers
    
    /**
    Creates a LoginWebView for obtaining an access token
    
    - parameter loginAuthenticator: the login authentication process to use
    - parameter frame:              The frame to use for the view, defaults to CGRectZero
    
    - returns: An initialized LoginWebView
    */
    @objc public init(loginAuthenticator: LoginViewAuthenticator, frame: CGRect = CGRect.zero) {
        let configuration = WKWebViewConfiguration()
        configuration.processPool = Configuration.shared.processPool
        webView = WKWebView.init(frame: frame, configuration: configuration)
        self.loginAuthenticator = loginAuthenticator
        super.init(frame: frame)
        webView.navigationDelegate = self
        self.addSubview(webView)
        setupWebView()
    }

    /**
     Initializer for adding a LoginWebView via Storyboard. If using this constructor,
     you must add the scopes you want before attempting to call loadLoginPage()
     
     - parameter aDecoder: The coder to use
     
     - returns: An initialized loginWebView
     */
    required public init?(coder aDecoder: NSCoder) {
        webView = WKWebView()
        self.loginAuthenticator = LoginViewAuthenticator(presentingViewController: UIViewController(), scopes: [])
        super.init(coder: aDecoder)
        webView.navigationDelegate = self
        self.addSubview(webView)
        setupWebView()
    }
    
    //MARK: View setup
    
    func setupWebView() {
        self.webView.scrollView.bounces = false
        self.webView.translatesAutoresizingMaskIntoConstraints = false

        let views = ["webView": webView]
        let horizontalConstraints = NSLayoutConstraint.constraints(withVisualFormat: "H:|[webView]|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: views)
        let verticalConstraints = NSLayoutConstraint.constraints(withVisualFormat: "V:|[webView]|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: views)
        
        addConstraints(horizontalConstraints)
        addConstraints(verticalConstraints)
    }
    
    //MARK: Actions
    
    /**
    Loads the login page
    */
    @objc public func load() {
        // Create URL for request
        guard let request = Request(session: nil, endpoint: loginAuthenticator.endpoint) else {
            loginAuthenticator.loginCompletion?(nil, RidesAuthenticationErrorFactory.errorForType(ridesAuthenticationErrorType:.invalidRequest))
            
            return
        }
        
        // Load request in web view
        self.webView.load(request.urlRequest)
    }
    
    /**
     Stops loading the login page and clears the view.
     If the login page has already loaded, calling this still clears the view.
     */
    @objc public func cancelLoad() {
        webView.stopLoading()
        if let url = URL(string: "about:blank") {
            webView.load(URLRequest(url: url))
        }
    }
}

extension LoginView : WKNavigationDelegate {
    
    public func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
            
        if loginAuthenticator.handleRedirect(for: navigationAction.request) {
            decisionHandler(WKNavigationActionPolicy.cancel)
        } else {
            decisionHandler(WKNavigationActionPolicy.allow)
        }
    }
    
    public func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        if (error as NSError).code != RidesWebViewErrors.frameLoadInterruptError.rawValue && (error as NSError).code != NSURLErrorCancelled {
            loginAuthenticator.loginCompletion?(nil, RidesAuthenticationErrorFactory.errorForType(ridesAuthenticationErrorType: .networkError))
        }
    }
    
    public func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
        if (error as NSError).code != RidesWebViewErrors.frameLoadInterruptError.rawValue && (error as NSError).code != NSURLErrorCancelled {
            loginAuthenticator.loginCompletion?(nil, RidesAuthenticationErrorFactory.errorForType(ridesAuthenticationErrorType: .networkError))
        }
    }
}

