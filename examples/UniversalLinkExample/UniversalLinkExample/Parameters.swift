//
//  Copyright © Uber Technologies, Inc. All rights reserved.
//


import Foundation

enum Parameter: CaseIterable {
    case clientID
    case codeChallenge
    case codeChallengeMethod
    case redirectURI
    case resposeType
    
    var identifier: String {
        switch self {
        case .clientID: return "client_id"
        case .codeChallenge: return "code_challenge"
        case .codeChallengeMethod: return "code_challenge_method"
        case .redirectURI: return "redirect_uri"
        case .resposeType: return "response_type"
        }
    }
    
    var title: String {
        switch self {
        case .clientID: return  "Client ID [Required]"
        case .codeChallenge: return "Code Challenge [Optional]"
        case .codeChallengeMethod: return "Code Challenge Method [Optional]"
        case .redirectURI: return "Redirect URI [Required]"
        case .resposeType: return "Response Type [Required]"
        }
    }
    
    var description: String {
        switch self {
        case .clientID:
            return "The client identifier found in the developer portal. (developer.uber.com)"
        case .redirectURI:
            return "The url that should be opened after fetching the authorization code. If response_type == \"code\", this url will be called with the code appended as a query parameter. redirect_uri?code=123"
        case .resposeType:
            return "The type of identifier the Uber authentication service should respond with. `code` is the only supported option."
        case.codeChallenge:
            return "A unique identifier to be used when exchanging the auth code for an auth token. Use this to verify the /token request is coming from the same party as the original sender. This parameter is not required to make a successful /authorize request, but is required to exchange for a token on the client."
        case .codeChallengeMethod:
            return "The method used to generate the code challenge identifier."
        }
    }
    
    var isRequired: Bool {
        switch self {
        case .clientID,
                .redirectURI,
                .resposeType,
                .codeChallenge,
                .codeChallengeMethod:
            return true
        }
    }
    
    var isEditable: Bool {
        switch self {
        case .clientID,
                .redirectURI:
            return true
        case .resposeType,
                .codeChallenge,
                .codeChallengeMethod:
            return false
        }
    }
}
