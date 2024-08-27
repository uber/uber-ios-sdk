//
//  Parameters.swift
//  UniversalLinkExample
//
//  Copyright © 2024 Uber Technologies, Inc. All rights reserved.
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.


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
