//
//  Copyright © Uber Technologies, Inc. All rights reserved.
//


import Foundation

struct AuthorizeRequest: Request {
    
    // MARK: Properties
    
    let host: String?
    let path: String
    
    // MARK: Private Properties
    
    private let codeChallenge: String
    private let clientID: String
    private let redirectURI: String
    private let requestURI: String?
    
    // MARK: Initializers
    
    init(type: LinkType,
         clientID: String,
         codeChallenge: String,
         redirectURI: String,
         requestURI: String?) {
        self.host = type.host
        self.path = type.path
        self.clientID = clientID
        self.codeChallenge = codeChallenge
        self.redirectURI = redirectURI
        self.requestURI = requestURI
    }
    
    // MARK: Request
    
    struct Response: Codable {}
    
    var parameters: [String : String]? {
        [
            "response_type": "code",
            "client_id": clientID,
            "code_challenge": codeChallenge,
            "code_challenge_method": "S256",
            "redirect_uri": redirectURI,
            "request_uri": requestURI
        ]
        .compactMapValues { $0 }
    }
    
    // MARK: LinkType
    
    enum LinkType {
        case url
        case deeplink
        
        var host: String? {
            switch self {
            case .url:
                return nil
            case .deeplink:
                return "authorize"
            }
        }
        
        var path: String {
            switch self {
            case .url:
                return "/oauth/v2/authorize"
            case .deeplink:
                return ""
            }
        }
    }
}
