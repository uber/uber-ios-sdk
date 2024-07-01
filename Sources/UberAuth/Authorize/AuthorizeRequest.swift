//
//  Copyright © Uber Technologies, Inc. All rights reserved.
//


import Foundation

///
/// Defines a network request conforming to the OAuth 2.0 standard authorization request
/// for the authorization code grant flow.
/// https://datatracker.ietf.org/doc/html/rfc6749#section-4.1.2
///
struct AuthorizeRequest: NetworkRequest {
    
    // MARK: Private Properties
    
    private let app: UberApp?
    private let codeChallenge: String?
    private let clientID: String
    private let redirectURI: String
    private let requestURI: String?
    private let scopes: [String]
    
    // MARK: Initializers
    
    init(app: UberApp?,
         clientID: String,
         codeChallenge: String?,
         redirectURI: String,
         requestURI: String?,
         scopes: [String] = []) {
        self.app = app
        self.clientID = clientID
        self.codeChallenge = codeChallenge
        self.redirectURI = redirectURI
        self.requestURI = requestURI
        self.scopes = scopes
    }
    
    // MARK: Request
    
    struct Response: Codable {}
    
    var parameters: [String : String]? {
        [
            "response_type": "code",
            "client_id": clientID,
            "code_challenge": codeChallenge,
            "code_challenge_method": codeChallenge != nil ? "S256" : nil,
            "redirect_uri": redirectURI,
            "request_uri": requestURI,
            "scope": scopes.joined(separator: " ")
        ]
        .compactMapValues { $0 }
    }
    
    var host: String? = nil
    
    var path: String {
        let identifier = app?.urlIdentifier ?? "universal"
        return "/oauth/v2/\(identifier)/authorize"
    }
}
