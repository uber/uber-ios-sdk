//
//  Copyright © Uber Technologies, Inc. All rights reserved.
//


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
        tokenManager.getToken() != nil ? .loggedIn : .loggedOut
    }
    
    private let tokenManager = TokenManager()
    
    // MARK: Initializers

    public override init(frame: CGRect) {
        super.init(frame: frame)
        configure()
    }
    
    public required init?(coder: NSCoder) {
        super.init(coder: coder)
        configure()
    }
        
    // MARK: UberButton
    
    override public var title: String {
        buttonState.title
    }
    
    override public var image: UIImage? {
        UIImage(
            named: "uber_logo_white",
            in: .module,
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
        tokenManager.deleteToken()
        update()
    }
    
    enum State {
        case loggedIn
        case loggedOut
        
        var title: String {
            switch self {
            case .loggedIn:
                return NSLocalizedString(
                    "Sign Out",
                    bundle: .module,
                    comment: "Login Button Sign Out Description"
                )
                .uppercased()
            case .loggedOut:
                return NSLocalizedString(
                    "Sign In",
                    bundle: .module,
                    comment: "Login Button Sign In Description"
                )
                .uppercased()
            }
        }
    }
}

