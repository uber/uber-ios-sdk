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
import UberCore
import UberRides
import CoreLocation

/// This class provides an example for using the LoginButton to do Native Login (SSO with the Uber App)
open class NativeLoginExampleViewController: ButtonExampleViewController, LoginButtonDelegate {
    
    let scopes: [UberScope]
    let loginManager: LoginManager
    let blackLoginButton: LoginButton
    let whiteLoginButton: LoginButton
    
    override public init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        scopes = [.profile, .places, .request]
        
        loginManager = LoginManager(loginType: .native)
        blackLoginButton = LoginButton(frame: CGRect.zero, scopes: scopes, loginManager: loginManager)
        whiteLoginButton = LoginButton(frame: CGRect.zero, scopes: scopes, loginManager: loginManager)
        
        whiteLoginButton.colorStyle = .white
        
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)

        blackLoginButton.presentingViewController = self
        whiteLoginButton.presentingViewController = self
        
        blackLoginButton.delegate = self
        whiteLoginButton.delegate = self
    }
    
    public required init?(coder aDecoder: NSCoder) {
        fatalError("init?(coder aDecoder: NSCoder) is not supported")
    }
    
    override open func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.title = "SSO"
        
        topView.addSubview(blackLoginButton)
        bottomView.addSubview(whiteLoginButton)
        
        addBlackLoginButtonConstraints()
        addWhiteLoginButtonConstraints()
    }
    
    // Mark: Private Interface
    
    fileprivate func addBlackLoginButtonConstraints() {
        blackLoginButton.translatesAutoresizingMaskIntoConstraints = false
        
        let centerYConstraint = NSLayoutConstraint(item: blackLoginButton, attribute: .centerY, relatedBy: .equal, toItem: topView, attribute: .centerY, multiplier: 1.0, constant: 0.0)
        let centerXConstraint = NSLayoutConstraint(item: blackLoginButton, attribute: .centerX, relatedBy: .equal, toItem: topView, attribute: .centerX, multiplier: 1.0, constant: 0.0)
        let widthConstraint = NSLayoutConstraint(item: blackLoginButton, attribute: .width, relatedBy: .equal, toItem: topView, attribute: .width, multiplier: 1.0, constant: -20.0)
        
        topView.addConstraints([centerYConstraint, centerXConstraint, widthConstraint])
    }
    
    fileprivate func addWhiteLoginButtonConstraints() {
        whiteLoginButton.translatesAutoresizingMaskIntoConstraints = false
        
        let centerYConstraint = NSLayoutConstraint(item: whiteLoginButton, attribute: .centerY, relatedBy: .equal, toItem: bottomView, attribute: .centerY, multiplier: 1.0, constant: 0.0)
        let centerXConstraint = NSLayoutConstraint(item: whiteLoginButton, attribute: .centerX, relatedBy: .equal, toItem: bottomView, attribute: .centerX, multiplier: 1.0, constant: 0.0)
        let widthConstraint = NSLayoutConstraint(item: whiteLoginButton, attribute: .width, relatedBy: .equal, toItem: bottomView, attribute: .width, multiplier: 1.0, constant: -20.0)
        
        bottomView.addConstraints([centerYConstraint, centerXConstraint, widthConstraint])
    }
    
    fileprivate func showMessage(_ message: String) {
        let alert = UIAlertController(title: nil, message: message, preferredStyle: UIAlertControllerStyle.alert)
        let okayAction = UIAlertAction(title: "Okay", style: UIAlertActionStyle.default, handler: nil)
        alert.addAction(okayAction)
        self.present(alert, animated: true, completion: nil)
    }
    
    // Mark: LoginButtonDelegate
    
    open func loginButton(_ button: LoginButton, didLogoutWithSuccess success: Bool) {
        if success {
            showMessage("Logout")
        }
    }
    
    open func loginButton(_ button: LoginButton, didCompleteLoginWithToken accessToken: AccessToken?, error: NSError?) {
        if let _ = accessToken {
            showMessage("Saved access token!")
        } else if let error = error {
            showMessage(error.localizedDescription)
        } else {
            showMessage("Error")
        }
    }
}

