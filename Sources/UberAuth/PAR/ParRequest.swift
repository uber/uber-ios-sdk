//
//  Copyright © Uber Technologies, Inc. All rights reserved.
//


import Foundation

struct ParRequest: Request {
    
    // MARK: Private Properties
    
    private let clientID: String
    
    private let prefill: [String: String]
    
    // MARK: Initializers
    
    init(clientID: String,
         prefill: [String: String]) {
        self.clientID = clientID
        self.prefill = prefill
    }
    
    // MARK: Request
    
    typealias Response = Par
    
    var body: [String: String]? {
        [
            "client_id": clientID,
            "response_type": "code",
            "login_hint": loginHint
        ]
    }
        
    var method: HTTPMethod = .post
    
    let path: String = "/oauth/v2/par"
    
    let contentType: String = "application/x-www-form-urlencoded"
    
    // MARK: Private
    
    private var loginHint: String {
        base64EncodedString(from: prefill) ?? ""
    }
    
    private func base64EncodedString(from dict: [String: String]) -> String? {
        (try? JSONSerialization.data(withJSONObject: dict))?.base64EncodedString()
    }
}

struct Par: Codable {
    
    /// An identifier used for profile sharing
    let requestURI: String?
    
    /// Lifetime of the request_uri
    let expiresIn: Date

    enum CodingKeys: String, CodingKey {
        case requestURI = "request_uri"
        case expiresIn  = "expires_in"
    }
}
