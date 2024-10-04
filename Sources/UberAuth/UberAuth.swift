//
//  UberAuth.swift
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

public typealias AuthCompletion = (Result<Client, UberAuthError>) -> ()

/// @mockable
public protocol UberAuthInterface {
    
    /// Executes a single login session using the provided context
    ///
    /// - Parameters:
    ///   - context: An `AuthContext` instance providing all information needed to execute authentication
    ///   - completion: A closure to be called upon completion
    static func login(context: AuthContext, completion: @escaping AuthCompletion)
    
    
    /// Clears any saved auth information from the keychain
    /// If `currentAuthContext` exists, logs out using the stored auth context
    /// Otherwise, attempts to delete the saved auth token directly using the internal TokenManager
    static func logout()
    
    /// Attempts to extract auth information from the provided URL.
    /// This method should be called from the implemeting application's openURL function.
    ///
    /// - Parameter url: The URL that was passed into the implementing app
    /// - Returns: A boolean indicating if the URL was handled or not
    static func handle(_ url: URL) -> Bool
}


///
/// An internal protocol that translates the class -> instance methods for UberAuth
///
/// @mockable
protocol AuthManaging {
    
    func login(context: AuthContext, completion: @escaping AuthCompletion)
    
    func logout()
    
    func handle(_ url: URL) -> Bool
    
    var isLoggedIn: Bool { get }
}

/// Public interface for the uber-auth-ios library
public final class UberAuth: UberAuthInterface, AuthManaging {
    
    // MARK: Public
    
    /// Executes a single login session using the provided context
    ///
    /// - Parameters:
    ///   - context: An `AuthContext` instance providing all information needed to execute authentication
    ///   - completion: A closure to be called upon completion
    public static func login(context: AuthContext = .init(),
                             completion: @escaping AuthCompletion) {
        auth.login(
            context: context,
            completion: completion
        )
    }
    
    /// Clears any saved auth information from the keychain
    /// If `currentAuthContext` exists, logs out using the stored auth context
    /// Otherwise, attempts to delete the saved auth token directly using the internal TokenManager
    public static func logout() {
        auth.logout()
    }
    
    /// Attempts to extract auth information from the provided URL.
    /// This method should be called from the implemeting application's openURL function.
    ///
    /// - Parameter url: The URL that was passed into the implementing app
    /// - Returns: A boolean indicating if the URL was handled or not
    @discardableResult
    public static func handle(_ url: URL) -> Bool {
        auth.handle(url)
    }
    
    /// A computed property that indicates if auth information is saved in the keychain
    /// First checks for saved token information using the current auth provider
    /// If no auth provider exists, falls back to the default token identifier
    public static var isLoggedIn: Bool {
        auth.isLoggedIn
    }
    
    // MARK: Internal
    // MARK: AuthManaging
    
    init(currentContext: AuthContext? = nil,
         tokenManager: TokenManaging = TokenManager()) {
        self.currentContext = currentContext
        self.tokenManager = tokenManager
    }
    
    func login(context: AuthContext = .init(),
               completion: @escaping AuthCompletion) {
        context.authProvider.execute(
            authDestination: context.authDestination,
            prefill: context.prefill,
            completion: completion
        )
        currentContext = context
    }
    
    func logout() {
        guard let currentContext else {
            tokenManager.deleteToken(identifier: TokenManager.defaultAccessTokenIdentifier)
            return
        }
        currentContext.authProvider.logout()
        self.currentContext = nil
    }
    
    func handle(_ url: URL) -> Bool {
        guard let currentContext else {
            return false
        }
        return currentContext.authProvider.handle(response: url)
    }
    
    var isLoggedIn: Bool {
        currentContext?.authProvider.isLoggedIn ?? (tokenManager.getToken(identifier: TokenManager.defaultAccessTokenIdentifier) != nil)
    }
    
    private static let auth = UberAuth()
    
    var currentContext: AuthContext?
    
    var tokenManager: TokenManaging = TokenManager()
}

