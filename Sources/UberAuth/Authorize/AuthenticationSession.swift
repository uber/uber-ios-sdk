//
//  Copyright © Uber Technologies, Inc. All rights reserved.
//


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
                        completion(.failure(UberAuthError.invalidAuthCode))
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
