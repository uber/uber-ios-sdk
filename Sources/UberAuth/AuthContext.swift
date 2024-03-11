//
//  Copyright © Uber Technologies, Inc. All rights reserved.
//


import Foundation
import UberCore

public class AuthContext {
    
    public let authDestination: AuthDestination
    
    public let authProvider: AuthProviding
    
    public let prefill: Prefill?
    
    public init(authDestination: AuthDestination = .native(),
                authProvider: AuthProviding = AuthorizationCodeAuthProvider(),
                prefill: Prefill? = nil) {
        self.authDestination = authDestination
        self.authProvider = authProvider
        self.prefill = prefill
    }
}
