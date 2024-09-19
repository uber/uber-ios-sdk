//
//  TokenRequest.swift
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
    
    var body: [String : String]? {
        [
            "code": authorizationCode,
            "client_id": clientID,
            "redirect_uri": redirectURI,
            "grant_type": grantType,
            "code_verifier": codeVerifier
        ]
    }
}
