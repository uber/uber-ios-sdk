//
//  AppStoreDeeplink.swift
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
@objc(UBSDKAppStoreDeeplink) public class AppStoreDeeplink: BaseDeeplink {
    
    /**
     Initializes an App Store Deeplink to bring the user to the appstore
     
     - returns: An initialized AppStoreDeeplink
     */
    @objc public init(userAgent: String?) {
        let scheme = "https"
        let domain = "m.uber.com"
        let path = "/sign-up"
        
        let clientIDQueryItem = URLQueryItem(name: "client_id", value: Configuration.shared.clientID)
        
        let userAgent = userAgent ?? "rides-ios-v\(Configuration.shared.sdkVersion)"
        
        let userAgentQueryItem = URLQueryItem(name: "user-agent", value: userAgent)
        
        let queryItems = [clientIDQueryItem, userAgentQueryItem]
        
        super.init(scheme: scheme, host: domain, path: path, queryItems: queryItems)!
    }
}
