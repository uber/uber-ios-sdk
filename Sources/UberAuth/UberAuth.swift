//
//  Copyright © Uber Technologies, Inc. All rights reserved.
//


import Foundation

public typealias AuthCompletion = (Result<Client, UberAuthError>) -> ()

/// @mockable
protocol AuthManaging {
    
    func login(context: AuthContext, completion: @escaping AuthCompletion)
    
    func handle(_ url: URL) -> Bool
}

/// Public interface for the uber-auth-ios library
public final class UberAuth: AuthManaging {
    
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
    
    /// Attempts to extract auth information from the provided URL.
    /// This method should be called from the implemeting application's openURL function.
    ///
    /// - Parameter url: The URL that was passed into the implementing app
    /// - Returns: A boolean indicating if the URL was handled or not
    @discardableResult
    public static func handle(_ url: URL) -> Bool {
        auth.handle(url)
    }
    
    // MARK: Internal
    // MARK: AuthManaging
    
    func login(context: AuthContext = .init(),
               completion: @escaping AuthCompletion) {
        context.authProvider.execute(
            authDestination: context.authDestination,
            prefill: context.prefill,
            completion: completion
        )
        currentContext = context
    }
    
    func handle(_ url: URL) -> Bool {
        guard let currentContext else {
            return false
        }
        return currentContext.authProvider.handle(response: url)
    }
    
    private static let auth = UberAuth()
    
    private var currentContext: AuthContext?
}

