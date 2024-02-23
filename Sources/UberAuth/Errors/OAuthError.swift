//
//  Copyright © Uber Technologies, Inc. All rights reserved.
//


import Foundation

/// OAuth Standard Errors
/// https://datatracker.ietf.org/doc/html/rfc6749#section-4.1.2
public enum OAuthError: String, Error, Equatable {

    // The request is missing a required parameter, includes an
    // invalid parameter value, includes a parameter more than
    // once, or is otherwise malformed.
    case invalidRequest = "invalid_request"
    
    // The client is not authorized to request an authorization
    // code using this method.
    case unauthorizedClient = "unauthorized_client"
    
    // The resource owner or authorization server denied the request.
    case accessDenied = "access_denied"
    
    // The authorization server does not support obtaining an
    // authorization code using this method.
    case unsupportedResponseType = "unsupported_response_type"
    
    // The requested scope is invalid, unknown, or malformed.
    case invalidScope = "invalid_scope"
    
    // The authorization server encountered an unexpected
    // condition that prevented it from fulfilling the request.
    // (This error code is needed because a 500 Internal Server
    // Error HTTP status code cannot be returned to the client
    // via an HTTP redirect.)
    case serverError = "server_error"
    
    // The authorization server is currently unable to handle
    // the request due to a temporary overloading or maintenance
    // of the server.  (This error code is needed because a 503
    // Service Unavailable HTTP status code cannot be returned
    // to the client via an HTTP redirect.)
    case temporarilyUnavailable = "temporarily_unavailable"
}

extension OAuthError: LocalizedError {
    
    public var errorDescription: String? {
        switch self {
        case .invalidRequest:
            return """
            The request is missing a required parameter, includes an
            invalid parameter value, includes a parameter more than
            once, or is otherwise malformed.
            """
        case .unauthorizedClient:
            return "The client is not authorized to request an authorization code using this method."
        case .accessDenied:
            return "The resource owner or authorization server denied the request."
        case .unsupportedResponseType:
            return " The authorization server does not support obtaining an authorization code using this method."
        case .invalidScope:
            return "The requested scope is invalid, unknown, or malformed."
        case .serverError:
            return """
            The authorization server encountered an unexpected
            condition that prevented it from fulfilling the request.
            (This error code is needed because a 500 Internal Server
            Error HTTP status code cannot be returned to the client
            via an HTTP redirect.)
            """
        case .temporarilyUnavailable:
            return """
            The authorization server is currently unable to handle
            the request due to a temporary overloading or maintenance
            of the server.  (This error code is needed because a 503
            Service Unavailable HTTP status code cannot be returned
            to the client via an HTTP redirect.)
            """
        }
    }
}
