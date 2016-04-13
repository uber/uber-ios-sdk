//
//  ImplicitGrantExampleViewController.swift
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

/// This class demonstrates how do use the LoginManager to complete Implicit Grant Authorization
class ImplicitGrantExampleViewController: UIViewController {
    /// The LoginManager to use for login
    let loginManager = LoginManager()
    
    let loginButton = UIButton(type: .RoundedRect)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.whiteColor()
        self.navigationItem.title = "Implicit Grant / Login Manager"
        
        self.setupLoginButton()
    }
    
    /**
     Sets up the login button
     */
    private func setupLoginButton() {
        // Using autolayout
        loginButton.setTitle("Login", forState: .Normal)
        loginButton.sizeToFit()
        loginButton.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(loginButton)
        
        // Center the button in the view
        let centerXConstraint = NSLayoutConstraint(item: loginButton, attribute: NSLayoutAttribute.CenterX, relatedBy: NSLayoutRelation.Equal, toItem: view, attribute: NSLayoutAttribute.CenterX, multiplier: 1.0, constant: 0.0)
        let centerYConstraint = NSLayoutConstraint(item: loginButton, attribute: NSLayoutAttribute.CenterY, relatedBy: NSLayoutRelation.Equal, toItem: view, attribute: NSLayoutAttribute.CenterY, multiplier: 1.0, constant: 0.0)
        
        self.view.addConstraints([ centerXConstraint, centerYConstraint ])
        
        // Add our login action
        loginButton.addTarget(self, action: Selector("loginButtonAction:"), forControlEvents: UIControlEvents.TouchUpInside)
    }
    
    func loginButtonAction(button: UIButton) {
        // Define which scopes we're requesting
        // Need to be authorized on your developer dashboard at developer.uber.com
        let requestedScopes = [ RidesScope.RideWidgets, RidesScope.Profile, RidesScope.Places ]
        // Use your loginManager to login with the requested scopes, viewcontroller to present over, and completion block
        loginManager.login(requestedScopes: requestedScopes, presentingViewController: self) { (accessToken, error) -> () in
            if accessToken != nil {
                //Success! AccessToken is automatically saved in keychain
                self.showMessage("Got an AccessToken!")
            } else {
                // Error
                if let error = error {
                    self.showMessage(error.localizedDescription)
                } else {
                    self.showMessage("An Unknown Error Occured")
                }
            }
        }
    }
    
    private func showMessage(message: String) {
        let alert = UIAlertController(title: nil, message: message, preferredStyle: UIAlertControllerStyle.Alert)
        let okayAction = UIAlertAction(title: "Okay", style: UIAlertActionStyle.Default, handler: nil)
        alert.addAction(okayAction)
        self.presentViewController(alert, animated: true, completion: nil)
    }
}
