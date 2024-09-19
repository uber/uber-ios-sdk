//
//  AuthorizationCodeAuthProvider.swift
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

import AuthenticationServices
import Foundation
import UberCore

public final class AuthorizationCodeAuthProvider: AuthProviding {
    
    // MARK: Public Properties
    
    public let clientID: String
    
    public let redirectURI: String
    
    public typealias Completion = (Result<Client, UberAuthError>) -> Void
        
    public static let defaultScopes = ["profile"]

    // MARK: Internal Properties
    
    var currentSession: AuthenticationSessioning?
    
    typealias AuthenticationSessionBuilder = (ASPresentationAnchor, String, URL, AuthCompletion) -> (AuthenticationSessioning)
    
    // MARK: Private Properties

    private let applicationLauncher: ApplicationLaunching
    
    private let authenticationSessionBuilder: AuthenticationSessionBuilder?
    
    private var completion: Completion?
    
    private let configurationProvider: ConfigurationProviding
    
    private let pkce = PKCE()
    
    private let presentationAnchor: ASPresentationAnchor
    
    private let responseParser: AuthorizationCodeResponseParsing
    
    private let shouldExchangeAuthCode: Bool
    
    private let networkProvider: NetworkProviding
    
    private let tokenManager: TokenManaging
    
    private let scopes: [String]
    
    private let prompt: Prompt?
    
    // MARK: Initializers
    
    public init(presentationAnchor: ASPresentationAnchor = .init(),
                scopes: [String] = AuthorizationCodeAuthProvider.defaultScopes,
                shouldExchangeAuthCode: Bool = false,
                prompt: Prompt? = nil) {
        self.configurationProvider = ConfigurationProvider()
        self.applicationLauncher = UIApplication.shared
        self.authenticationSessionBuilder = nil
        self.clientID = configurationProvider.clientID
        self.presentationAnchor = presentationAnchor
        self.redirectURI = configurationProvider.redirectURI
        self.responseParser = AuthorizationCodeResponseParser()
        self.shouldExchangeAuthCode = shouldExchangeAuthCode
        self.networkProvider = NetworkProvider(baseUrl: Constants.baseUrl)
        self.tokenManager = TokenManager()
        self.scopes = scopes
        self.prompt = prompt
    }
    
    init(presentationAnchor: ASPresentationAnchor = .init(),
         authenticationSessionBuilder: AuthenticationSessionBuilder? = nil,
         scopes: [String] = AuthorizationCodeAuthProvider.defaultScopes,
         prompt: Prompt? = nil,
         shouldExchangeAuthCode: Bool = false,
         configurationProvider: ConfigurationProviding = ConfigurationProvider(),
         applicationLauncher: ApplicationLaunching = UIApplication.shared,
         responseParser: AuthorizationCodeResponseParsing = AuthorizationCodeResponseParser(),
         networkProvider: NetworkProviding = NetworkProvider(baseUrl: Constants.baseUrl),
         tokenManager: TokenManaging = TokenManager()) {
        
        self.applicationLauncher = applicationLauncher
        self.authenticationSessionBuilder = authenticationSessionBuilder
        self.clientID = configurationProvider.clientID
        self.configurationProvider = configurationProvider
        self.presentationAnchor = presentationAnchor
        self.redirectURI = configurationProvider.redirectURI
        self.responseParser = responseParser
        self.shouldExchangeAuthCode = shouldExchangeAuthCode
        self.networkProvider = networkProvider
        self.tokenManager = tokenManager
        self.scopes = scopes
        self.prompt = prompt
    }
    
    // MARK: AuthProviding
    
    public func execute(authDestination: AuthDestination,
                        prefill: Prefill? = nil,
                        completion: @escaping Completion) {
        
        // Completion is stored for native handle callback
        // Upon completion, intercept result and exchange for token if enabled
        let authCompletion: Completion = { [weak self] result in
            guard let self else { return }
            
            switch result {
            case .success(let client):
                // Exchange auth code for token if needed
                if shouldExchangeAuthCode,
                   let code = client.authorizationCode {
                    exchange(code: code, completion: completion)
                    self.completion = nil
                    return
                }
            case .failure:
                break
            }
            
            completion(result)
            self.completion = nil
        }

        executePar(
            prefill: prefill,
            completion: { [weak self] requestURI in
                self?.executeLogin(
                    authDestination: authDestination,
                    requestURI: requestURI,
                    completion: authCompletion
                )
            }
        )
        
        self.completion = authCompletion
    }
    
    public func logout() -> Bool {
        tokenManager.deleteToken(identifier: TokenManager.defaultAccessTokenIdentifier)
    }
    
    public func handle(response url: URL) -> Bool {
        guard responseParser.isValidResponse(url: url, matching: redirectURI) else {
            return false
        }

        let result = responseParser(url: url)
        completion?(result)
        
        return true
    }
    
    public var isLoggedIn: Bool {
        tokenManager.getToken(identifier: TokenManager.defaultAccessTokenIdentifier) != nil
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
        case .native(let appPriority):
            executeNativeLogin(
                appPriority: appPriority,
                requestURI: requestURI,
                completion: completion
            )
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
            app: nil,
            clientID: clientID,
            codeChallenge: shouldExchangeAuthCode ? pkce.codeChallenge : nil,
            prompt: prompt,
            redirectURI: redirectURI,
            requestURI: requestURI,
            scopes: scopes
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
        
        currentSession = authenticationSessionBuilder?(ASPresentationAnchor(), callbackURLScheme, url, completion) ??
            AuthenticationSession(
                anchor: presentationAnchor,
                callbackURLScheme: callbackURLScheme,
                url: url,
                completion: { [weak self] result in
                    guard let self else { return }
                    completion(result)
                    currentSession = nil
                }
            )
        
        currentSession?.start()
    }
        
    /// Performs login using one of the native Uber applications if available.
    ///
    /// There are three possible destinations for auth through this method:
    ///     1. The native Uber app
    ///     2. The OS supplied Safari browser
    ///     3. In app auth through ASWebAuthenticationSession
    ///
    /// This method will run through the desired native app destinations supplied in `appPriority`.
    /// For each one it will:
    ///     * Use the configuration provider to determine if the app is installed, using UIApplication's openUrl.
    ///       If the app's scheme has not been registered in the Info.plist and is not queryable it will default to true
    ///       and continue with the auth flow. If it is registered but not installed, we will continue to the next app.
    ///     * Build a universal link specific to the current app destination
    ///     * Attempt to launch the app using the `applicationLauncher`. If the app is installed, the native app
    ///       should be launched (1), if not the OS supplied browser will be launched (2)
    ///
    /// If all app destinations have been exhausted and no url has been launched we fall back to in app auth (3)
    ///
    /// - Parameters:
    ///   - appPriority: An ordered list of Uber applications to use to perform login
    ///   - completion: A closure to handle the login result
    private func executeNativeLogin(appPriority: [UberApp],
                                    requestURI: String?,
                                    completion: @escaping Completion) {
     
        var nativeLaunched = false
        
        // Executes the asynchronous operation `launch` serially for each app in appPriority
        // Stops the execution after the first app is successfully launched
        AsyncDispatcher.exec(
            for: appPriority.map { ($0, requestURI) },
            with: { _ in },
            asyncMethod: launch(context:completion:),
            continue: { launched in
                if launched { nativeLaunched = true }
                return !launched // Continue only if app was not launched
            },
            finally: { [weak self] in
                guard !nativeLaunched else {
                    return
                }
                
                // If no native app was launched, fall back to in app login
                self?.executeInAppLogin(
                    requestURI: requestURI,
                    completion: completion
                )
            }
        )
    }
    
    /// Attempts to launch a native app with an SSO universal link.
    /// Calls a closure with a boolean indicating if the application was successfully opened.
    ///
    /// - Parameters:
    ///   - context: A tuple of the destination app and an optional requestURI
    ///   - completion: An optional closure indicating whether or not the app was launched
    private func launch(context: (app: UberApp, requestURI: String?),
                        completion: ((Bool) -> Void)?) {
        let (app, requestURI) = context
        guard configurationProvider.isInstalled(
            app: app,
            defaultIfUnregistered: true
        ) else {
            completion?(false)
            return
        }
        
        // .login not supported for native auth
        var prompt = prompt
        prompt?.remove(.login)
        
        let request = AuthorizeRequest(
            app: app,
            clientID: clientID,
            codeChallenge: shouldExchangeAuthCode ? pkce.codeChallenge : nil,
            prompt: prompt,
            redirectURI: redirectURI,
            requestURI: requestURI,
            scopes: scopes
        )
        
        guard let url = request.url(baseUrl: Constants.baseUrl) else {
            completion?(false)
            return
        }
        
        DispatchQueue.main.async {
            self.applicationLauncher.launch(
                url,
                completion: { opened in
                    completion?(opened)
                }
            )
        }
    }

    private func executePar(prefill: Prefill?,
                            completion: @escaping (_ requestURI: String?) -> Void) {
      guard let prefill else {
          completion(nil)
          return
      }

      let request = ParRequest(
          clientID: clientID,
          prefill: prefill.dictValue
      )

      networkProvider.execute(
          request: request,
          completion: { result in
              switch result {
              case .success(let response):
                  completion(response.requestURI)
              case .failure:
                  completion(nil)
              }
          }
       )
    }
    
    // MARK: Token Exchange
    
    /// Makes a request to the /token endpoing to exchange the authorization code
    /// for an access token.
    /// - Parameter code: The authorization code to exchange
    private func exchange(code: String, completion: @escaping Completion) {
        let request = TokenRequest(
            clientID: clientID,
            authorizationCode: code,
            redirectURI: redirectURI,
            codeVerifier: pkce.codeVerifier
        )
        
        networkProvider.execute(
            request: request,
            completion: { [weak self] result in
                switch result {
                case .success(let response):
                    let client = Client(tokenResponse: response)
                    if let accessToken = client.accessToken {
                        self?.tokenManager.saveToken(
                            accessToken,
                            identifier: TokenManager.defaultAccessTokenIdentifier
                        )
                    }
                    completion(.success(client))
                case .failure(let error):
                    completion(.failure(error))
                }
            }
        )
    }
    
    // MARK: Constants
    
    private enum Constants {
        static let clientIDKey = "ClientID"
        static let redirectURI = "RedirectURI"
        static let baseUrl = "https://auth.uber.com/v2"
    }
}


fileprivate extension Client {
    
    init(tokenResponse: TokenRequest.Response) {
        self = Client(
            authorizationCode: nil,
            accessToken: AccessToken(
                tokenString: tokenResponse.tokenString,
                refreshToken: tokenResponse.refreshToken,
                tokenType: tokenResponse.tokenType,
                expiresIn: tokenResponse.expiresIn,
                scope: tokenResponse.scope
            )
        )
    }
}
