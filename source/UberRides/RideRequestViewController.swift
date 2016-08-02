//
//  RideRequestViewController.swift
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

import UIKit
import MapKit

/**
 *  Delegate Protocol to pass errors from the internal RideRequestView outward if necessary.
 *  For example, you might want to dismiss the View Controller if it experiences an error
 */
@objc(UBSDKRideRequestViewControllerDelegate) public protocol RideRequestViewControllerDelegate {
    /**
     Delegate method to pass on errors from the RideRequestView that can't be handled
     by the RideRequestViewController
     
     - parameter rideRequestViewController: The RideRequestViewController that experienced the error
     - parameter error:                     The NSError that was experienced, with a code related to the appropriate RideRequestViewErrorType
     */
    @objc func rideRequestViewController(rideRequestViewController: RideRequestViewController, didReceiveError error: NSError)
}

// View controller to wrap the RideRequestView
@objc (UBSDKRideRequestViewController) public class RideRequestViewController: UIViewController {
    /// The RideRequestViewControllerDelegate to handle the errors
    public var delegate: RideRequestViewControllerDelegate?
    
    /// The LoginManager to use for managing the login process
    public var loginManager: LoginManager {
        didSet {
            accessTokenIdentifier = loginManager.accessTokenIdentifier
            keychainAccessGroup = loginManager.keychainAccessGroup
        }
    }
    
    lazy var rideRequestView: RideRequestView = RideRequestView()
    lazy var loginView: LoginView = LoginView(loginAuthenticator: ImplicitGrantAuthenticator(presentingViewController: self, scopes: [.RideWidgets]))
    lazy var nativeAuthenticator = NativeAuthenticator(scopes: [.RideWidgets])
    
    static let sourceString = "ride_request_widget"
    
    private var accessTokenWasUnauthorizedOnPreviousAttempt = false
    private var accessTokenIdentifier: String
    private var keychainAccessGroup: String
    private var loginCompletion: ((accessToken: AccessToken?, error: NSError?) -> Void)?
    
    /**
     Initializes a RideRequestViewController using the provided coder. By default,
     uses the default token identifier and access group
     
     - parameter aDecoder: The Coder to use
     
     - returns: An initialized RideRequestViewController, or nil if something went wrong
     */
    @objc public required init?(coder aDecoder: NSCoder) {
        loginManager = LoginManager()
        accessTokenIdentifier = loginManager.accessTokenIdentifier
        keychainAccessGroup = loginManager.keychainAccessGroup
        
        super.init(coder: aDecoder)
        
        let builder = RideParametersBuilder()
        builder.setSource(RideRequestViewController.sourceString)
        let defaultRideParameters = builder.build()
        
        rideRequestView.rideParameters = defaultRideParameters
    }
    
     /**
     Designated initializer for the RideRequestViewController.
    
     - parameter rideParameters: The RideParameters to use for prefilling the RideRequestView.
     - parameter loginManager:   The LoginManger to use for logging in (if required). Also uses its values for token identifier & access group to check for an access token
     
     - returns: An initialized RideRequestViewController
     */
    @objc public init(rideParameters: RideParameters, loginManager: LoginManager) {
        self.loginManager = loginManager
        accessTokenIdentifier = loginManager.accessTokenIdentifier
        keychainAccessGroup = loginManager.keychainAccessGroup
        
        super.init(nibName: nil, bundle: nil)
        
        if rideParameters.source == nil {
            rideParameters.source = RideRequestViewController.sourceString
        }
        
        rideRequestView.rideParameters = rideParameters
        rideRequestView.accessToken = TokenManager.fetchToken(accessTokenIdentifier, accessGroup: keychainAccessGroup)
    }
    
    // MARK: View Lifecycle
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        self.edgesForExtendedLayout = UIRectEdge.None
        self.view.backgroundColor = UIColor.whiteColor()
        
        setupRideRequestView()
        setupLoginView()
    }
    
    public override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        self.load()
    }
    
    public override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        stopLoading()
        accessTokenWasUnauthorizedOnPreviousAttempt = false
    }
    
    // MARK: UIViewController
    
    public override func supportedInterfaceOrientations() -> UIInterfaceOrientationMask {
        return [.Portrait, .PortraitUpsideDown]
    }
    
    // MARK: Internal

    func load() {
        if let accessToken = TokenManager.fetchToken(accessTokenIdentifier, accessGroup: keychainAccessGroup) {
            rideRequestView.accessToken = accessToken
            rideRequestView.hidden = false
            loginView.hidden = true
            rideRequestView.load()
        } else {
            switch loginManager.loginType {
            case .Native:
                executeNativeLogin()
            case .Implicit:
                fallthrough
            case .AuthorizationCode:
                loginView.hidden = false
                rideRequestView.hidden = true
                loginView.load()
            }
        }
    }
    
    func executeNativeLogin() {
        loginManager.authenticator = nativeAuthenticator
        loginManager.loggingIn = true
        nativeAuthenticator.login()
    }
    
    func stopLoading() {
        loginView.cancelLoad()
        rideRequestView.cancelLoad()
    }
    
    func displayNetworkErrorAlert() {
        self.rideRequestView.cancelLoad()
        self.loginView.cancelLoad()
        let alertController = UIAlertController(title: nil, message: LocalizationUtil.localizedString(forKey: "The Ride Request Widget encountered a problem.", comment: "The Ride Request Widget encountered a problem."), preferredStyle: .Alert)
        let tryAgainAction = UIAlertAction(title: LocalizationUtil.localizedString(forKey: "Try Again", comment: "Try Again"), style: .Default, handler: { (UIAlertAction) -> Void in
            self.load()
        })
        let cancelAction = UIAlertAction(title: LocalizationUtil.localizedString(forKey: "Cancel", comment: "Cancel"), style: .Cancel, handler: { (UIAlertAction) -> Void in
            self.delegate?.rideRequestViewController(self, didReceiveError: RideRequestViewErrorFactory.errorForType(.NetworkError))
        })
        alertController.addAction(tryAgainAction)
        alertController.addAction(cancelAction)
        self.presentViewController(alertController, animated: true, completion: nil)
    }
    
    func displayNotSupportedErrorAlert() {
        let alertController = UIAlertController(title: nil, message: LocalizationUtil.localizedString(forKey: "The operation you are attempting is not supported on the current device.", comment: "The operation you are attempting is not supported on the current device."), preferredStyle: .Alert)
        let okayAction = UIAlertAction(title: LocalizationUtil.localizedString(forKey: "OK", comment: "OK"), style: .Default, handler: nil)
        alertController.addAction(okayAction)
        self.presentViewController(alertController, animated: true, completion: nil)
    }
    
    //MARK: Private
    
    private func setupRideRequestView() {
        self.view.addSubview(rideRequestView)
        
        rideRequestView.translatesAutoresizingMaskIntoConstraints = false
        
        let views = ["rideRequestView": rideRequestView]
        let horizontalConstraints = NSLayoutConstraint.constraintsWithVisualFormat("H:|[rideRequestView]|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: views)
        let verticalConstraints = NSLayoutConstraint.constraintsWithVisualFormat("V:|[rideRequestView]|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: views)
        
        self.view.addConstraints(horizontalConstraints)
        self.view.addConstraints(verticalConstraints)
        
        rideRequestView.delegate = self
    }
    
    private func setupLoginView() {
        switch loginManager.loginType {
        case .AuthorizationCode:
            fallthrough
        case .Implicit:
            setupImplicitLoginView()
            break
        case .Native:
            setupNativeLogin()
            break
        }
    }
    
    private func setupImplicitLoginView() {
        let loginBehavior = ImplicitGrantAuthenticator(presentingViewController: self, scopes: [.RideWidgets])
        loginBehavior.loginCompletion = { token, error in
            guard let token = token else {
                if error?.code == RidesAuthenticationErrorType.NetworkError.rawValue {
                    self.displayNetworkErrorAlert()
                } else {
                    self.delegate?.rideRequestViewController(self, didReceiveError: RideRequestViewErrorFactory.errorForType(.AccessTokenMissing))
                }
                return
            }
            self.loginView.hidden = true
            self.rideRequestView.accessToken = token
            self.rideRequestView.hidden = false
            self.load()
        }
        loginManager.authenticator = loginBehavior
        let loginView = LoginView(loginAuthenticator: loginBehavior)
        self.view.addSubview(loginView)
        loginView.hidden = true
        loginView.translatesAutoresizingMaskIntoConstraints = false
        
        let views = ["loginView": loginView]
        let horizontalConstraints = NSLayoutConstraint.constraintsWithVisualFormat("H:|[loginView]|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: views)
        let verticalConstraints = NSLayoutConstraint.constraintsWithVisualFormat("V:|[loginView]|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: views)
        
        self.view.addConstraints(horizontalConstraints)
        self.view.addConstraints(verticalConstraints)
        
        self.loginView = loginView
    }
    
    private func setupNativeLogin() {
        
        nativeAuthenticator.loginCompletion = { token, error in
            guard let token = token else {
                if error?.code == RidesAuthenticationErrorType.NetworkError.rawValue {
                    self.displayNetworkErrorAlert()
                } else if error?.code == RidesAuthenticationErrorType.Unavailable.rawValue {
                    self.loginManager.loginType = .Implicit
                    self.setupLoginView()
                    self.load()
                    self.loginManager.loginType = .Native
                } else {
                    self.delegate?.rideRequestViewController(self, didReceiveError: RideRequestViewErrorFactory.errorForType(.AccessTokenMissing))
                }
                return
            }
            self.loginView.hidden = true
            self.rideRequestView.accessToken = token
            self.rideRequestView.hidden = false
            self.load()
        }
        nativeAuthenticator.deeplinkCompletion = { error in
            if (error == nil) {
                RidesAppDelegate.sharedInstance.loginManager = self.loginManager
            }
        };
    }
}

//MARK: RideRequestView Delegate

extension RideRequestViewController : RideRequestViewDelegate {
    public func rideRequestView(rideRequestView: RideRequestView, didReceiveError error: NSError) {
        let errorType = RideRequestViewErrorType(rawValue: error.code) ?? .Unknown
        switch errorType {
        case .NetworkError:
            self.displayNetworkErrorAlert()
            break
        case .NotSupported:
            self.displayNotSupportedErrorAlert()
            break
        case .AccessTokenMissing:
            fallthrough
        case .AccessTokenExpired:
            if accessTokenWasUnauthorizedOnPreviousAttempt {
                fallthrough
            }
            attemptTokenRefresh(accessTokenIdentifier, accessGroup: keychainAccessGroup)
            break
        default:
            self.delegate?.rideRequestViewController(self, didReceiveError: error)
            break
        }
    }

    private func attemptTokenRefresh(tokenIdentifier: String?, accessGroup: String?) {
        let identifer = tokenIdentifier ?? Configuration.getDefaultAccessTokenIdentifier()
        let group = accessGroup ?? Configuration.getDefaultKeychainAccessGroup()
        guard let accessToken = TokenManager.fetchToken(identifer, accessGroup: group), refreshToken = accessToken.refreshToken else {
            accessTokenWasUnauthorizedOnPreviousAttempt = true
            TokenManager.deleteToken(identifer, accessGroup: group)
            self.load()
            return
        }
        TokenManager.deleteToken(accessTokenIdentifier, accessGroup: keychainAccessGroup)

        let ridesClient = RidesClient(accessTokenIdentifier: identifer, keychainAccessGroup: group)
        ridesClient.refreshAccessToken(refreshToken) { (accessToken, response) in
            if let token = accessToken {
                TokenManager.saveToken(token, tokenIdentifier: self.accessTokenIdentifier, accessGroup: self.keychainAccessGroup)
            }
            self.load()
        }
    }
}
