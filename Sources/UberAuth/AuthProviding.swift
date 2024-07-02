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

extension AuthProviding where Self == AuthorizationCodeAuthProvider {
    
    public static func authorizationCode(presentationAnchor: ASPresentationAnchor = .init(),
                                         scopes: [String] = AuthorizationCodeAuthProvider.defaultScopes,
                                         shouldExchangeAuthCode: Bool = true,
                                         prompt: Prompt? = nil) -> Self {
        AuthorizationCodeAuthProvider(
            presentationAnchor: presentationAnchor,
            scopes: scopes,
            shouldExchangeAuthCode: shouldExchangeAuthCode,
            prompt: prompt
        )
    }
}
