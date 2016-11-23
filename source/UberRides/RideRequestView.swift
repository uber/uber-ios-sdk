//
//  RideRequestView.swift
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

import WebKit
import CoreLocation

/**
 *  Delegates are informed of events that occur in the RideRequestView such as errors.
 */
@objc(UBSDKRideRequestViewDelegate) public protocol RideRequestViewDelegate {
    /**
     An error has occurred in the Ride Request Control.
     
     - parameter rideRequestView: the RideRequestView
     - parameter error:           the NSError that occured, with a code of RideRequestViewErrorType
     */
    func rideRequestView(rideRequestView: RideRequestView, didReceiveError error: NSError)
}

/// A view that shows the embedded Uber experience. 
@objc(UBSDKRideRequestView) public class RideRequestView: UIView {
    /// The RideRequestViewDelegate of this view.
    public var delegate: RideRequestViewDelegate?
    
    /// The access token used to authorize the web view
    public var accessToken: AccessToken?
    
    /// Ther RideParameters to use for prefilling the RideRequestView
    public var rideParameters: RideParameters
    
    var webView: WKWebView
    let redirectURL = "uberconnect://oauth"
    
    static let sourceString = "ride_request_view"
    
     /**
     Initializes to show the embedded Uber ride request view.
     
     - parameter rideParameters: The RideParameters to use for presetting values; defaults to using the current location for pickup
     - parameter accessToken:    specific access token to use with web view; defaults to using TokenManager's default token
     - parameter frame:          frame of the view. Defaults to CGRectZero
     
     - returns: An initialized RideRequestView
     */
    @objc public required init(rideParameters: RideParameters, accessToken: AccessToken?, frame: CGRect) {
        self.rideParameters = rideParameters
        self.accessToken = accessToken
        let configuration = WKWebViewConfiguration()
        configuration.processPool = Configuration.processPool
        webView = WKWebView(frame: CGRectZero, configuration: configuration)
        super.init(frame: frame)
        initialSetup()
    }
    
    /**
     Initializes to show the embedded Uber ride request view.
     Uses the TokenManager's default accessToken
     
     - parameter rideParameters: The RideParameters to use for presetting values
     - parameter frame:          frame of the view
     
     - returns: An initialized RideRequestView
     */
    @objc public convenience init(rideParameters: RideParameters, frame: CGRect) {
        self.init(rideParameters: rideParameters, accessToken: TokenManager.fetchToken(), frame: frame)
    }

    /**
     Initializes to show the embedded Uber ride request view.
     Frame defaults to CGRectZero
     Uses the TokenManager's default accessToken
     
     - parameter rideParameters: The RideParameters to use for presetting values
     
     - returns: An initialized RideRequestView
     */
    @objc public convenience init(rideParameters: RideParameters) {
        self.init(rideParameters: rideParameters, accessToken: TokenManager.fetchToken(), frame: CGRectZero)
    }
    
    /**
     Initializes to show the embedded Uber ride request view.
     Uses the current location for pickup
     Uses the TokenManager's default accessToken
     
     - parameter frame:          frame of the view
     
     - returns: An initialized RideRequestView
     */
    @objc public convenience override init(frame: CGRect) {
        self.init(rideParameters: RideParametersBuilder().build(), accessToken: TokenManager.fetchToken(), frame: frame)
    }
    
    /**
     Initializes to show the embedded Uber ride request view.
     Uses the current location for pickup
     Uses the TokenManager's default accessToken
     Frame defaults to CGRectZero
     
     - returns: An initialized RideRequestView
     */
    @objc public convenience init() {
        self.init(rideParameters: RideParametersBuilder().build(), accessToken: TokenManager.fetchToken(), frame: CGRectZero)
    }
    
    required public init?(coder aDecoder: NSCoder) {
        rideParameters = RideParametersBuilder().build()
        let configuration = WKWebViewConfiguration()
        configuration.processPool = Configuration.processPool
        webView = WKWebView(frame: CGRectZero, configuration: configuration)
        super.init(coder: aDecoder)
        initialSetup()
    }
    
    deinit {
        webView.scrollView.delegate = nil
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    // MARK: Public
    
    /**
     Load the Uber Ride Request Widget view.
     Requires that the access token has been retrieved.
     */
    public func load() {
        guard let accessToken = accessToken else {
            self.delegate?.rideRequestView(self, didReceiveError: RideRequestViewErrorFactory.errorForType(.AccessTokenMissing))
            return
        }
        
        let tokenString = accessToken.tokenString
        
        if rideParameters.source == nil {
            rideParameters.source = RideRequestView.sourceString
        }
        
        let endpoint = Components.RideRequestWidget(rideParameters: rideParameters)
        let request = Request(session: nil, endpoint: endpoint, bearerToken: tokenString)
        request.prepare()
        let urlRequest = request.urlRequest
        urlRequest.cachePolicy = .ReturnCacheDataElseLoad
        webView.loadRequest(urlRequest)
    }
    
    /**
     Stop loading the Ride Request Widget View and clears the view.
     If the view has already loaded, calling this still clears the view.
    */
    public func cancelLoad() {
        webView.stopLoading()
        if let url = NSURL(string: "about:blank") {
            webView.loadRequest(NSURLRequest(URL: url))
        }
    }
    
    // MARK: Private
    
    private func initialSetup() {
        webView.navigationDelegate = self
        webView.scrollView.delegate = self
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(keyboardWillAppear(_:)), name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(keyboardDidAppear(_:)), name: UIKeyboardDidShowNotification, object: nil)
        
        setupWebView()
    }
    
    private func setupWebView() {
        addSubview(webView)
        webView.translatesAutoresizingMaskIntoConstraints = false
        webView.scrollView.bounces = false
        
        let views = ["webView": webView]
        let horizontalConstraints = NSLayoutConstraint.constraintsWithVisualFormat("H:|[webView]|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: views)
        let verticalConstraints = NSLayoutConstraint.constraintsWithVisualFormat("V:|[webView]|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: views)
        
        addConstraints(horizontalConstraints)
        addConstraints(verticalConstraints)
    }
    
    // MARK: Keyboard Notifications
    
    func keyboardWillAppear(notification: NSNotification) {
        webView.scrollView.scrollEnabled = false
    }
    
    func keyboardDidAppear(notification: NSNotification) {
        webView.scrollView.scrollEnabled = true
    }
}

// MARK: WKNavigationDelegate

extension RideRequestView: WKNavigationDelegate {
    public func webView(webView: WKWebView, decidePolicyForNavigationAction navigationAction: WKNavigationAction, decisionHandler: (WKNavigationActionPolicy) -> Void) {
        if let url = navigationAction.request.URL {
            if url.absoluteString?.lowercaseString.hasPrefix(redirectURL.lowercaseString) ?? false {
                let error = OAuthUtil.parseRideWidgetErrorFromURL(url)
                delegate?.rideRequestView(self, didReceiveError: error)
                decisionHandler(.Cancel)
                return
            } else if url.scheme == "tel" || url.scheme == "sms" {
                if (!UIApplication.sharedApplication().openURL(url)) {
                    delegate?.rideRequestView(self, didReceiveError: RideRequestViewErrorFactory.errorForType(.NotSupported))
                }
                decisionHandler(.Cancel)
                return
            }
        }
        
        decisionHandler(.Allow)
    }
    
    public func webView(webView: WKWebView, didFailNavigation navigation: WKNavigation!, withError error: NSError) {
        delegate?.rideRequestView(self, didReceiveError: RideRequestViewErrorFactory.errorForType(.NetworkError))
    }
    
    public func webView(webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: NSError) {
        guard error.code != 102 else {
            return
        }
        delegate?.rideRequestView(self, didReceiveError: RideRequestViewErrorFactory.errorForType(.NetworkError))
    }
}

// MARK: UIScrollViewDelegate

extension RideRequestView : UIScrollViewDelegate {
    public func scrollViewDidScroll(scrollView: UIScrollView) {
        if !scrollView.scrollEnabled {
            scrollView.bounds = self.webView.bounds
        }
    }
}
