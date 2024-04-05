//
//  Copyright © Uber Technologies, Inc. All rights reserved.
//


import Foundation


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
    
    typealias Response = Token
    
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

///
/// The Access Token response for the authorization code grant flow as
/// defined by the OAuth 2.0 standard.
/// https://datatracker.ietf.org/doc/html/rfc6749#section-5.1
///
struct Token: Codable {
    
    let accessToken: String
    let tokenType: String
    let expiresIn: Int?
    let refreshToken: String?
    let scope: [String]
    
    enum CodingKeys: String, CodingKey {
        case accessToken = "access_token"
        case tokenType = "token_type"
        case expiresIn = "expires_in"
        case refreshToken = "refresh_token"
        case scope
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.accessToken = try container.decode(String.self, forKey: .accessToken)
        self.tokenType = try container.decode(String.self, forKey: .tokenType)
        self.expiresIn = try container.decodeIfPresent(Int.self, forKey: .expiresIn)
        self.refreshToken = try container.decodeIfPresent(String.self, forKey: .refreshToken)
        
        let scopeString = try container.decodeIfPresent(String.self, forKey: .scope)
        self.scope = (scopeString ?? "")
            .split(separator: " ")
            .map(String.init)
    }
    
    init(accessToken: String, 
         tokenType: String,
         expiresIn: Int? = nil,
         refreshToken: String? = nil,
         scope: [String] = []) {
        self.accessToken = accessToken
        self.tokenType = tokenType
        self.expiresIn = expiresIn
        self.refreshToken = refreshToken
        self.scope = scope
    }
}
