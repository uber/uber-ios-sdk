//
//  LoginWebView.swift
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

/**
 *  LoginWebViewDelegate protocol. Alerts delegate to login outcome with either
 a valid access token or an error describing what went wrong
 */
@objc public protocol LoginViewDelegate {
    
     /**
     Called after an access token has been successfully retrieved.
     
     - parameter loginView:     The LoginView that completed log in
     - parameter accessToken:   The AccessToken received from login
     */
    @objc func loginView(loginView: LoginView, didSucceedWithToken accessToken: AccessToken)
    
     /**
     Called if the LoginView experienced an error when attempting to log in. The
     included authentication error provides more details
     
     - parameter loginView: The LoginView that experienced the error
     - parameter error:     An NSError describing what went wrong, code contains the RidesAuthenticationError that occured.
     */
    @objc func loginView(loginView: LoginView, didFailWithError error: NSError)
}

/// Login Web View class. Wrapper around a WKWebView to handle Login flow for Implicit Grant
@objc(UBSDKLoginView) public class LoginView : UIView {
    
    public var delegate : LoginViewDelegate?
    public var scopes: [RidesScope]?
    
    var callbackURIString = Configuration.getCallbackURIString()
    var clientID = Configuration.getClientID()
    let webView: WKWebView
    
    //MARK: Initializers
    
    /**
    Creates a LoginWebView for obtaining an access token
    
    - parameter scopes:            Array of RidesScope that you would like to request
    - parameter frame:             The frame to use for the view, defaults to CGRectZero
    
    - returns: An initialized LoginWebView
    */
    @objc public init(scopes: [RidesScope], frame: CGRect) {
        let configuration = WKWebViewConfiguration()
        configuration.processPool = Configuration.processPool
        webView = WKWebView.init(frame: frame, configuration: configuration)
        
        var filteredScopes = [RidesScope]()
        for scope in scopes {
            if scope.scopeType == .General {
                filteredScopes.append(scope)
            }
        }
        
        if filteredScopes.count < scopes.count {
            print("Warning: can not request access to privileged scopes via implicit grant.")
        }
        
        self.scopes = filteredScopes
        super.init(frame: frame)
        webView.navigationDelegate = self
        self.addSubview(webView)
        setupWebView()
    }
    
    /**
     Creates a LoginWebView for obtaining an access token.
     Defaults to a CGRectZero Frame
     
     - parameter scopes: Array of RidesScope that you would like to request
     
     - returns: An initialized LoginWebView
     */
    @objc public convenience init(scopes: [RidesScope]) {
        self.init(scopes: scopes, frame: CGRectZero)
    }

    /**
     Initializer for adding a LoginWebView via Storyboard. If using this constructor,
     you must add the scopes you want before attempting to call loadLoginPage()
     
     - parameter aDecoder: The coder to use
     
     - returns: An initialized loginWebView
     */
    required public init?(coder aDecoder: NSCoder) {
        webView = WKWebView()
        callbackURIString = Configuration.getCallbackURIString()
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
        let horizontalConstraints = NSLayoutConstraint.constraintsWithVisualFormat("H:|[webView]|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: views)
        let verticalConstraints = NSLayoutConstraint.constraintsWithVisualFormat("V:|[webView]|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: views)
        
        addConstraints(horizontalConstraints)
        addConstraints(verticalConstraints)
    }
    
    //MARK: Actions
    
    /**
    Loads the login page
    */
    public func load() {
        guard let scopes = scopes else {
            print("Must set request scopes")
            return
        }
        
        // Create URL for request
        let endpoint = OAuth.Login(clientID: clientID, scopes: scopes, redirect: callbackURIString)
        let request = Request(session: nil, endpoint: endpoint)
        request.prepare()
        
        guard let _ = request.requestURL() else {
            self.delegate?.loginView(self, didFailWithError: RidesAuthenticationErrorFactory.errorForType(ridesAuthenticationErrorType:.InvalidRequest))
            return
        }
        
        // Load request in web view
        self.webView.loadRequest(request.urlRequest)
    }
    
    /**
     Stops loading the login page and clears the view.
     If the login page has already loaded, calling this still clears the view.
     */
    public func cancelLoad() {
        webView.stopLoading()
        if let url = NSURL(string: "about:blank") {
            webView.loadRequest(NSURLRequest(URL: url))
        }
    }
}

extension LoginView : WKNavigationDelegate {
    
    public func webView(webView: WKWebView, decidePolicyForNavigationAction navigationAction: WKNavigationAction, decisionHandler: (WKNavigationActionPolicy) -> Void) {
        
        var shouldLoad = true

        if navigationAction.request.URL?.absoluteString.lowercaseString.hasPrefix(callbackURIString.lowercaseString) == true {
            do {
                let accessToken = try AccessTokenFactory.createAccessTokenFromRedirectURL(navigationAction.request.URL!)
                self.delegate?.loginView(self, didSucceedWithToken: accessToken)
            } catch let ridesError as NSError {
                self.delegate?.loginView(self, didFailWithError: ridesError)
            } catch {
                self.delegate?.loginView(self, didFailWithError: RidesAuthenticationErrorFactory.errorForType(ridesAuthenticationErrorType: .InvalidResponse))
            }
            shouldLoad = false
        }
        
        if shouldLoad {
            if navigationAction.request.URL?.absoluteString.containsString("errors") == true {
                let authError = OAuthUtil.parseAuthenticationErrorFromURL(navigationAction.request.URL!)
                
                self.delegate?.loginView(self, didFailWithError: authError)
                shouldLoad = false
            }
        }
        
        if (shouldLoad) {
            decisionHandler(WKNavigationActionPolicy.Allow)
        } else {
            decisionHandler(WKNavigationActionPolicy.Cancel)
        }
    }
    
    public func webView(webView: WKWebView, didFailNavigation navigation: WKNavigation!, withError error: NSError) {
        self.delegate?.loginView(self, didFailWithError: RidesAuthenticationErrorFactory.errorForType(ridesAuthenticationErrorType: .NetworkError))
    }
    
    public func webView(webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: NSError) {
        if error.code != 102 {
            self.delegate?.loginView(self, didFailWithError: RidesAuthenticationErrorFactory.errorForType(ridesAuthenticationErrorType: .NetworkError))
        }
    }
}

