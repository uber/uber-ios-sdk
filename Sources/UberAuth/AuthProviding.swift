//
//  Copyright © Uber Technologies, Inc. All rights reserved.
//

import AuthenticationServices
import Foundation
import UberCore

/// @mockable
public protocol AuthProviding {

    func execute(authDestination: AuthDestination,
                 prefill: Prefill?,
                 completion: @escaping (Result<Client, UberAuthError>) -> ())
    
    func handle(response url: URL) -> Bool
}
