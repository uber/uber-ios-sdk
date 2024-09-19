//
//  AuthenticationSession.swift
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


import AuthenticationServices
import Foundation

/// @mockable
protocol AuthenticationSessioning {
    init(anchor: ASPresentationAnchor,
         callbackURLScheme: String,
         url: URL,
         completion: @escaping AuthCompletion)
    
    func start()
}

final class AuthenticationSession: AuthenticationSessioning {
    
    private let authSession: ASWebAuthenticationSession
    
    private let presentationContextProvider: ASWebAuthenticationPresentationContextProviding?
    
    init(anchor: ASPresentationAnchor = ASPresentationAnchor(),
         callbackURLScheme: String, 
         url: URL,
         completion: @escaping AuthCompletion) {
        self.presentationContextProvider = AuthPresentationContextProvider(anchor: anchor)
        self.authSession = ASWebAuthenticationSession(
            url: url,
            callbackURLScheme: callbackURLScheme,
            completionHandler: { url, error in
                switch (url, error) {
                case (_, .some(let error)):
                    completion(.failure(UberAuthError(error: error)))
                case (.none, _):
                    completion(.failure(UberAuthError.invalidAuthCode))
                case (.some(let url), _):
                    guard let code = Self.parse(url: url) else {
                        completion(.failure(Self.parseError(url: url)))
                        return
                    }
                    completion(.success(.init(authorizationCode: code)))
                }
            }
        )
        self.authSession.presentationContextProvider = presentationContextProvider
    }
    
    func start() {
        if #available(iOS 13.4, *) {
            guard authSession.canStart else {
                return
            }
        }
        authSession.start()
    }
    
    
    /// Attempts to get the authorization code `code` from the query parameters of the provided url
    /// - Parameter url: The URL containing the response code
    /// - Returns: An optional string containing the autorization code's value
    private static func parse(url: URL) -> String? {
        guard let components = URLComponents(url: url, resolvingAgainstBaseURL: false),
              let codeParameter = components.queryItems?.first(where: { $0.name == "code" }) else {
            return nil
        }
        return codeParameter.value
    }
    
    private static func parseError(url: URL) -> UberAuthError {
        guard let components = URLComponents(url: url, resolvingAgainstBaseURL: false),
              let errorParameter = components.queryItems?.first(where: { $0.name == "error" })?.value else {
            return .invalidAuthCode
        }
        switch OAuthError(rawValue: errorParameter) {
        case .some(let error):
            return UberAuthError.oAuth(error)
        case .none:
            return .invalidAuthCode
        }
    }
}

final class AuthPresentationContextProvider: NSObject, ASWebAuthenticationPresentationContextProviding {
    
    private weak var anchor: ASPresentationAnchor?
    
    init(anchor: ASPresentationAnchor) {
        self.anchor = anchor
    }
    
    func presentationAnchor(for session: ASWebAuthenticationSession) -> ASPresentationAnchor {
        anchor ?? UIWindow()
    }
}
