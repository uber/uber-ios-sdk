//
//  Copyright © Uber Technologies, Inc. All rights reserved.
//

import AuthenticationServices
import Foundation
import UberCore

public final class AuthorizationCodeAuthProvider: AuthProviding {
    
    // MARK: Initializers
    
    public init() {}
    
    // MARK: AutoProviding
    
    public func execute(authDestination: AuthDestination,
                        prefill: Prefill?,
                        completion: @escaping AuthCompletion) {
        // TODO: Implement
    }
    
    public func handle(response url: URL) -> Bool {
        // TODO: Implement
        true
    }
}
