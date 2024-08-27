//
//  LoginButton.swift
//  UberAuth
//
//  Copyright © 2024 Uber Technologies, Inc. All rights reserved.
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


import Foundation
import UberCore
import UIKit


/// 
/// A protocol to respond to Uber LoginButton events
///
public protocol LoginButtonDelegate: AnyObject {
    
    /// 
    /// The login button attempted to log out
    ///
    /// - Parameters:
    ///   - button: The LoginButton instance that attempted logout
    ///   - success: A bollean indicating whether or not the logout was successful
    func loginButton(_ button: LoginButton, 
                     didLogoutWithSuccess success: Bool)
    
    
    /// 
    /// The login button completed authentication
    ///
    /// - Parameters:
    ///   - button: The LoginButton instance that completed authentication
    ///   - result: A Result containing the authentication response. If successful, contains the Client object returned from the UberAuth authenticate function. If failed, contains an UberAuth error indicating the failure reason.
    func loginButton(_ button: LoginButton,
                     didCompleteLoginWithResult result: Result<Client, UberAuthError>)
}

///
/// A protocol to provide content for the Uber LoginButton
///
public protocol LoginButtonDataSource: AnyObject {
    
    /// 
    /// Provides an optional AuthContext to be used during authentication
    ///
    /// - Parameter button: The LoginButton instance requesting the information
    /// - Returns: An optional AuthContext instance
    func authContext(_ button: LoginButton) -> AuthContext
}

public final class LoginButton: UberButton {
     
    // MARK: Public Properties
    
    /// The LoginButtonDelegate for this button
    public weak var delegate: LoginButtonDelegate?
    
    public weak var dataSource: LoginButtonDataSource?
    
    // MARK: Private Properties
    
    private var buttonState: State {
        tokenManager.getToken(
            identifier: Constants.tokenIdentifier
        ) != nil ? .loggedIn : .loggedOut
    }
    
    private let tokenManager: TokenManaging
    
    // MARK: Initializers

    public override init(frame: CGRect) {
        self.tokenManager = TokenManager()
        super.init(frame: frame)
        configure()
    }
    
    public required init?(coder: NSCoder) {
        self.tokenManager = TokenManager()
        super.init(coder: coder)
        configure()
    }
    
    public init(tokenManager: TokenManaging = TokenManager()) {
        self.tokenManager = tokenManager
        super.init(frame: .zero)
        configure()
    }
        
    // MARK: UberButton
    
    public override var title: NSAttributedString? {
        NSAttributedString(string: buttonState.title)
    }
    
    override public var image: UIImage? {
        UIImage(
            named: "uber_logo_white",
            in: .resource(for: LoginButton.self),
            compatibleWith: nil
        )?.withRenderingMode(.alwaysTemplate)
    }
        
    // MARK: Private
    
    private func configure() {
        addTarget(self, action: #selector(buttonTapped), for: .touchUpInside)
    }
    
    @objc private func buttonTapped(_ sender: UIButton) {
        switch buttonState {
        case .loggedIn:
            logout()
        case .loggedOut:
            login()
        }
    }
    
    private func login() {
        let defaultContext = AuthContext(
            authProvider: .authorizationCode(
                shouldExchangeAuthCode: true
            )
        )
        let context = dataSource?.authContext(self) ?? defaultContext
        UberAuth.login(context: context) { [weak self] result in
            guard let self else { return }
            delegate?.loginButton(self, didCompleteLoginWithResult: result)
            update()
        }
    }
    
    private func logout() {
        // TODO: Implement UberAuth.logout()
        tokenManager.deleteToken(identifier: Constants.tokenIdentifier)
        update()
    }
    
    // MARK: State
    
    enum State {
        case loggedIn
        case loggedOut
        
        var title: String {
            switch self {
            case .loggedIn:
                return NSLocalizedString(
                    "Sign Out",
                    bundle: .resource(for: LoginButton.self),
                    comment: "Login Button Sign Out Description"
                )
                .uppercased()
            case .loggedOut:
                return NSLocalizedString(
                    "Sign In",
                    bundle: .resource(for: LoginButton.self),
                    comment: "Login Button Sign In Description"
                )
                .uppercased()
            }
        }
    }
    
    // MARK: Constants
    
    private enum Constants {
        static let tokenIdentifier: String = TokenManager.defaultAccessTokenIdentifier
    }
}

