//
//  LoginManager.swift
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

import SafariServices

/// Manages user login via SSO, authorization code grant, or implicit grant.
@objc(UBSDKLoginManager) public class LoginManager: NSObject, LoginManaging {
    private(set) public var accessTokenIdentifier: String
    private(set) public var keychainAccessGroup: String
    private(set) public var loginType: LoginType
    private var oauthViewController: UIViewController?
    private var safariAuthenticationSession: Any? // Any? because otherwise this won't compile for earlier versions of iOS
    var authenticator: UberAuthenticating?
    var loggingIn: Bool = false
    var willEnterForegroundCalled: Bool = false
    private var postCompletionHandler: AuthenticationCompletionHandler?

    /**
    Create instance of login manager to authenticate user and retreive access token.
    
    - parameter accessTokenIdentifier: The access token identifier to use for saving the Access Token, defaults to Configuration.shared.defaultAccessTokenIdentifier
    - parameter keychainAccessGroup:   The keychain access group to use for saving the Access Token, defaults to Configuration.shared.defaultKeychainAccessGroup
    - parameter loginType:         The login type to use for logging in, defaults to Implicit
    
    - returns: An initialized LoginManager
    */
    @objc public init(accessTokenIdentifier: String, keychainAccessGroup: String?, loginType: LoginType) {

        self.accessTokenIdentifier = accessTokenIdentifier
        self.keychainAccessGroup = keychainAccessGroup ?? Configuration.shared.defaultKeychainAccessGroup
        self.loginType = loginType
        
        super.init()
    }

    /**
     Create instance of login manager to authenticate user and retreive access token.
     Uses the Implicit Login Behavior

     - parameter accessTokenIdentifier: The access token identifier to use for saving the Access Token, defaults to Configuration.getDefaultAccessTokenIdentifier()
     - parameter keychainAccessGroup:   The keychain access group to use for saving the Access Token, defaults to Configuration.getDefaultKeychainAccessGroup()

     - returns: An initialized LoginManager
     */
    @objc public convenience init(accessTokenIdentifier: String, keychainAccessGroup: String?) {
        self.init(accessTokenIdentifier: accessTokenIdentifier, keychainAccessGroup: keychainAccessGroup, loginType: LoginType.implicit)
    }

    /**
     Create instance of login manager to authenticate user and retreive access token.
     Uses the Implicit Login Behavior & your Configuration's keychain access group

     - parameter accessTokenIdentifier: The access token identifier to use for saving the Access Token, defaults to Configuration.getDefaultAccessTokenIdentifier()

     - returns: An initialized LoginManager
     */
    @objc public convenience init(accessTokenIdentifier: String) {
        self.init(accessTokenIdentifier: accessTokenIdentifier, keychainAccessGroup: nil)
    }

    /**
     Create instance of login manager to authenticate user and retreive access token.
     Uses the provided LoginType, with the accessTokenIdentifier & keychainAccessGroup defined
     in your Configuration

     - parameter loginType: The login behavior to use for logging in

     - returns: An initialized LoginManager
     */
    @objc public convenience init(loginType: LoginType) {
        self.init(accessTokenIdentifier: Configuration.shared.defaultAccessTokenIdentifier, keychainAccessGroup: nil, loginType: loginType)
    }

    /**
     Create instance of login manager to authenticate user and retreive access token.
     Uses the Native LoginType, with the accessTokenIdentifier & keychainAccessGroup defined
     in your Configuration

     - returns: An initialized LoginManager
     */
    @objc public convenience override init() {
        self.init(accessTokenIdentifier: Configuration.shared.defaultAccessTokenIdentifier, keychainAccessGroup: nil, loginType: LoginType.native)
    }

    // Mark: LoginManaging
    
     /**
     Launches view for user to log into Uber account and grant access to requested scopes.
     Access token (or error) is passed into completion handler.
     
     - parameter scopes:                   scopes being requested.
     - parameter presentingViewController: The presenting view controller present the login view controller over.
     - parameter completion:               The LoginManagerRequestTokenHandler completion handler for login success/failure.
     */
    @objc public func login(requestedScopes scopes: [UberScope], presentingViewController: UIViewController? = nil, completion: AuthenticationCompletionHandler? = nil) {
        self.postCompletionHandler = completion
        UberAppDelegate.shared.loginManager = self

        var authenticator: UberAuthenticating
        switch loginType {
        case .native:
            authenticator = NativeAuthenticator(scopes: scopes)
        case .implicit:
            authenticator = ImplicitGrantAuthenticator(scopes: scopes)
        case .authorizationCode:
            authenticator = AuthorizationCodeGrantAuthenticator(scopes: scopes)
        }

        self.authenticator = authenticator
        loggingIn = true
        willEnterForegroundCalled = false
        executeLogin(presentingViewController: presentingViewController, authenticator: authenticator)
    }
    
    /**
     Called via the RidesAppDelegate when the application is opened via a URL. Responsible
     for parsing the url and creating an OAuthToken.
     
     - parameter application:       The UIApplication object. Pass in the value from the App Delegate
     - parameter url:               The URL resource to open. As passed to the corresponding AppDelegate methods
     - parameter sourceApplication: The bundle ID of the app that is requesting your app to open the URL (url).
     As passed to the corresponding AppDelegate method (iOS 8)
     - parameter annotation:        annotation: A property list object supplied by the source app to communicate
     information to the receiving app As passed to the corresponding AppDelegate method (iOS 8)
     
     - returns: true if the url was meant to be handled by the SDK, false otherwise
     */
    public func application(_ application: UIApplication, open url: URL, sourceApplication: String?, annotation: Any?) -> Bool {
        guard let sourceApplication = sourceApplication else { return false }
        let sourceIsNative = loginType == .native && sourceApplication.hasPrefix("com.ubercab")
        let sourceIsSafariVC = loginType != .native && sourceApplication == "com.apple.SafariViewService"
        let sourceIsSafari = loginType != .native && sourceApplication == "com.apple.mobilesafari"
        let isValidSourceApplication = sourceIsNative || sourceIsSafariVC || sourceIsSafari

        if loggingIn && isValidSourceApplication {
            authenticator?.consumeResponse(url: url, completion: loginCompletion)
            return true
        } else {
            return false
        }
    }

    /**
     Called via the RidesAppDelegate when the application is opened via a URL. Responsible
     for parsing the url and creating an OAuthToken. (iOS 9+)

     - parameter application:       The UIApplication object. Pass in the value from the App Delegate
     - parameter url:               The URL resource to open. As passed to the corresponding AppDelegate methods
     - parameter options:           A dictionary of URL handling options. As passed to the corresponding AppDelegate method.

     - returns: true if the url was meant to be handled by the SDK, false otherwise
     */
    @available(iOS 9.0, *)
    public func application(_ app: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey : Any]) -> Bool {
        let sourceApplication = options[UIApplicationOpenURLOptionsKey.sourceApplication] as? String
        let annotation = options[.annotation] as Any?

        return application(app, open: url, sourceApplication: sourceApplication, annotation: annotation)
    }
    
    /**
     Called via the RidesAppDelegate when the application is about to enter the foreground. Used to distinguish
     calls to applicationDidBecomeActive() that represent a true context switch vs. those that represent system
     dialogs appearing over the app
     */
    public func applicationWillEnterForeground() {
        if loggingIn {
            willEnterForegroundCalled = true
        }
    }

    /**
     Called via the RidesAppDelegate when the application becomes active. Used to determine
     if a user abandons Native login without getting an access token.
     */
    public func applicationDidBecomeActive() {
        if willEnterForegroundCalled && loggingIn && loginType == .native {
            self.handleLoginCanceled()
            UberAppDelegate.shared.loginManager = nil;
        }
    }
    
    // Mark: Private Interface
    
    private func executeLogin(presentingViewController: UIViewController?, authenticator: UberAuthenticating) {
        if authenticator.authorizationURL.scheme == "https" {
            executeWebLogin(presentingViewController: presentingViewController, authenticator: authenticator)
        } else {
            executeDeeplinkLogin(presentingViewController: presentingViewController, authenticator: authenticator)
        }
    }

    // Delegates a web login to SFAuthenticationSession, SFSafariViewController, or just Safari
    private func executeWebLogin(presentingViewController: UIViewController?, authenticator: UberAuthenticating) {
        if #available(iOS 11.0, *) {
            executeSafariAuthLogin(authenticator: authenticator)
        } else if #available(iOS 9.0, *) {
            executeSafariVCLogin(presentingViewController: presentingViewController, authenticator: authenticator)
        } else {
            UIApplication.shared.openURL(authenticator.authorizationURL)
        }
    }

    /// Login using SFAuthenticationSession
    @available(iOS 11.0, *)
    private func executeSafariAuthLogin(authenticator: UberAuthenticating) {
        guard let bundleID = Bundle.main.bundleIdentifier else {
            preconditionFailure("You do not have a Bundle ID set for your app. You need a Bundle ID to use Uber Authentication")
        }

        let safariAuthenticationSession = SFAuthenticationSession(url: authenticator.authorizationURL, callbackURLScheme: bundleID, completionHandler: { (callbackURL, error) in
            if let callbackURL = callbackURL {
                authenticator.consumeResponse(url: callbackURL, completion: self.loginCompletion)
            } else {
                self.handleLoginCanceled()
            }
            self.safariAuthenticationSession = nil
        })
        safariAuthenticationSession.start()
        self.safariAuthenticationSession = safariAuthenticationSession
    }

    /// Login using SFSafariViewController
    @available(iOS 9.0, *)
    private func executeSafariVCLogin(presentingViewController: UIViewController?, authenticator: UberAuthenticating) {
        // Find the topmost view controller, and present from it
        var presentingViewController = presentingViewController
        if presentingViewController == nil {
            var topController = UIApplication.shared.keyWindow?.rootViewController
            while let vc = topController?.presentedViewController {
                topController = vc
            }
            presentingViewController = topController
        }

        let safariVC = SFSafariViewController(url: authenticator.authorizationURL)

        presentingViewController?.present(safariVC, animated: true, completion: nil)
        oauthViewController = safariVC
    }

    /// Login using native deeplink
    private func executeDeeplinkLogin(presentingViewController: UIViewController?, authenticator: UberAuthenticating) {
        DeeplinkManager.shared.open(authenticator.authorizationURL, completion: { error in
            guard let _ = error else { return }
            
            // If the user rejected the attempt to call the Uber app, don't use fallback.
            if self.loginType == .native && error?.code == DeeplinkErrorType.deeplinkNotFollowed.rawValue {
                self.loginCompletion(accessToken: nil, error: UberAuthenticationErrorFactory.errorForType(ridesAuthenticationErrorType: .unableToPresentLogin))
                return
            }
            
            // If we can't open the deeplink, fallback.
            // Privileged scopes require auth code flow.
            // Since that requires server support, fallback to app store if not available.
            if authenticator.scopes.contains(where: { $0.scopeType == .privileged }) {
                if (Configuration.shared.useFallback) {
                    self.loginType = .authorizationCode
                } else {
                    let appstoreDeeplink = AppStoreDeeplink(userAgent: nil)
                    appstoreDeeplink.execute(completion: { _ in
                        self.loginCompletion(accessToken: nil, error: UberAuthenticationErrorFactory.errorForType(ridesAuthenticationErrorType: .unableToPresentLogin))
                    })
                    return
                }
            } else { // Otherwise fallback to implicit flow
                self.loginType = .implicit
            }
            self.login(requestedScopes: authenticator.scopes, presentingViewController: presentingViewController, completion: self.postCompletionHandler)
        })
    }
    
    func handleLoginCanceled() {
        loggingIn = false
        willEnterForegroundCalled = false
        loginCompletion(accessToken: nil, error: UberAuthenticationErrorFactory.errorForType(ridesAuthenticationErrorType: .userCancelled))
        authenticator = nil
    }
    
    func loginCompletion(accessToken: AccessToken?, error: NSError?) {
        loggingIn = false
        willEnterForegroundCalled = false
        authenticator = nil
        oauthViewController?.dismiss(animated: true, completion: nil)

        var error = error
        if let accessToken = accessToken {
            let tokenIdentifier = accessTokenIdentifier
            let accessGroup = keychainAccessGroup
            let success = TokenManager.save(accessToken: accessToken, tokenIdentifier: tokenIdentifier, accessGroup: accessGroup)
            if !success {
                error = UberAuthenticationErrorFactory.errorForType(ridesAuthenticationErrorType: .unableToSaveAccessToken)
                print("Error: access token failed to save to keychain")
            }
        }

        postCompletionHandler?(accessToken, error)
    }
}
