//
//  UberLoginButton.swift
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

import UIKit

@objc public enum LoginButtonState : Int {
    case SignedIn
    case SignedOut
}

/**
 *  Protocol to listen to login button events, such as logging in / out
 */
@objc(UBSDKLoginButtonDelegate) public protocol LoginButtonDelegate {
    
    /**
     The Login Button attempted to log out
     
     - parameter button:  The LoginButton involved
     - parameter success: True if log out succeeded, false otherwise
     */
    @objc func loginButton(button: LoginButton, didLogoutWithSuccess success: Bool)
    
    /**
     THe Login Button completed a login
     
     - parameter button:  The LoginButton involved
     - parameter accessToken: The access token that
     - parameter error:       The error that occured
     */
    @objc func loginButton(button: LoginButton, didCompleteLoginWithToken accessToken: AccessToken?, error: NSError?)
}

/// Button to handle logging in to Uber
@objc(UBSDKLoginButton) public class LoginButton: UberButton {
    
    let horizontalCenterPadding: CGFloat = 50
    let loginVerticalPadding: CGFloat = 15
    let loginHorizontalEdgePadding: CGFloat = 15
    
    /// The LoginButtonDelegate for this button
    public weak var delegate: LoginButtonDelegate?
    
    /// The LoginManager to use for log in
    public var loginManager: LoginManager {
        didSet {
            refreshContent()
        }
    }
    
    /// The RidesScopes to request
    public var scopes: [RidesScope]
    
    /// The view controller to present login over. Used
    public var presentingViewController: UIViewController?
    
    /// The current LoginButtonState of this button (signed in / signed out)
    public var buttonState: LoginButtonState {
        if let _ = TokenManager.fetchToken(accessTokenIdentifier, accessGroup: keychainAccessGroup) {
            return .SignedIn
        } else {
            return .SignedOut
        }
    }
    
    private var accessTokenIdentifier: String {
        return loginManager.accessTokenIdentifier
    }
    
    private var keychainAccessGroup: String {
        return loginManager.keychainAccessGroup
    }
    
    private var loginCompletion: ((accessToken: AccessToken?, error: NSError?) -> Void)?
    
    public init(frame: CGRect, scopes: [RidesScope], loginManager: LoginManager) {
        self.loginManager = loginManager
        self.scopes = scopes
        super.init(frame: frame)
        setup()
    }
    
    public required init?(coder aDecoder: NSCoder) {
        loginManager = LoginManager(loginType: .Native)
        scopes = []
        super.init(coder: aDecoder)
        setup()
    }
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    //Mark: UberButton
    
    /**
     Setup the LoginButton by adding  a target to the button and setting the login completion block
     */
    override public func setup() {
        super.setup()
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(refreshContent), name: TokenManager.TokenManagerDidSaveTokenNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(refreshContent), name: TokenManager.TokenManagerDidDeleteTokenNotification, object: nil)
        addTarget(self, action: #selector(uberButtonTapped), forControlEvents: .TouchUpInside)
        loginCompletion = { token, error in
            self.delegate?.loginButton(self, didCompleteLoginWithToken: token, error: error)
            self.refreshContent()
        }
    }
    
    /**
     Updates the content of the button. Sets the image icon and font, as well as the text
     */
    override public func setContent() {
        super.setContent()
        
        let buttonFont = UIFont.systemFontOfSize(13)
        let titleText = titleForButtonState(buttonState)
        let logo = getImage("ic_logo_white")
        
        
        uberTitleLabel.font = buttonFont
        uberTitleLabel.text = titleText
        
        uberImageView.image = logo
        uberImageView.contentMode = .Center
    }
    
    /**
     Adds the layout constraints for the Login button.
     */
    override public func setConstraints() {
        
        uberTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        uberImageView.translatesAutoresizingMaskIntoConstraints = false
        
        uberImageView.setContentHuggingPriority(UILayoutPriorityDefaultHigh, forAxis: .Horizontal)
        uberTitleLabel.setContentHuggingPriority(UILayoutPriorityDefaultHigh, forAxis: .Horizontal)
        uberTitleLabel.setContentHuggingPriority(UILayoutPriorityDefaultHigh, forAxis: .Vertical)
        
        let imageLeftConstraint = NSLayoutConstraint(item: uberImageView, attribute: .Left, relatedBy: .Equal, toItem: self, attribute: .Left, multiplier: 1.0, constant: loginHorizontalEdgePadding)
        let imageTopConstraint = NSLayoutConstraint(item: uberImageView, attribute: .Top, relatedBy: .Equal, toItem: self, attribute: .Top, multiplier: 1.0, constant: loginVerticalPadding)
        let imageBottomConstraint = NSLayoutConstraint(item: uberImageView, attribute: .Bottom, relatedBy: .Equal, toItem: self, attribute: .Bottom, multiplier: 1.0, constant: -loginVerticalPadding)
        
        let titleLabelRightConstraint = NSLayoutConstraint(item: uberTitleLabel, attribute: .Right, relatedBy: .Equal, toItem: self, attribute: .Right, multiplier: 1.0, constant: -loginHorizontalEdgePadding)
        let titleLabelCenterYConstraint = NSLayoutConstraint(item: uberTitleLabel, attribute: .CenterY, relatedBy: .Equal, toItem: uberImageView, attribute: .CenterY, multiplier: 1.0, constant: 0.0)
        
        let imagePaddingRightConstraint = NSLayoutConstraint(item: uberTitleLabel, attribute: .Left, relatedBy: .GreaterThanOrEqual , toItem: uberImageView, attribute: .Right, multiplier: 1.0, constant: imageLabelPadding)
        
        let horizontalCenterPaddingConstraint = NSLayoutConstraint(item: uberTitleLabel, attribute: .Left, relatedBy: .GreaterThanOrEqual , toItem: uberImageView, attribute: .Right, multiplier: 1.0, constant: horizontalCenterPadding)
        horizontalCenterPaddingConstraint.priority = UILayoutPriorityDefaultLow
        
        addConstraints([imageLeftConstraint, imageTopConstraint, imageBottomConstraint])
        addConstraints([titleLabelRightConstraint, titleLabelCenterYConstraint])
        addConstraints([imagePaddingRightConstraint, horizontalCenterPaddingConstraint])
    }
    
    //Mark: UIView
    
    override public func sizeThatFits(size: CGSize) -> CGSize {
        let sizeThatFits = super.sizeThatFits(size)
        
        let iconSizeThatFits = uberImageView.image?.size ?? CGSizeZero
        let labelSizeThatFits = uberTitleLabel.intrinsicContentSize()
        
        let labelMinHeight = labelSizeThatFits.height + 2 * loginVerticalPadding
        let iconMinHeight = iconSizeThatFits.height + 2 * loginVerticalPadding
            
        let height = max(iconMinHeight, labelMinHeight)
        
        return CGSizeMake(sizeThatFits.width + horizontalCenterPadding, height)
    }
    
    override public func updateConstraints() {
        refreshContent()
        super.updateConstraints()
    }
    
    //Mark: Internal Interface
    
    func uberButtonTapped(button: UIButton) {
        switch buttonState {
        case .SignedIn:
            let success = TokenManager.deleteToken(accessTokenIdentifier, accessGroup: keychainAccessGroup)
            delegate?.loginButton(self, didLogoutWithSuccess: success)
            refreshContent()
        case .SignedOut:
            loginManager.login(requestedScopes: scopes, presentingViewController: presentingViewController, completion: loginCompletion)
        }
    }
    
    //Mark: Private Interface
    
    @objc private func refreshContent() {
        uberTitleLabel.text = titleForButtonState(buttonState)
    }
    
    private func titleForButtonState(buttonState: LoginButtonState) -> String {
        var titleText: String!
        switch buttonState {
        case .SignedIn:
            titleText = LocalizationUtil.localizedString(forKey: "Sign Out", comment: "Login Button Sign Out Description").uppercaseString
        case .SignedOut:
            titleText = LocalizationUtil.localizedString(forKey: "Sign In", comment: "Login Button Sign In Description").uppercaseString
        }
        return titleText
    }

    private func getImage(name: String) -> UIImage? {
        let bundle = NSBundle(forClass: RideRequestButton.self)
        return UIImage(named: name, inBundle: bundle, compatibleWithTraitCollection: nil)?.imageWithRenderingMode(.AlwaysTemplate)
    }
}
