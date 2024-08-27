//
//  UberAuthError.swift
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
import UberCore
import Foundation

public enum UberAuthError: Error {
    // The user cancelled the auth flow
    case cancelled
    
    // The application failed to open the Uber client app
    case couldNotOpenApp(UberApp)
    
    // An existing authentication session is in progress
    case existingAuthSession
    
    // The auth code was not found or is malformed
    case invalidAuthCode
    
    // The response url could not be parsed
    case invalidResponse
    
    // Failed to build the auth request
    case invalidRequest(String)
    
    // An OAuth standard error occurred
    case oAuth(OAuthError)
    
    // An unknown error occurred
    case other(Error)
    
    // An error occurred when making a network request
    case serviceError
}

// MARK: - LocalizedError

extension UberAuthError: LocalizedError {
    
    public var errorDescription: String? {
        switch self {
        case .cancelled:
            return "The user cancelled the auth flow"
        case .couldNotOpenApp(let uberApp):
            return "The application failed to open the Uber client app: \(uberApp)"
        case .existingAuthSession:
            return "An existing authentication session is in progress"
        case .invalidAuthCode:
            return "The auth code was not found or is malformed"
        case .oAuth(let error):
            return error.errorDescription
        case .invalidResponse:
            return "The response url could not be parsed"
        case .invalidRequest(let details):
            return "Failed to build the auth request: \(details)"
        case .other(let error):
            return "An unknown error occurred: \(error)"
        case .serviceError:
            return "An error occurred when making a network request"
        }
    }
}

// MARK: - HTTPURLResponse

extension UberAuthError {
    
    init?(_ response: HTTPURLResponse) {
        
        // Only return errors for failed status codes
        switch response.statusCode {
        case (0 ..< 300):
            return nil
        default:
            break
        }
        
        guard let url = response.url else {
            self = .oAuth(.invalidRequest)
            return
        }
        
        guard let components = URLComponents(url: url, resolvingAgainstBaseURL: false) else {
            self = .oAuth(.invalidRequest)
            return
        }
        
        // Check for error url query parameter
        guard let queryItems = components.queryItems,
              let errorString = queryItems.first(where: { $0.name == "error" })?.value,
              let error = OAuthError(rawValue: errorString) else {
            self = .oAuth(.invalidRequest)
            return
        }
        
        self = .init(error: error)
    }
}

// MARK: - Error Convenience Initializer

extension UberAuthError {
    
    init(error: Error) {
        switch error {
        case let authError as ASWebAuthenticationSessionError:
            switch authError.code {
            case .canceledLogin:
                self = .cancelled
            default:
                self = .other(error)
            }
        case let oauthError as OAuthError:
            self = .oAuth(oauthError)
        default:
            self = .other(error)
        }
    }
    
    init(httpStatusCode: Int) {
        self = .init(
            error: URLError(
                URLError.Code(
                    rawValue: httpStatusCode
                )
            )
        )
    }
}

// MARK: Equatable

extension UberAuthError: Equatable {
    
    public static func == (lhs: UberAuthError, rhs: UberAuthError) -> Bool {
        guard let lhsDescription = lhs.errorDescription,
           let rhsDescription = rhs.errorDescription else {
            return false
        }
        return lhsDescription == rhsDescription
    }
}
