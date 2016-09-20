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
    
    /// The scheme for the auth deeplink
    open var scheme: String
    
    /// The domain for the auth deeplink
    open var domain: String
    
    /// The path for the auth deeplink
    open var path: String?
    
    /// The array of query items the deeplink will include
    open var queryItems: [URLQueryItem]?
    
    open let deeplinkURL: URL
    
    fileprivate var waitingOnSystemPromptResponse = false
    fileprivate var checkingSystemPromptResponse = false
    fileprivate var promptTimer: Timer?
    fileprivate var completionWrapper: ((NSError?) -> ()) = { _ in }
    
    @objc public init?(scheme: String, domain: String, path: String?, queryItems: [URLQueryItem]?) {
        self.scheme = scheme
        self.domain = domain
        self.path = path
        self.queryItems = queryItems
        
        var requestURLComponents = URLComponents()
        requestURLComponents.scheme = scheme
        requestURLComponents.host = domain
        requestURLComponents.path = path ?? ""
        requestURLComponents.queryItems = queryItems
        guard let deeplinkURL = requestURLComponents.url else {
            return nil
        }
        self.deeplinkURL = deeplinkURL

        super.init()
    }
    
    /**
     Executes the base deeplink, accounting for the possiblity of an alert appearing
     on iOS 9+
     
     - parameter completion: The completion block to execute once the deeplink has
     executed. Passes in True if the url was successfully opened, false otherwise.
     */
    @objc open func execute(_ completion: ((NSError?) -> ())? = nil) {
        
        let usingIOS9 = ProcessInfo().isOperatingSystemAtLeast(OperatingSystemVersion(majorVersion: 9, minorVersion: 0, patchVersion: 0))
        
        if usingIOS9 {
            executeOnIOS9(completion)
        } else {
            executeOnBelowIOS9(completion)
        }
    }
    
    //Mark: Internal Interface
    
    func executeOnIOS9(_ completion: ((NSError?) -> ())?) {
        NotificationCenter.default.addObserver(self, selector: #selector(appWillResignActiveHandler), name: NSNotification.Name.UIApplicationWillResignActive, object: nil);
        NotificationCenter.default.addObserver(self, selector: #selector(appDidBecomeActiveHandler), name: NSNotification.Name.UIApplicationDidBecomeActive, object: nil);
        NotificationCenter.default.addObserver(self, selector: #selector(appDidEnterBackgroundHandler), name: NSNotification.Name.UIApplicationDidEnterBackground, object: nil)
        
        completionWrapper = { handled in
            NotificationCenter.default.removeObserver(self)
            self.promptTimer?.invalidate()
            self.promptTimer = nil
            self.checkingSystemPromptResponse = false
            self.waitingOnSystemPromptResponse = false
            completion?(handled)
        }
        
        var error: NSError?
        if UIApplication.shared.canOpenURL(deeplinkURL) {
            let openedURL = UIApplication.shared.openURL(deeplinkURL)
            if !openedURL {
                error = DeeplinkErrorFactory.errorForType(.unableToFollow)
            }
        } else {
            error = DeeplinkErrorFactory.errorForType(.unableToOpen)
        }
        
        if error != nil {
            completionWrapper(error)
        }
    }
    
    func executeOnBelowIOS9(_ completion: ((NSError?) -> ())?) {
        completionWrapper = { handled in
            completion?(handled)
        }
        
        var error: NSError?
        if UIApplication.shared.canOpenURL(deeplinkURL) {
            let openedURL = UIApplication.shared.openURL(deeplinkURL)
            if !openedURL {
                error = DeeplinkErrorFactory.errorForType(.unableToFollow)
            }
        } else {
            error = DeeplinkErrorFactory.errorForType(.unableToOpen)
        }
        
        completionWrapper(error)
    }
    
    //Mark: App Lifecycle Notifications
    
    @objc fileprivate func appWillResignActiveHandler(_ notification: Notification) {
        if !waitingOnSystemPromptResponse {
            waitingOnSystemPromptResponse = true
        } else if checkingSystemPromptResponse {
            completionWrapper(nil)
        }
    }
    
    @objc fileprivate func appDidBecomeActiveHandler(_ notification: Notification) {
        if waitingOnSystemPromptResponse {
            checkingSystemPromptResponse = true
            promptTimer = Timer.scheduledTimer(timeInterval: 0.25, target: self, selector: #selector(deeplinkHelper), userInfo: nil, repeats: false)
        }
    }
    
    @objc fileprivate func appDidEnterBackgroundHandler(_ notification: Notification) {
        completionWrapper(nil)
    }
    
    @objc fileprivate func deeplinkHelper() {
        let error = DeeplinkErrorFactory.errorForType(.deeplinkNotFollowed)
        completionWrapper(error)
    }
}

