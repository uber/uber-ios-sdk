//
//  ParRequest.swift
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

struct ParRequest: NetworkRequest {
    
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
