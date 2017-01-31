//
//  OAuthViewController.swift
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

// MARK: View Controller Lifecycle

// View controller to users to enter credentials for OAuth.
@objc(UBSDKOAuthViewController)
class OAuthViewController: UIViewController {
    
    var hasLoaded = false
    var loginView: LoginView
    
    /**
     Initializes the web view controller with the necessary information.
     
     - parameter loginAuthenticator: the login authentication process to use
     
     - returns: An initialized OAuthWebViewController
    */
    @objc init(loginAuthenticator: LoginViewAuthenticator) {
        loginView = LoginView(loginAuthenticator: loginAuthenticator)
        super.init(nibName: nil, bundle: nil)
    }
    
    @objc required init?(coder aDecoder: NSCoder) {
        fatalError("initWithCoder: is not supported")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.edgesForExtendedLayout = UIRectEdge()
        self.view.addSubview(loginView)
        self.setupLoginView()
        // Set up navigation item
        let cancelButton = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(cancel))
        navigationItem.leftBarButtonItem = cancelButton
        navigationItem.title = LocalizationUtil.localizedString(forKey: "Sign in with Uber", comment: "Title of navigation bar during OAuth")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if !hasLoaded {
            self.loginView.load()
        }
    }
    
    func cancel() {
        self.loginView.loginAuthenticator.loginCompletion?(nil, RidesAuthenticationErrorFactory.errorForType(ridesAuthenticationErrorType: .userCancelled))
        dismiss(animated: true, completion: nil)
    }
    
    //MARK: View Setup
    
    func setupLoginView() {
        self.loginView.translatesAutoresizingMaskIntoConstraints = false
        
        let views = ["loginView": self.loginView]
        let horizontalConstraints = NSLayoutConstraint.constraints(withVisualFormat: "H:|[loginView]|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: views)
        let verticalConstraints = NSLayoutConstraint.constraints(withVisualFormat: "V:|[loginView]|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: views)
        
        self.view.addConstraints(horizontalConstraints)
        self.view.addConstraints(verticalConstraints)
    }
}
