//
//  UberAppDelegate.swift
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

/**
 Responsible for parsing any events that require switching to the Uber app.
 Designed to mimic methods from your application's AppDelegate and should
 be called inside their corresponding methods
 */
@objc(UBSDKAppDelegate) public class UberAppDelegate : NSObject {
    
    //MARK: Class variables
    
    @objc public static let shared = UberAppDelegate()
    
    //MARK: Public variables
    
    @objc public var loginManager : LoginManaging?
    
    //Mark: NSObject
    
    public override init() {
        super.init()
        
        NotificationCenter.default.addObserver(self, selector: #selector(didBecomeActive), name: UIApplication.didBecomeActiveNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(willEnterForeground), name: UIApplication.willEnterForegroundNotification, object: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    //MARK: Public Methods
    
    /**
     Handles parsing a deeplink that can be handled by the Rides SDK. Should be
     be called in your ApplicationDelegate:
     application:openURL:sourceApplication:annotation: (iOS 8)
     OR
     app:openURL:options: (iOS 9+), passing in options[UIApplicationOpenURLOptionsSourceApplicationKey] as sourceApplication

     - parameter application: Your singleton app object. As passed to the corresponding AppDelegate method
     - parameter url: The URL resource to open. As passed to the corresponding AppDelegate methods
     - parameter sourceApplication: The bundle ID of the app that is requesting
     your app to open the URL (url). As passed to the corresponding AppDelegate method (iOS 8) or
     options[UIApplicationOpenURLOptionsSourceApplicationKey] (iOS 9+)
     - parameter annotation: A property list object supplied by the source app to
     communicate information to the receiving app As passed to the corresponding AppDelegate method
     - returns: true if the URL was intended for the Rides SDK, false otherwise
     */
    @objc public func application(_ application: UIApplication, open url: URL, sourceApplication: String?, annotation: Any?) -> Bool {
        guard let manager = loginManager else {
            return false
        }
        let urlHandled = manager.application(application, open: url, sourceApplication: sourceApplication, annotation: annotation)
        if (urlHandled) {
            loginManager = nil
        }

        return urlHandled
    }
    
    @objc public func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        guard let options = launchOptions, let launchURL = options[UIApplication.LaunchOptionsKey.url] as? URL else {
            return false
        }
        
        let manager = loginManager ?? LoginManager()
        let sourceApplication = options[UIApplication.LaunchOptionsKey.sourceApplication] as? String
        let annotation = options[UIApplication.LaunchOptionsKey.annotation] as Any?
        let urlHandled = manager.application(application, open: launchURL, sourceApplication: sourceApplication, annotation: annotation)
        loginManager = nil
        return urlHandled
    }
    
    //MARK: Private Methods
    
    @objc private func willEnterForeground(_ notification: Notification) {
        if let manager = loginManager {
            manager.applicationWillEnterForeground()
        }
    }
    
    @objc private func didBecomeActive(_ notification: Notification) {
        if let manager = loginManager {
            manager.applicationDidBecomeActive()
        }
    }

}
