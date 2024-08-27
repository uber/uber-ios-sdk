//
//  AuthorizeRequest.swift
//  UberAuth
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
import UberCore

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
    private let prompt: Prompt?
    private let redirectURI: String
    private let requestURI: String?
    private let scopes: [String]
    
    // MARK: Initializers
    
    init(app: UberApp?,
         clientID: String,
         codeChallenge: String?,
         prompt: Prompt? = nil,
         redirectURI: String,
         requestURI: String?,
         scopes: [String] = []) {
        self.app = app
        self.clientID = clientID
        self.codeChallenge = codeChallenge
        self.prompt = prompt
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
            "prompt": prompt?.stringValue,
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
