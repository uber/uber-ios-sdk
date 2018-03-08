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
    case signedIn
    case signedOut
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
    @objc func loginButton(_ button: LoginButton, didLogoutWithSuccess success: Bool)
    
    /**
     THe Login Button completed a login
     
     - parameter button:  The LoginButton involved
     - parameter accessToken: The access token that
     - parameter error:       The error that occured
     */
    @objc func loginButton(_ button: LoginButton, didCompleteLoginWithToken accessToken: AccessToken?, error: NSError?)
}

/// Button to handle logging in to Uber
@objc(UBSDKLoginButton) public class LoginButton: UberButton {
    
    let horizontalCenterPadding: CGFloat = 50
    let loginVerticalPadding: CGFloat = 15
    let loginHorizontalEdgePadding: CGFloat = 15

    /// The LoginButtonDelegate for this button
    @objc public weak var delegate: LoginButtonDelegate?
    
    /// The LoginManager to use for log in
    @objc public var loginManager: LoginManager {
        didSet {
            refreshContent()
        }
    }
    
    /// The UberScopes to request
    @objc public var scopes: [UberScope]
    
    /// The view controller to present login over. Used
    @objc public var presentingViewController: UIViewController?
    
    /// The current LoginButtonState of this button (signed in / signed out)
    @objc public var buttonState: LoginButtonState {
        if let _ = TokenManager.fetchToken(identifier: accessTokenIdentifier, accessGroup: keychainAccessGroup) {
            return .signedIn
        } else {
            return .signedOut
        }
    }
    
    private var accessTokenIdentifier: String {
        return loginManager.accessTokenIdentifier
    }
    
    private var keychainAccessGroup: String {
        return loginManager.keychainAccessGroup
    }
    
    private var loginCompletion: ((_ accessToken: AccessToken?, _ error: NSError?) -> Void)?
    
    @objc public init(frame: CGRect, scopes: [UberScope], loginManager: LoginManager) {
        self.loginManager = loginManager
        self.scopes = scopes
        super.init(frame: frame)
        setup()
    }
    
    public required init?(coder aDecoder: NSCoder) {
        loginManager = LoginManager(loginType: .native)
        scopes = []
        super.init(coder: aDecoder)
        setup()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    //Mark: UberButton
    
    /**
     Setup the LoginButton by adding  a target to the button and setting the login completion block
     */
    override public func setup() {
        super.setup()
        NotificationCenter.default.addObserver(self, selector: #selector(refreshContent), name: Notification.Name(rawValue: TokenManager.tokenManagerDidSaveTokenNotification), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(refreshContent), name: Notification.Name(rawValue: TokenManager.tokenManagerDidDeleteTokenNotification), object: nil)
        addTarget(self, action: #selector(uberButtonTapped), for: .touchUpInside)
        loginCompletion = { token, error in
            self.delegate?.loginButton(self, didCompleteLoginWithToken: token, error: error)
            self.refreshContent()
        }
        sizeToFit()
    }
    
    /**
     Updates the content of the button. Sets the image icon and font, as well as the text
     */
    override public func setContent() {
        super.setContent()
        
        let buttonFont = UIFont.systemFont(ofSize: 13)
        let titleText = titleForButtonState(buttonState)
        let logo = getImage("ic_logo_white")
        
        
        uberTitleLabel.font = buttonFont
        uberTitleLabel.text = titleText
        
        uberImageView.image = logo
        uberImageView.contentMode = .center
    }
    
    /**
     Adds the layout constraints for the Login button.
     */
    override public func setConstraints() {
        
        uberTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        uberImageView.translatesAutoresizingMaskIntoConstraints = false
        
        uberImageView.setContentHuggingPriority(UILayoutPriority.defaultHigh, for: .horizontal)
        uberTitleLabel.setContentHuggingPriority(UILayoutPriority.defaultHigh, for: .horizontal)
        uberTitleLabel.setContentHuggingPriority(UILayoutPriority.defaultHigh, for: .vertical)
        
        let imageLeftConstraint = NSLayoutConstraint(item: uberImageView, attribute: .left, relatedBy: .equal, toItem: self, attribute: .left, multiplier: 1.0, constant: loginHorizontalEdgePadding)
        let imageTopConstraint = NSLayoutConstraint(item: uberImageView, attribute: .top, relatedBy: .equal, toItem: self, attribute: .top, multiplier: 1.0, constant: loginVerticalPadding)
        let imageBottomConstraint = NSLayoutConstraint(item: uberImageView, attribute: .bottom, relatedBy: .equal, toItem: self, attribute: .bottom, multiplier: 1.0, constant: -loginVerticalPadding)
        
        let titleLabelRightConstraint = NSLayoutConstraint(item: uberTitleLabel, attribute: .right, relatedBy: .equal, toItem: self, attribute: .right, multiplier: 1.0, constant: -loginHorizontalEdgePadding)
        let titleLabelCenterYConstraint = NSLayoutConstraint(item: uberTitleLabel, attribute: .centerY, relatedBy: .equal, toItem: uberImageView, attribute: .centerY, multiplier: 1.0, constant: 0.0)
        
        let imagePaddingRightConstraint = NSLayoutConstraint(item: uberTitleLabel, attribute: .left, relatedBy: .greaterThanOrEqual , toItem: uberImageView, attribute: .right, multiplier: 1.0, constant: imageLabelPadding)
        
        let horizontalCenterPaddingConstraint = NSLayoutConstraint(item: uberTitleLabel, attribute: .left, relatedBy: .greaterThanOrEqual , toItem: uberImageView, attribute: .right, multiplier: 1.0, constant: horizontalCenterPadding)
        horizontalCenterPaddingConstraint.priority = UILayoutPriority.defaultLow
        
        addConstraints([imageLeftConstraint, imageTopConstraint, imageBottomConstraint])
        addConstraints([titleLabelRightConstraint, titleLabelCenterYConstraint])
        addConstraints([imagePaddingRightConstraint, horizontalCenterPaddingConstraint])
    }
    
    //Mark: UIView
    
    override public func sizeThatFits(_ size: CGSize) -> CGSize {
        let sizeThatFits = super.sizeThatFits(size)
        
        let iconSizeThatFits = uberImageView.image?.size ?? CGSize.zero
        let labelSizeThatFits = uberTitleLabel.intrinsicContentSize
        
        let labelMinHeight = labelSizeThatFits.height + 2 * loginVerticalPadding
        let iconMinHeight = iconSizeThatFits.height + 2 * loginVerticalPadding
            
        let height = max(iconMinHeight, labelMinHeight)
        
        return CGSize(width: sizeThatFits.width + horizontalCenterPadding, height: height)
    }
    
    override public func updateConstraints() {
        refreshContent()
        super.updateConstraints()
    }
    
    //Mark: Internal Interface
    
    @objc func uberButtonTapped(_ button: UIButton) {
        switch buttonState {
        case .signedIn:
            let success = TokenManager.deleteToken(identifier: accessTokenIdentifier, accessGroup: keychainAccessGroup)
            delegate?.loginButton(self, didLogoutWithSuccess: success)
            refreshContent()
        case .signedOut:
            loginManager.login(requestedScopes: scopes, presentingViewController: presentingViewController, completion: loginCompletion)
        }
    }
    
    //Mark: Private Interface
    
    @objc private func refreshContent() {
        DispatchQueue.main.async { [weak self] in
            guard let strongSelf = self else { return }

            strongSelf.uberTitleLabel.text = strongSelf.titleForButtonState(strongSelf.buttonState)
        }
    }
    
    private func titleForButtonState(_ buttonState: LoginButtonState) -> String {
        var titleText: String!
        switch buttonState {
        case .signedIn:
            titleText = NSLocalizedString("Sign Out", bundle: Bundle(for: type(of: self)), comment: "Login Button Sign Out Description").uppercased()
        case .signedOut:
            titleText = NSLocalizedString("Sign In", bundle: Bundle(for: type(of: self)), comment: "Login Button Sign In Description").uppercased()
        }
        return titleText
    }

    private func getImage(_ name: String) -> UIImage? {
        let bundle = Bundle(for: LoginButton.self)
        return UIImage(named: name, in: bundle, compatibleWith: nil)?.withRenderingMode(.alwaysTemplate)
    }
}
