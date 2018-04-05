//
//  LoginManagingProtocol.swift
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

/**
 The type of behaviour that login manager should use for authentication.
 
 - AuthorizationCode: Authorization code grant.
 - Implicit: Implicit grant (only valid for general scope endpoints).
 - Native:   Native login (SSO via the Uber App)
 */
@objc(UBSDKLoginType) public enum LoginType: Int {
    case authorizationCode
    case implicit
    case native
}

@objc public protocol LoginManaging {
    /**
     Function for initializing a login attempt
     
     - parameter scopes:                   scopes being requested.
     - parameter presentingViewController: The presenting view controller present the login view controller over.
     - parameter completion:               The LoginManagerRequestTokenHandler completion handler for login success/failure.
     */
    @objc func login(requestedScopes scopes: [UberScope], presentingViewController: UIViewController?, completion: ((_ accessToken: AccessToken?, _ error: NSError?) -> Void)?)
    
    /**
     Called via the RidesAppDelegate when the application is opened via a URL. Responsible
     for parsing the url and creating an OAuthToken. (iOS 8 and below)
     
     - parameter application:       The UIApplication object. Pass in the value from the App Delegate
     - parameter url:               The URL resource to open. As passed to the corresponding AppDelegate methods
     - parameter sourceApplication: The bundle ID of the app that is requesting your app to open the URL (url).
     As passed to the corresponding AppDelegate method
     - parameter annotation:        annotation: A property list object supplied by the source app to communicate
     information to the receiving app As passed to the corresponding AppDelegate method
     
     - returns: true if the url was meant to be handled by the SDK, false otherwise
     */
    func application(_ application: UIApplication, open url: URL, sourceApplication: String?, annotation: Any?) -> Bool

    /**
     Called via the RidesAppDelegate when the application is opened via a URL. Responsible
     for parsing the url and creating an OAuthToken. (iOS 9+)

     - parameter application:       The UIApplication object. Pass in the value from the App Delegate
     - parameter url:               The URL resource to open. As passed to the corresponding AppDelegate methods
     - parameter options:           A dictionary of URL handling options. As passed to the corresponding AppDelegate method.

     - returns: true if the url was meant to be handled by the SDK, false otherwise
     */
    @available(iOS 9.0, *)
    func application(_ app: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey : Any]) -> Bool
    
    /**
     Called via the RidesAppDelegate when the application is about to enter the foreground. Used to determine
     if a user abandons Native login without getting an access token.
     */
    func applicationWillEnterForeground()
    
    /**
     Called via the RidesAppDelegate when the application becomes active. Used to determine
     if a user abandons Native login without getting an access token.
     */
    func applicationDidBecomeActive()
}
