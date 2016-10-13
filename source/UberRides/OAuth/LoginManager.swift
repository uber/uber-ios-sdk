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



/// Manages user login via SSO, authorization code grant, or implicit grant.
@objc(UBSDKLoginManager) public class LoginManager: NSObject, LoginManaging {
    
    /// Optional state to use for explcit grant authorization
    public var state: String?
    
    var accessTokenIdentifier: String
    var keychainAccessGroup: String
    var loginType: LoginType
    var oauthViewController: OAuthViewController?
    var authenticator: UberAuthenticating?
    var loggingIn: Bool = false
    
    /**
    Create instance of login manager to authenticate user and retreive access token.
    
    - parameter accessTokenIdentifier: The access token identifier to use for saving the Access Token, defaults to Configuration.getDefaultAccessTokenIdentifier()
    - parameter keychainAccessGroup:   The keychain access group to use for saving the Access Token, defaults to Configuration.getDefaultKeychainAccessGroup()
    - parameter loginType:         The login type to use for logging in, defaults to Implicit
    
    - returns: An initialized LoginManager
    */
    @objc public init(accessTokenIdentifier: String, keychainAccessGroup: String?, loginType: LoginType) {

        self.accessTokenIdentifier = accessTokenIdentifier
        self.keychainAccessGroup = keychainAccessGroup ?? Configuration.getDefaultKeychainAccessGroup()
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
        let accessGroup = keychainAccessGroup ?? Configuration.getDefaultKeychainAccessGroup()
        self.init(accessTokenIdentifier: accessTokenIdentifier, keychainAccessGroup: accessGroup, loginType: LoginType.Implicit)
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
        self.init(accessTokenIdentifier: Configuration.getDefaultAccessTokenIdentifier(), keychainAccessGroup: Configuration.getDefaultKeychainAccessGroup(), loginType: loginType)
    }
    
    /**
     Create instance of login manager to authenticate user and retreive access token.
     Uses the Native LoginType, with the accessTokenIdentifier & keychainAccessGroup defined
     in your Configuration
     
     - returns: An initialized LoginManager
     */
    @objc public convenience override init() {
        self.init(accessTokenIdentifier: Configuration.getDefaultAccessTokenIdentifier(), keychainAccessGroup: Configuration.getDefaultKeychainAccessGroup(), loginType: LoginType.Native)
    }
    
    // Mark: LoginManaging
    
     /**
     Launches view for user to log into Uber account and grant access to requested scopes.
     Access token (or error) is passed into completion handler.
     
     - parameter scopes:                   scopes being requested.
     - parameter presentingViewController: The presenting view controller present the login view controller over.
     - parameter completion:               The LoginManagerRequestTokenHandler completion handler for login success/failure.
     */
    @objc public func login(requestedScopes scopes: [RidesScope], presentingViewController: UIViewController? = nil, completion: ((accessToken: AccessToken?, error: NSError?) -> Void)? = nil) {
        guard !loggingIn else {
            completion?(accessToken: nil, error: RidesAuthenticationErrorFactory.errorForType(ridesAuthenticationErrorType: .Unavailable))
            return
        }
        
        var loginAuthenticator: UberAuthenticating!
        
        switch loginType {
        case .AuthorizationCode:
            guard let presentingViewController = presentingViewController else {
                completion?(accessToken: nil, error: RidesAuthenticationErrorFactory.errorForType(ridesAuthenticationErrorType: .UnableToPresentLogin))
                return
            }
            loginAuthenticator = AuthorizationCodeGrantAuthenticator(presentingViewController: presentingViewController, scopes: scopes, state: state)
        case .Implicit:
            guard let presentingViewController = presentingViewController else {
                completion?(accessToken: nil, error: RidesAuthenticationErrorFactory.errorForType(ridesAuthenticationErrorType: .UnableToPresentLogin))
                return
            }
            loginAuthenticator = ImplicitGrantAuthenticator(presentingViewController: presentingViewController, scopes: scopes)
        case .Native:
            let nativeAuthenticator = NativeAuthenticator(scopes: scopes)
            nativeAuthenticator.deeplinkCompletion = { error in
                if (error == nil) {
                    RidesAppDelegate.sharedInstance.loginManager = self
                }
            };
            loginAuthenticator = nativeAuthenticator
        }
        
        loginAuthenticator.keychainAccessGroup = keychainAccessGroup
        loginAuthenticator.accessTokenIdentifier = accessTokenIdentifier
        loginAuthenticator.loginCompletion = loginCompletion(loginType, presentingViewController: presentingViewController, completion: completion)
        
        loggingIn = true
        authenticator = loginAuthenticator
        executeLogin()
    }
    
    /**
     Called via the RidesAppDelegate when the application is opened via a URL. Responsible
     for parsing the url and creating an OAuthToken.
     
     - parameter application:       The UIApplication object. Pass in the value from the App Delegate
     - parameter url:               The URL resource to open. As passed to the corresponding AppDelegate methods
     - parameter sourceApplication: The bundle ID of the app that is requesting your app to open the URL (url).
     As passed to the corresponding AppDelegate method (iOS 8)
     OR
     options[UIApplicationOpenURLOptionsSourceApplicationKey] (iOS 9+)
     - parameter annotation:        annotation: A property list object supplied by the source app to communicate
     information to the receiving app As passed to the corresponding AppDelegate method (iOS 8)
     OR
     options[UIApplicationLaunchOptionsAnnotationKey] (iOS 9+)
     
     
     - returns: true if the url was meant to be handled by the SDK, false otherwise
     */
    public func application(application: UIApplication, openURL url: NSURL, sourceApplication: String?, annotation: AnyObject?) -> Bool {
        guard let source = sourceApplication where source.hasPrefix("com.ubercab"),
        let nativeAuthenticator = authenticator as? NativeAuthenticator else {
            return false
        }
        let redirectURL = NSURLRequest(URL: url)
        let handled = nativeAuthenticator.handleRedirectRequest(redirectURL)
        loggingIn = false
        authenticator = nil
        return handled
    }
    
    /**
     Called via the RidesAppDelegate when the application becomes active. Used to determine
     if a user abandons Native login without getting an access token.
     
     - parameter application: The UIApplication object. Pass in the value from the App Delegate
     */
    public func applicationDidBecomeActive() {
        if loggingIn {
            self.handleLoginCanceled()
        }
    }
    
    // Mark: Internal Interface
    
    func executeLogin() {
        authenticator?.login()
    }
    
    // Mark: Private Interface
    
    private func handleLoginCanceled() {
        loggingIn = false
        authenticator?.loginCompletion?(accessToken: nil, error: RidesAuthenticationErrorFactory.errorForType(ridesAuthenticationErrorType: .UserCancelled))
        authenticator = nil
    }
    
    private func loginCompletion(loginType: LoginType, presentingViewController: UIViewController?, completion: ((accessToken: AccessToken?, error: NSError?) -> Void)?) -> ((accessToken: AccessToken?, error: NSError?) -> Void)? {
        var loginCompletion: ((accessToken: AccessToken?, error: NSError?) -> Void)?
        
        switch loginType {
        case .Native:
            loginCompletion = { token, error in
                self.loggingIn = false
                if let error = error where error.code == RidesAuthenticationErrorType.Unavailable.rawValue {
                    self.handleNativeFallback(error, presentingViewController: presentingViewController, completion: completion)
                } else {
                    completion?(accessToken: token, error: error)
                }
            }
            break
        case .Implicit:
            fallthrough
        case .AuthorizationCode:
            fallthrough
        default:
            loginCompletion = { token, error in
                self.loggingIn = false
                if let presentingViewController = presentingViewController {
                    presentingViewController.dismissViewControllerAnimated(true, completion: { () -> Void in
                        completion?(accessToken: token, error: error)
                    })
                } else {
                    completion?(accessToken: token, error: error)
                }
            }
            break
        }
        
        return loginCompletion
    }
    
    private func handleNativeFallback(error: NSError?, presentingViewController: UIViewController?, completion: ((accessToken: AccessToken?, error: NSError?) -> Void)?) {
        guard let manager = authenticator as? NativeAuthenticator else {
            completion?(accessToken: nil, error: error)
            return
        }
        
        if manager.scopes.contains({ $0.scopeType == .Privileged }) {
            if (Configuration.getFallbackEnabled()) {
                loginType = .AuthorizationCode
            } else {
                let appstoreDeeplink = AppStoreDeeplink(userAgent: nil)
                appstoreDeeplink.execute({ _ in
                    completion?(accessToken: nil, error: error)
                })
                return
            }
        } else {
            loginType = .Implicit
        }
        login(requestedScopes: manager.scopes, presentingViewController: presentingViewController, completion: completion)
    }
}
