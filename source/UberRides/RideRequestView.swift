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
import UberCore

/**
 Delegates are informed of events that occur in the RideRequestView such as errors.
 
 - Warning: The Ride Request Widget is deprecated, and will no longer work for new apps.
 Existing apps have until 05/31/2018 to migrate. See the Uber API Changelog for more details.
 */
@objc(UBSDKRideRequestViewDelegate) public protocol RideRequestViewDelegate {
    /**
     An error has occurred in the Ride Request Control.
     
     - parameter rideRequestView: the RideRequestView
     - parameter error:           the NSError that occured, with a code of RideRequestViewErrorType
     */
    func rideRequestView(_ rideRequestView: RideRequestView, didReceiveError error: NSError)
}

/**
 A view that shows the embedded Uber experience.
 - Warning: The Ride Request Widget is deprecated, and will no longer work for new apps.
 Existing apps have until 05/31/2018 to migrate. See the Uber API Changelog for more details.
*/
@objc(UBSDKRideRequestView) public class RideRequestView: UIView {
    /// The RideRequestViewDelegate of this view.
    @objc public var delegate: RideRequestViewDelegate?
    
    /// The access token used to authorize the web view
    @objc public var accessToken: AccessToken?
    
    /// Ther RideParameters to use for prefilling the RideRequestView
    @objc public var rideParameters: RideParameters
    
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
        configuration.processPool = Configuration.shared.processPool
        webView = WKWebView(frame: CGRect.zero, configuration: configuration)
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
        self.init(rideParameters: rideParameters, accessToken: TokenManager.fetchToken(), frame: CGRect.zero)
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
        self.init(rideParameters: RideParametersBuilder().build(), accessToken: TokenManager.fetchToken(), frame: CGRect.zero)
    }
    
    required public init?(coder aDecoder: NSCoder) {
        rideParameters = RideParametersBuilder().build()
        let configuration = WKWebViewConfiguration()
        configuration.processPool = Configuration.shared.processPool
        webView = WKWebView(frame: CGRect.zero, configuration: configuration)
        super.init(coder: aDecoder)
        initialSetup()
    }
    
    deinit {
        webView.scrollView.delegate = nil
        NotificationCenter.default.removeObserver(self)
    }
    
    // MARK: Public
    
    /**
     Load the Uber Ride Request Widget view.
     Requires that the access token has been retrieved.
     */
    @objc public func load() {
        guard !webView.isLoading else { return }
        guard let accessToken = accessToken else {
            self.delegate?.rideRequestView(self, didReceiveError: RideRequestViewErrorFactory.errorForType(.accessTokenMissing))
            return
        }
        
        let tokenString = accessToken.tokenString
        
        rideParameters.source = rideParameters.source ?? RideRequestView.sourceString
        
        let endpoint = Components.rideRequestWidget(rideParameters: rideParameters)
        guard let request = Request(session: nil, endpoint: endpoint, bearerToken: tokenString) else {
            delegate?.rideRequestView(self, didReceiveError: RideRequestViewErrorFactory.errorForType(.invalidRequest))
            return
        }
        request.prepare()
        var urlRequest = request.urlRequest
        urlRequest.cachePolicy = .returnCacheDataElseLoad
        webView.load(urlRequest)
    }
    
    /**
     Stop loading the Ride Request Widget View and clears the view.
     If the view has already loaded, calling this still clears the view.
    */
    @objc public func cancelLoad() {
        webView.stopLoading()
        if let url = URL(string: "about:blank") {
            webView.load(URLRequest(url: url))
        }
    }
    
    // MARK: Private
    
    private func initialSetup() {
        webView.navigationDelegate = self
        webView.scrollView.delegate = self
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillAppear(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardDidAppear(_:)), name: UIResponder.keyboardDidShowNotification, object: nil)
        
        setupWebView()
    }
    
    private func setupWebView() {
        addSubview(webView)
        webView.translatesAutoresizingMaskIntoConstraints = false
        webView.scrollView.bounces = false
        
        let views = ["webView": webView]
        let horizontalConstraints = NSLayoutConstraint.constraints(withVisualFormat: "H:|[webView]|", options: NSLayoutConstraint.FormatOptions(rawValue: 0), metrics: nil, views: views)
        let verticalConstraints = NSLayoutConstraint.constraints(withVisualFormat: "V:|[webView]|", options: NSLayoutConstraint.FormatOptions(rawValue: 0), metrics: nil, views: views)
        
        addConstraints(horizontalConstraints)
        addConstraints(verticalConstraints)
    }
    
    // MARK: Keyboard Notifications
    
    @objc func keyboardWillAppear(_ notification: Notification) {
        webView.scrollView.isScrollEnabled = false
    }
    
    @objc func keyboardDidAppear(_ notification: Notification) {
        webView.scrollView.isScrollEnabled = true
    }
}

// MARK: WKNavigationDelegate

extension RideRequestView: WKNavigationDelegate {
    public func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        if let url = navigationAction.request.url {
            if url.absoluteString.lowercased().hasPrefix(redirectURL.lowercased()) {
                let error = OAuthUtil.parseRideWidgetErrorFromURL(url)
                delegate?.rideRequestView(self, didReceiveError: error)
                decisionHandler(.cancel)
                return
            } else if url.scheme == "tel" || url.scheme == "sms" {
                if (!UIApplication.shared.openURL(url)) {
                    delegate?.rideRequestView(self, didReceiveError: RideRequestViewErrorFactory.errorForType(.notSupported))
                }
                decisionHandler(.cancel)
                return
            }
        }
        
        decisionHandler(.allow)
    }
    
    public func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        delegate?.rideRequestView(self, didReceiveError: RideRequestViewErrorFactory.errorForType(.networkError))
    }
    
    public func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
        guard (error as NSError).code != 102 else {
            return
        }
        delegate?.rideRequestView(self, didReceiveError: RideRequestViewErrorFactory.errorForType(.networkError))
    }
}

// MARK: UIScrollViewDelegate

extension RideRequestView : UIScrollViewDelegate {
    public func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if !scrollView.isScrollEnabled {
            scrollView.bounds = self.webView.bounds
        }
    }
}
