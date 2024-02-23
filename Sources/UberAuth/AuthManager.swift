//
//  Copyright © Uber Technologies, Inc. All rights reserved.
//


import Foundation
import UIKit

public typealias AuthCompletion = (Result<Client, UberAuthError>) -> ()

/// @mockable
protocol AuthManaging {
    
    func login(context: AuthContext, completion: @escaping AuthCompletion)
    
    func handle(_ url: URL) -> Bool
}

final class AuthManager: AuthManaging {
    
    private var currentContext: AuthContext?
    
    init() {}
    
    // MARK: LoginManaging
    
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
    
}
