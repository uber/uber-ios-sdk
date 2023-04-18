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
    case implicitLogin(clientID: String, scopes: [UberScope], redirect: URL, requestUri: String? = nil)
    case authorizationCodeLogin(clientID: String, redirect: URL, scopes: [UberScope], state: String?, requestUri: String? = nil)
    case refresh(clientID: String, refreshToken: String)
    case par(clientID: String, loginHint: [String: String], responseType: ResponseType)

    public var method: UberHTTPMethod {
        switch self {
        case .implicitLogin,
                .authorizationCodeLogin:
            return .get
        case .refresh,
                .par:
            return .post
        }
    }

    public var host: String {
        OAuth.regionHost
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
        case .par(let clientID, let loginHint, let responseType):
            let loginHintString = base64EncodedString(from: loginHint) ?? ""
            let query = queryBuilder(
                ("client_id", clientID),
                ("response_type", responseType.rawValue),
                ("login_hint", loginHintString)
            )
            var components = URLComponents()
            components.queryItems = query
            return components.query?.data(using: String.Encoding.utf8)
        default:
            return nil
        }
    }

    static var regionHost: String {
        return "https://auth.uber.com"
    }

    public var path: String {
        switch self {
        case .implicitLogin:
            fallthrough
        case .authorizationCodeLogin:
            return "/oauth/v2/authorize"
        case .refresh:
            return "/oauth/v2/mobile/token"
        case .par:
            return "/oauth/v2/par"
        }
    }

    public var query: [URLQueryItem] {
        switch self {
        case .implicitLogin(let clientID, let scopes, let redirect, let requestUri):
            var loginQuery = baseLoginQuery(clientID, redirect: redirect, scopes: scopes)
            let additionalQueryItems = buildQueryItems([
                ("response_type", ResponseType.token.rawValue),
                ("request_uri", requestUri)
            ])
            loginQuery.append(contentsOf: additionalQueryItems)
            return loginQuery
        case .authorizationCodeLogin(let clientID, let redirect, let scopes, let state, let requestUri):
            var loginQuery = baseLoginQuery(clientID, redirect: redirect, scopes: scopes)
            let additionalQueryItems = buildQueryItems([
                ("response_type", ResponseType.code.rawValue),
                ("state", state ?? ""),
                ("request_uri", requestUri)
            ])
            loginQuery.append(contentsOf: additionalQueryItems)
            return loginQuery
        case .par:
            return queryBuilder()
        case .refresh:
            return queryBuilder()
        }
    }
    
    public var contentType: String? {
        switch self {
        case .implicitLogin,
                .authorizationCodeLogin,
                .refresh:
            return nil
        case .par:
            return "application/x-www-form-urlencoded"
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
    
    private func base64EncodedString(from dict: [String: String]) -> String? {
        (try? JSONSerialization.data(withJSONObject: dict))?.base64EncodedString()
    }
    
    private func buildQueryItems(_ items: [(String, String?)]) -> [URLQueryItem] {
        items.compactMap { pair -> [URLQueryItem]? in
            guard let value = pair.1 else {
                return nil
            }
            return self.queryBuilder((pair.0, value))
        }
        .flatMap { $0 }
    }
    
    // MARK: - ResponseType
    
    public enum ResponseType: String {
        case code
        case token
    }
}
