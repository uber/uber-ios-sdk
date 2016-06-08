//
//  NativeLoginExampleViewController.swift
//  Swift SDK
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
import UberRides
import CoreLocation

/// This class provides an example for using the LoginButton to do Native Login (SSO with the Uber App)
public class NativeLoginExampleViewController: ButtonExampleViewController, LoginButtonDelegate {
    
    let scopes: [RidesScope]
    let loginManager: LoginManager
    let blackLoginButton: LoginButton
    let whiteLoginButton: LoginButton
    
    override public init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
        scopes = [.Profile, .Places, .Request]
        loginManager = LoginManager(loginType: .Native)
        blackLoginButton = LoginButton(frame: CGRectZero, scopes: scopes, loginManager: loginManager)
        whiteLoginButton = LoginButton(frame: CGRectZero, scopes: scopes, loginManager: loginManager)
        
        whiteLoginButton.colorStyle = .White
        
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)

        blackLoginButton.presentingViewController = self
        whiteLoginButton.presentingViewController = self
        
        blackLoginButton.delegate = self
        whiteLoginButton.delegate = self
    }
    
    public required init?(coder aDecoder: NSCoder) {
        fatalError("init?(coder aDecoder: NSCoder) is not supported")
    }
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.title = "SSO"
        
        topView.addSubview(blackLoginButton)
        bottomView.addSubview(whiteLoginButton)
        
        addBlackLoginButtonConstraints()
        addWhiteLoginButtonConstraints()
    }
    
    // Mark: Private Interface
    
    private func addBlackLoginButtonConstraints() {
        blackLoginButton.translatesAutoresizingMaskIntoConstraints = false
        
        let centerYConstraint = NSLayoutConstraint(item: blackLoginButton, attribute: .CenterY, relatedBy: .Equal, toItem: topView, attribute: .CenterY, multiplier: 1.0, constant: 0.0)
        let centerXConstraint = NSLayoutConstraint(item: blackLoginButton, attribute: .CenterX, relatedBy: .Equal, toItem: topView, attribute: .CenterX, multiplier: 1.0, constant: 0.0)
        let widthConstraint = NSLayoutConstraint(item: blackLoginButton, attribute: .Width, relatedBy: .Equal, toItem: topView, attribute: .Width, multiplier: 1.0, constant: -20.0)
        
        topView.addConstraints([centerYConstraint, centerXConstraint, widthConstraint])
    }
    
    private func addWhiteLoginButtonConstraints() {
        whiteLoginButton.translatesAutoresizingMaskIntoConstraints = false
        
        let centerYConstraint = NSLayoutConstraint(item: whiteLoginButton, attribute: .CenterY, relatedBy: .Equal, toItem: bottomView, attribute: .CenterY, multiplier: 1.0, constant: 0.0)
        let centerXConstraint = NSLayoutConstraint(item: whiteLoginButton, attribute: .CenterX, relatedBy: .Equal, toItem: bottomView, attribute: .CenterX, multiplier: 1.0, constant: 0.0)
        let widthConstraint = NSLayoutConstraint(item: whiteLoginButton, attribute: .Width, relatedBy: .Equal, toItem: bottomView, attribute: .Width, multiplier: 1.0, constant: -20.0)
        
        bottomView.addConstraints([centerYConstraint, centerXConstraint, widthConstraint])
    }
    
    private func showMessage(message: String) {
        let alert = UIAlertController(title: nil, message: message, preferredStyle: UIAlertControllerStyle.Alert)
        let okayAction = UIAlertAction(title: "Okay", style: UIAlertActionStyle.Default, handler: nil)
        alert.addAction(okayAction)
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    // Mark: LoginButtonDelegate
    
    public func loginButton(button: LoginButton, didLogoutWithSuccess success: Bool) {
        if success {
            showMessage("Logout")
        }
    }
    
    public func loginButton(button: LoginButton, didCompleteLoginWithToken accessToken: AccessToken?, error: NSError?) {
        if let _ = accessToken {
            showMessage("Saved access token!")
        } else if let error = error {
            showMessage(error.localizedDescription)
        } else {
            showMessage("Error")
        }
    }
}

