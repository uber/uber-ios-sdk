//
//  Copyright © Uber Technologies, Inc. All rights reserved.
//


import Foundation
import UberCore

///
/// Defines a network request conforming to the OAuth 2.0 standard access token request
/// for the authorization code grant flow.
/// https://datatracker.ietf.org/doc/html/rfc6749#section-4.1.3
///
struct TokenRequest: NetworkRequest {
    
    let path: String
    let clientID: String
    let authorizationCode: String
    let grantType: String
    let redirectURI: String
    let codeVerifier: String
    
    init(path: String = "/oauth/v2/token",
         clientID: String,
         authorizationCode: String,
         grantType: String = "authorization_code",
         redirectURI: String,
         codeVerifier: String) {
        self.path = path
        self.clientID = clientID
        self.authorizationCode = authorizationCode
        self.grantType = grantType
        self.redirectURI = redirectURI
        self.codeVerifier = codeVerifier
    }
    
    // MARK: Request
    
    var method: HTTPMethod {
        .post
    }
    
    typealias Response = AccessToken
    
    var parameters: [String : String]? {
        [
            "code": authorizationCode,
            "client_id": clientID,
            "redirect_uri": redirectURI,
            "grant_type": grantType,
            "code_verifier": codeVerifier
        ]
    }
}
