//
//  Copyright © Uber Technologies, Inc. All rights reserved.
//

import AuthenticationServices
import Foundation
import UberCore

public final class AuthorizationCodeAuthProvider: AuthProviding {
    
    // MARK: Public Properties
    
    public let clientID: String
    
    public let redirectURI: String
    
    public typealias Completion = (Result<Client, UberAuthError>) -> Void
    
    public static let defaultScopes = ["profile"]

    // MARK: Private Properties

    private let shouldExchangeAuthCode: Bool
    
    var currentSession: AuthenticationSessioning?
    
    private let presentationAnchor: ASPresentationAnchor
    
    private let pkce = PKCE()
    
    private var completion: Completion?
    
    // MARK: Initializers
    
    public init(presentationAnchor: ASPresentationAnchor = .init(),
                scopes: [String] = AuthorizationCodeAuthProvider.defaultScopes,
                shouldExchangeAuthCode: Bool = true,
                configurationProvider: ConfigurationProviding = PlistParser(plistName: "Info")) {
                
        guard let clientID: String = configurationProvider.clientID else {
            preconditionFailure("No clientID specified in Info.plist")
        }
        
        guard let redirectURI: String = configurationProvider.redirectURI else {
            preconditionFailure("No redirectURI specified in Info.plist")
        }
        
        self.redirectURI = redirectURI
        self.clientID = clientID
        self.presentationAnchor = presentationAnchor
        self.shouldExchangeAuthCode = shouldExchangeAuthCode
    }
    
    // MARK: AuthProviding
    
    public func execute(authDestination: AuthDestination,
                        prefill: Prefill?,
                        completion: @escaping Completion) {
        self.completion = completion
        
        // TODO: Implement PAR
        
        executeLogin(
            authDestination: authDestination,
            requestURI: nil,
            completion: completion
        )
    }
    
    public func handle(response url: URL) -> Bool {
        // TODO: Implement
        true
    }
    
    // MARK: - Private
    
    private func executeLogin(authDestination: AuthDestination,
                              requestURI: String?,
                              completion: @escaping Completion) {
        switch authDestination {
        case .inApp:
            executeInAppLogin(
                requestURI: requestURI,
                completion: completion
            )
        case .native:
            // TODO: Implement
            break
        }
    }
    
    /// Performs login using an embedded browser within the third party client.
    /// - Parameters:
    ///   - completion: A closure to handle the login result
    private func executeInAppLogin(requestURI: String?,
                                   completion: @escaping Completion) {
        
        // Only execute one authentication session at a time
        guard currentSession == nil else {
            completion(.failure(.existingAuthSession))
            return
        }
        
        let request = AuthorizeRequest(
            type: .url,
            clientID: clientID,
            codeChallenge: pkce.codeChallenge,
            redirectURI: redirectURI,
            requestURI: requestURI
        )
        
        guard let url = request.url(baseUrl: Constants.baseUrl) else {
            completion(.failure(.invalidRequest("Invalid base URL")))
            return
        }
        
        guard let callbackURL = URL(string: redirectURI),
              let callbackURLScheme = callbackURL.scheme else {
            completion(.failure(.invalidRequest("Invalid redirect URI")))
            return
        }
        
        currentSession = AuthenticationSession(
            anchor: presentationAnchor,
            callbackURLScheme: callbackURLScheme,
            url: url,
            completion: { result in
                if self.shouldExchangeAuthCode,
                   case .success(let client) = result,
                   let code = client.authorizationCode {
                    // TODO: Exchange auth code here
                    self.currentSession = nil
                    return
                }
                completion(result)
                self.currentSession = nil
            }
        )
        
        currentSession?.start()
    }
        
    // MARK: Constants
    
    private enum Constants {
        static let clientIDKey = "ClientID"
        static let redirectURI = "RedirectURI"
        static let baseUrl = "https://auth.uber.com/v2"
    }
}
