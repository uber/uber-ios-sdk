//
//  OAuthEndpoint.swift
//  UberRides
//
//  Copyright © 2017 Uber Technologies, Inc. All rights reserved.
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

/**
 OAuth endpoints.

 - ImplicitLogin: Used to login user and request access to specified scopes via implicit grant.
 - AuthorizationCodeLogin: Used to login user and request access to specified scopes via authorization code grant.
 - Refresh: Used to refresh an access token that has been aquired via SSO
 */
public enum OAuth: APIEndpoint {
    case implicitLogin(clientID: String, scopes: [UberScope], redirect: URL)
    case authorizationCodeLogin(clientID: String, redirect: URL, scopes: [UberScope], state: String?)
    case refresh(clientID: String, refreshToken: String)

    public var method: UberHTTPMethod {
        switch self {
        case .implicitLogin:
            fallthrough
        case .authorizationCodeLogin:
            return .get
        case .refresh:
            return .post
        }
    }

    public var host: String {
        return OAuth.regionHost
    }

    public var body: Data? {
        switch self {
        case .refresh(let clientID, let refreshToken):
            let query = queryBuilder(
                ("client_id", clientID),
                ("refresh_token", refreshToken)
            )
            var components = URLComponents()
            components.queryItems = query
            return components.query?.data(using: String.Encoding.utf8)
        default:
            return nil
        }
    }

    static var regionHost: String {
        return "https://login.uber.com"
    }

    public var path: String {
        switch self {
        case .implicitLogin:
            fallthrough
        case .authorizationCodeLogin:
            return "/oauth/v2/authorize"
        case .refresh:
            return "/oauth/v2/mobile/token"
        }
    }

    public var query: [URLQueryItem] {
        switch self {
        case .implicitLogin(let clientID, let scopes, let redirect):
            var loginQuery = baseLoginQuery(clientID, redirect: redirect, scopes: scopes)
            let additionalQueryItems = queryBuilder(("response_type", "token"))

            loginQuery.append(contentsOf: additionalQueryItems)
            return loginQuery
        case .authorizationCodeLogin(let clientID, let redirect, let scopes, let state):
            var loginQuery = baseLoginQuery(clientID, redirect: redirect, scopes: scopes)
            let additionalQueryItems = queryBuilder(("response_type", "code"),
                                                    ("state", state ?? ""))
            loginQuery.append(contentsOf: additionalQueryItems)
            return loginQuery
        case .refresh:
            return queryBuilder()
        }
    }

    func baseLoginQuery(_ clientID: String, redirect: URL, scopes: [UberScope]) -> [URLQueryItem] {

        return queryBuilder(
            ("scope", scopes.toUberScopeString()),
            ("client_id", clientID),
            ("redirect_uri", redirect.absoluteString),
            ("signup_params", createSignupParameters()))
    }

    private func createSignupParameters() -> String {
        let signupParameters = [ "redirect_to_login" : true ]
        do {
            let json = try JSONSerialization.data(withJSONObject: signupParameters, options: JSONSerialization.WritingOptions(rawValue: 0))
            return json.base64EncodedString(options: NSData.Base64EncodingOptions.lineLength76Characters)
        } catch _ as NSError {
            return ""
        }
    }
}
