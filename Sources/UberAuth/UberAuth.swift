//
//  Copyright © Uber Technologies, Inc. All rights reserved.
//


import Foundation

/// Public interface for the uber-auth-ios library
public final class UberAuth {
    
    // MARK: Public
    
    /// Attempts to extract auth information from the provided URL.
    /// This method should be called from the implemeting application's openURL function.
    ///
    /// - Parameter url: The URL that was passed into the implementing app
    /// - Returns: A boolean indicating if the URL was handled or not
    @discardableResult
    public static func handle(_ url: URL) -> Bool {
        manager.handle(url)
    }
 
    public static func login(context: AuthContext = .init(),
                             completion: @escaping AuthCompletion) {
        manager.login(context: context, completion: completion)
    }
    
    // MARK: Internal
        
    private static let manager: AuthManaging = AuthManager()
}

