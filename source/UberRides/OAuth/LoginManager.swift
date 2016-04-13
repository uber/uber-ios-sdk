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

/**
The type of behaviour that login manager should use for authentication.

- Implicit: Implicit grant (only valid for general scope endpoints).
*/
@objc public enum LoginBehavior : Int {
    case Implicit
}

/// Manages user login via implicit grant.
@objc(UBSDKLoginManager) public class LoginManager: NSObject {
    
    /// Completion handler for when login has succeeded or retrieved an error.
    var loginCompletion: ((accessToken: AccessToken?, error: NSError?) -> Void)?
    
    var accessTokenIdentifier: String
    var keychainAccessGroup: String
    var loginBehavior: LoginBehavior
    var oauthViewController: OAuthViewController?
    
    private var currentScopes: [RidesScope]?
    private var currentPresentingViewController: UIViewController?
    
    
    /**
    Create instance of login manager to authenticate user and retreive access token.
    
    - parameter accessTokenIdentifier: The access token identifier to use for saving the Access Token, defaults to Configuration.getDefaultAccessTokenIdentifier()
    - parameter keychainAccessGroup:   The keychain access group to use for saving the Access Token, defaults to Configuration.getDefaultKeychainAccessGroup()
    - parameter loginBehavior:         The login behavior to use for logging in, defaults to Implicit
    
    - returns: An initialized LoginManager
    */
    @objc public init(accessTokenIdentifier: String, keychainAccessGroup: String?, loginBehavior: LoginBehavior) {

        self.accessTokenIdentifier = accessTokenIdentifier
        self.keychainAccessGroup = keychainAccessGroup ?? Configuration.getDefaultKeychainAccessGroup()
        self.loginBehavior = loginBehavior
        self.loginCompletion = nil
        
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
        self.init(accessTokenIdentifier: accessTokenIdentifier, keychainAccessGroup: accessGroup, loginBehavior: LoginBehavior.Implicit)
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
     Uses the provided LoginBehavior, with the accessTokenIdentifier & keychainAccessGroup defined
     in your Configuration
     
     - parameter loginBehavior: The login behavior to use for logging in
     
     - returns: An initialized LoginManager
     */
    @objc public convenience init(loginBehavior: LoginBehavior) {
        self.init(accessTokenIdentifier: Configuration.getDefaultAccessTokenIdentifier(), keychainAccessGroup: Configuration.getDefaultAccessTokenIdentifier(), loginBehavior: loginBehavior)
    }
    
    /**
     Create instance of login manager to authenticate user and retreive access token.
     Uses the Implicit LoginBehavior, with the accessTokenIdentifier & keychainAccessGroup defined
     in your Configuration
     
     - returns: An initialized LoginManager
     */
    @objc public convenience override init() {
        self.init(accessTokenIdentifier: Configuration.getDefaultAccessTokenIdentifier(), keychainAccessGroup: Configuration.getDefaultAccessTokenIdentifier(), loginBehavior: LoginBehavior.Implicit)
    }
    
     /**
     Launches view for user to log into Uber account and grant access to requested scopes.
     Access token (or error) is passed into completion handler.
     
     - parameter scopes:                   scopes being requested.
     - parameter presentingViewController: The presenting view controller present the login view controller over.
     - parameter completion:               The LoginManagerRequestTokenHandler completion handler for login success/failure.
     */
    @objc public func login(requestedScopes scopes: [RidesScope], presentingViewController: UIViewController? = nil , completion: ((accessToken: AccessToken?, error: NSError?) -> Void)? = nil) {
        self.loginCompletion = completion

        switch(self.loginBehavior) {
        case .Implicit:
            guard let presentingViewController = presentingViewController else {
                completion?(accessToken: nil, error: RidesAuthenticationErrorFactory.errorForType(ridesAuthenticationErrorType: .UnableToPresentLogin))
                self.loginCompletion = nil
                return
            }
            
            self.loginCompletion = { token, error in
                presentingViewController.dismissViewControllerAnimated(true, completion: { () -> Void in
                    completion?(accessToken: token, error: error)
                })
            };
            
            let oauthViewController = OAuthViewController(scopes: scopes)
            oauthViewController.loginView.delegate = self
            let navController = UINavigationController(rootViewController: oauthViewController)
            self.oauthViewController = oauthViewController
            
            presentingViewController.presentViewController(navController, animated: true, completion: nil)
        }
    }
    
    // MARK: Private
    
    private func displayNetworkErrorAlert() {
        guard let oauthViewController = oauthViewController else {
            self.loginCompletion?(accessToken: nil, error: RidesAuthenticationErrorFactory.errorForType(ridesAuthenticationErrorType: .NetworkError))
            return
        }
        oauthViewController.loginView.cancelLoad()
        let alertController = UIAlertController(title: nil, message: LocalizationUtil.localizedString(forKey: "The Ride Request Widget encountered a problem.", comment: "The Ride Request Widget encountered a problem."), preferredStyle: .Alert)
        let tryAgainAction = UIAlertAction(title: LocalizationUtil.localizedString(forKey: "Try Again", comment: "Try Again"), style: .Default, handler: { (UIAlertAction) -> Void in
            oauthViewController.loginView.load()
        })
        let cancelAction = UIAlertAction(title: LocalizationUtil.localizedString(forKey: "Cancel", comment: "Cancel"), style: .Cancel, handler: { (UIAlertAction) -> Void in
            self.loginCompletion?(accessToken: nil, error: RidesAuthenticationErrorFactory.errorForType(ridesAuthenticationErrorType: .NetworkError))
        })
        alertController.addAction(tryAgainAction)
        alertController.addAction(cancelAction)
        oauthViewController.presentViewController(alertController, animated: true, completion: nil)
    }
}

// MARK: LoginViewDelegate

extension LoginManager: LoginViewDelegate {
    @objc public func loginView(loginWebView: LoginView, didSucceedWithToken accessToken: AccessToken) {
        if !TokenManager.saveToken(accessToken, tokenIdentifier: accessTokenIdentifier, accessGroup: keychainAccessGroup) {
            print("Error: access token failed to save to keychain")
        }
        self.loginCompletion?(accessToken: accessToken, error: nil)
    }
    
    @objc public func loginView(loginWebView: LoginView, didFailWithError error: NSError) {
        guard error.code != RidesAuthenticationErrorType.NetworkError.rawValue else {
            displayNetworkErrorAlert()
            return
        }
        
        self.loginCompletion?(accessToken: nil, error: error)
    }
}