//
//  Copyright © Uber Technologies, Inc. All rights reserved.
//


import AuthenticationServices
import Foundation

public enum UberAuthError: Error {
    // The user cancelled the auth flow
    case cancelled
    
    // The application failed to open the Uber client app
    case couldNotOpenApp(UberApp)
    
    // The auth code was not found or is malformed
    case invalidAuthCode
    
    // Failed to build the auth request
    case invalidRequest
    
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
        case .invalidAuthCode:
            return "The auth code was not found or is malformed"
        case .invalidRequest:
            return "Failed to build the auth request"
        case .oAuth(let error):
            return error.errorDescription
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
