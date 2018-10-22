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
import UberCore

/**
 *  Delegate Protocol to pass errors from the internal RideRequestView outward if necessary.
 *  For example, you might want to dismiss the View Controller if it experiences an error
 - Warning: The Ride Request Widget is deprecated, and will no longer work for new apps.
 Existing apps have until 05/31/2018 to migrate. See the Uber API Changelog for more details.
 */
@objc(UBSDKRideRequestViewControllerDelegate) public protocol RideRequestViewControllerDelegate {
    /**
     Delegate method to pass on errors from the RideRequestView that can't be handled
     by the RideRequestViewController
     
     - parameter rideRequestViewController: The RideRequestViewController that experienced the error
     - parameter error:                     The NSError that was experienced, with a code related to the appropriate RideRequestViewErrorType
     */
    @objc func rideRequestViewController(_ rideRequestViewController: RideRequestViewController, didReceiveError error: NSError)
}

/**
 View controller to wrap the RideRequestView
 - Warning: The Ride Request Widget is deprecated, and will no longer work for new apps.
 Existing apps have until 05/31/2018 to migrate. See the Uber API Changelog for more details.
*/
@objc (UBSDKRideRequestViewController) public class RideRequestViewController: UIViewController {
    /// The RideRequestViewControllerDelegate to handle the errors
    @objc public var delegate: RideRequestViewControllerDelegate?
    
    /// The LoginManager to use for managing the login process
    @objc public var loginManager: LoginManager
    
    lazy var rideRequestView: RideRequestView = RideRequestView()

    static let sourceString = "ride_request_widget"

    private var accessTokenWasUnauthorizedOnPreviousAttempt = false
    private var loginCompletion: ((_ accessToken: AccessToken?, _ error: NSError?) -> Void)?
    
    /**
     Initializes a RideRequestViewController using the provided coder. By default,
     uses the default token identifier and access group
     
     - parameter aDecoder: The Coder to use
     
     - returns: An initialized RideRequestViewController, or nil if something went wrong
     */
    @objc public required init?(coder aDecoder: NSCoder) {
        loginManager = LoginManager()
        
        super.init(coder: aDecoder)

        let defaultRideParameters = RideParametersBuilder()
        defaultRideParameters.source = RideRequestViewController.sourceString
        
        rideRequestView.rideParameters = defaultRideParameters.build()
    }
    
     /**
     Designated initializer for the RideRequestViewController.
    
     - parameter rideParameters: The RideParameters to use for prefilling the RideRequestView.
     - parameter loginManager:   The LoginManger to use for logging in (if required). Also uses its values for token identifier & access group to check for an access token
     
     - returns: An initialized RideRequestViewController
     */
    @objc public init(rideParameters: RideParameters, loginManager: LoginManager) {
        self.loginManager = loginManager
        
        super.init(nibName: nil, bundle: nil)
        
        rideParameters.source = rideParameters.source ?? RideRequestViewController.sourceString
        
        rideRequestView.rideParameters = rideParameters
        rideRequestView.accessToken = TokenManager.fetchToken(identifier: loginManager.accessTokenIdentifier, accessGroup: loginManager.keychainAccessGroup)
    }
    
    // MARK: View Lifecycle
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        self.edgesForExtendedLayout = UIRectEdge()
        self.view.backgroundColor = UIColor.white
        
        setupRideRequestView()
    }

    public override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        load()
    }
    
    public override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        accessTokenWasUnauthorizedOnPreviousAttempt = false
    }
    
    // MARK: UIViewController
    
    public override var supportedInterfaceOrientations : UIInterfaceOrientationMask {
        return [.portrait, .portraitUpsideDown]
    }
    
    // MARK: Internal

    func load() {
        if let accessToken = TokenManager.fetchToken(identifier: loginManager.accessTokenIdentifier, accessGroup: loginManager.keychainAccessGroup) {
            rideRequestView.accessToken = accessToken
            rideRequestView.load()
        } else {
            loginManager.login(requestedScopes: [.rideWidgets], presentingViewController: self) { accessToken, error in
                if let accessToken = accessToken {
                    self.rideRequestView.accessToken = accessToken
                    self.rideRequestView.load()
                } else {
                    self.delegate?.rideRequestViewController(self, didReceiveError: RideRequestViewErrorFactory.errorForType(.accessTokenMissing))
                }
            }
        }
    }
    
    func stopLoading() {
        rideRequestView.cancelLoad()
    }
    
    func displayNetworkErrorAlert() {
        self.rideRequestView.cancelLoad()
        let alertController = UIAlertController(title: nil, message: NSLocalizedString("The Ride Request Widget encountered a problem.", bundle: Bundle(for: type(of: self)), comment: "The Ride Request Widget encountered a problem."), preferredStyle: .alert)
        let tryAgainAction = UIAlertAction(title: NSLocalizedString("Try Again", bundle: Bundle(for: type(of: self)), comment: "Try Again"), style: .default, handler: { (UIAlertAction) -> Void in
            self.load()
        })
        let cancelAction = UIAlertAction(title: NSLocalizedString("Cancel", bundle: Bundle(for: type(of: self)), comment: "Cancel"), style: .cancel, handler: { (UIAlertAction) -> Void in
            self.delegate?.rideRequestViewController(self, didReceiveError: RideRequestViewErrorFactory.errorForType(.networkError))
        })
        alertController.addAction(tryAgainAction)
        alertController.addAction(cancelAction)
        self.present(alertController, animated: true, completion: nil)
    }
    
    func displayNotSupportedErrorAlert() {
        let alertController = UIAlertController(title: nil, message: NSLocalizedString("The operation you are attempting is not supported on the current device.", bundle: Bundle(for: type(of: self)), comment: "The operation you are attempting is not supported on the current device."), preferredStyle: .alert)
        let okayAction = UIAlertAction(title: NSLocalizedString("OK", bundle: Bundle(for: type(of: self)), comment: "OK"), style: .default, handler: nil)
        alertController.addAction(okayAction)
        self.present(alertController, animated: true, completion: nil)
    }
    
    //MARK: Private
    
    private func setupRideRequestView() {
        self.view.addSubview(rideRequestView)
        
        rideRequestView.translatesAutoresizingMaskIntoConstraints = false
        
        let views = ["rideRequestView": rideRequestView]
        let horizontalConstraints = NSLayoutConstraint.constraints(withVisualFormat: "H:|[rideRequestView]|", options: NSLayoutConstraint.FormatOptions(rawValue: 0), metrics: nil, views: views)
        let verticalConstraints = NSLayoutConstraint.constraints(withVisualFormat: "V:|[rideRequestView]|", options: NSLayoutConstraint.FormatOptions(rawValue: 0), metrics: nil, views: views)
        
        self.view.addConstraints(horizontalConstraints)
        self.view.addConstraints(verticalConstraints)
        
        rideRequestView.delegate = self
    }
}

//MARK: RideRequestView Delegate

extension RideRequestViewController : RideRequestViewDelegate {
    public func rideRequestView(_ rideRequestView: RideRequestView, didReceiveError error: NSError) {
        let errorType = RideRequestViewErrorType(rawValue: error.code) ?? .unknown
        switch errorType {
        case .networkError:
            self.displayNetworkErrorAlert()
            break
        case .notSupported:
            self.displayNotSupportedErrorAlert()
            break
        case .accessTokenMissing:
            fallthrough
        case .accessTokenExpired:
            if accessTokenWasUnauthorizedOnPreviousAttempt {
                fallthrough
            }
            attemptTokenRefresh()
            break
        default:
            self.delegate?.rideRequestViewController(self, didReceiveError: error)
            break
        }
    }

    private func attemptTokenRefresh() {
        let identifer = loginManager.accessTokenIdentifier
        let group = loginManager.keychainAccessGroup
        guard let accessToken = TokenManager.fetchToken(identifier: identifer, accessGroup: group), let refreshToken = accessToken.refreshToken else {
            accessTokenWasUnauthorizedOnPreviousAttempt = true
            _ = TokenManager.deleteToken(identifier: identifer, accessGroup: group)
            self.load()
            return
        }
        _ = TokenManager.deleteToken(identifier: identifer, accessGroup: group)

        let ridesClient = RidesClient()
        ridesClient.refreshAccessToken(usingRefreshToken: refreshToken) { (accessToken, response) in
            if let token = accessToken {
                _ = TokenManager.save(accessToken: token, tokenIdentifier: identifer, accessGroup: group)
            }
            self.load()
        }
    }
}
