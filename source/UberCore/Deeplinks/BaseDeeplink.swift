//
//  BaseDeeplink.swift
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
 *  A Deeplinking object for authenticating a user via the native Uber app
 */
@objc(UBSDKBaseDeeplink) open class BaseDeeplink: NSObject, Deeplinking {
    @objc public var url: URL

    @objc open var fallbackURLs: [URL] {
        var urls: [URL] = []
        if url.scheme == "uber",
            var urlComponents = URLComponents(url: url, resolvingAgainstBaseURL: false) {
            urlComponents.scheme = "uber-enterprise"
            if let betaURL = urlComponents.url {
                urls.append(betaURL)
            }

            urlComponents.scheme = "uber-nightly"
            if let nightlyURL = urlComponents.url {
                urls.append(nightlyURL)
            }
        } else if url.scheme == "ubereats",
            var urlComponents = URLComponents(url: url, resolvingAgainstBaseURL: false) {
            urlComponents.scheme = "ubereats-enterprise"
            if let betaURL = urlComponents.url {
                urls.append(betaURL)
            }

            urlComponents.scheme = "ubereats-nightly"
            if let nightlyURL = urlComponents.url {
                urls.append(nightlyURL)
            }
        }
        return urls
    }

    @objc public init?(scheme: String, host: String, path: String, queryItems: [URLQueryItem]?) {
        var components = URLComponents()
        components.scheme = scheme
        components.host = host
        components.path = path
        components.queryItems = queryItems

        if let url = components.url {
            self.url = url
        } else {
            return nil
        }
    }
    
    /**
     Executes the base deeplink, accounting for the possiblity of an alert appearing
     on iOS 9+
     
     - parameter completion: The completion block to execute once the deeplink has
     executed. Passes in True if the url was successfully opened, false otherwise.
     */
    @objc public func execute(completion: DeeplinkCompletionHandler? = nil) {
        DeeplinkManager.shared.open(self, completion: completion)
    }
}

/// Fallback types for Deeplinks
@objc(UBSDKDeeplinkFallbackType) public enum DeeplinkFallbackType: Int {
    /// Mobile web fallback (m.uber.com)
    case mobileWeb
    /// App Store download fallback
    case appStore
    /// No fallback
    case none
}
