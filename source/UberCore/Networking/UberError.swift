//
//  UberError.swift
//  UberRides
//
//  Copyright © 2016 Uber Technologies, Inc. All rights reserved.
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

// MARK: UberError

/// Base class for errors that can be mapped from HTTP responses.
@objc(UBSDKError) public class UberError: NSObject, Decodable {
    /// HTTP status code for error.
    @objc public internal(set) var status: Int
    
    /// Human readable message which corresponds to the client error.
    @objc public internal(set) var title: String?
    
    /// Underscore delimited string.
    @objc public internal(set) var code: String?
    
    /// Additional information about errors. Can be "fields" or "meta" as the key.
    @objc public internal(set) var meta: [String: Any]?
    
    /// List of additional errors. This can be populated instead of status/code/title.
    @objc public internal(set) var errors: [UberError]?

    /// Convenience initializer.
    ///
    /// - parameter status: The Status code to use for this error
    /// - parameter code:   The underscore delimited code string to use for this error
    /// - parameter title:  Human readable message which corresponds to this error
    @objc public init(status: Int, code: String?, title: String?) {
        self.status = status
        self.code = code
        self.title = title
    }

    public required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        status = try container.decodeIfPresent(Int.self, forKey: .status) ?? -1
        title = try container.decodeIfPresent(String.self, forKey: .error)
        title = try title ?? container.decodeIfPresent(String.self, forKey: .message)
        title = try title ?? container.decodeIfPresent(String.self, forKey: .title)
        code = try container.decodeIfPresent(String.self, forKey: .code)
        errors = try container.decodeIfPresent([UberError].self, forKey: .errors)
        meta = try? container.decode([String: [String]].self, forKey: .fields)
        meta = try? meta ?? container.decode([String: [String: String]].self, forKey: .meta)
    }

    enum CodingKeys: String, CodingKey {
        case code    = "code"
        case status  = "status"
        case errors  = "errors"
        case message = "message"
        case title   = "title"
        case meta    = "meta"
        case fields  = "fields"
        case error   = "error"
    }
}
// MARK: UberError subclasses

/// Client error 4xx.
@objc(UBSDKClientError) public class UberClientError: UberError {
    public required init(from decoder: Decoder) throws {
        try super.init(from: decoder)
    }

    @objc public override init(status: Int, code: String?, title: String?) {
        super.init(status: status, code: code, title: title)
    }
}

/// Server error 5xx.
@objc(UBSDKServerError) public class UberServerError: UberError {
    public required init(from decoder: Decoder) throws {
        try super.init(from: decoder)
    }

    @objc public override init(status: Int, code: String?, title: String?) {
        super.init(status: status, code: code, title: title)
    }
}

/// Unknown error type.
@objc(UBSDKUnknownError) public class UberUnknownError: UberError {
    public required init(from decoder: Decoder) throws {
        try super.init(from: decoder)
    }

    @objc public override init(status: Int, code: String?, title: String?) {
        super.init(status: status, code: code, title: title)
    }
}

// MARK: RidesAuthenticationError

/**
 Possible authentication errors.
 
 - AccessDenied:            The user denied the requested scopes.
 - ExpiredJWT:              The scope accept session expired.
 - GeneralError:            A general error occured.
 - InternalServerError:     An internal server error occured.
 - InvalidAppSignature:     The provided app signature did not match what was expected.
 - InvalidAuthCode:         There was a problem authorizing you.
 - InvalidClientID:         Invalid client ID provided for authentication.
 - InvalidFlowError:        There was a problem displaying the authorize screen.
 - InvalidJWT:              There was a problem authorizing you.
 - InvalidJWTSignature:     There was a problem authorizing you.
 - InvalidNonce:            There was a problem authorizing you.
 - InvalidRedirect:         Redirect URI provided was invalid
 - InvalidRefreshToken:     The provided Refresh Token was invalid
 - InvalidRequest:          General case for invalid requests.
 - InvalidResponse:         The response from the server was un-parseable
 - InvalidScope:            Scopes provided contains an invalid scope.
 - InvalidSSOResponse:      The server responded with an invalid response.
 - InvalidUserID:           There was a problem with your user ID.
 - MalformedRequest:        There was a problem loading the authorize screen.
 - MismatchingRedirect:     Redirect URI provided doesn't match one registered for client ID.
 - NetworkError:            A network error occured
 - ServerError:             A server error occurred during authentication.
 - UnableToPresentLogin:    Unable to present the login screen
 - UnableToSaveAccessToken: There was a problem saving the access token
 - Unavailable:             Authentication services temporarily unavailable.
 - UserCancelled:           User cancelled the auth process
 */
@objc(UBSDKAuthenticationErrorType) public enum UberAuthenticationErrorType: Int {
    case accessDenied
    case expiredJWT
    case generalError
    case internalServerError
    case invalidAppSignature
    case invalidAuthCode
    case invalidClientID
    case invalidFlowError
    case invalidJWT
    case invalidJWTSignature
    case invalidNonce
    case invalidRedirect
    case invalidRefreshToken
    case invalidRequest
    case invalidResponse
    case invalidScope
    case invalidSSOResponse
    case invalidUserID
    case malformedRequest
    case mismatchingRedirect
    case networkError
    case serverError
    case unableToPresentLogin
    case unableToSaveAccessToken
    case unavailable
    case userCancelled
    
    func toString() -> String {
        switch self {
        case .accessDenied:
            return "access_denied"
        case .expiredJWT:
            return "expired_jwt"
        case .generalError:
            return "general_error"
        case .internalServerError:
            return "internal_server_error"
        case .invalidAppSignature:
            return "invalid_app_signature"
        case .invalidAuthCode:
            return "invalid_auth_code"
        case .invalidClientID:
            return "invalid_client_id"
        case .invalidFlowError:
            return "invalid_flow_error"
        case .invalidJWT:
            return "invalid_jwt"
        case .invalidJWTSignature:
            return "invalid_jwt_signature"
        case .invalidNonce:
            return "invalid_nonce"
        case .invalidRedirect:
            return "invalid_redirect_uri"
        case .invalidRefreshToken:
            return "invalid_refresh_token"
        case .invalidRequest:
            return "invalid_parameters"
        case .invalidResponse:
            return "invalid_response"
        case .invalidScope:
            return "invalid_scope"
        case .invalidSSOResponse:
            return "invalid_sso_response"
        case .invalidUserID:
            return "invalid_user_id"
        case .malformedRequest:
            return "malformed_request"
        case .mismatchingRedirect:
            return "mismatching_redirect_uri"
        case .networkError:
            return "network_error"
        case .serverError:
            return "server_error"
        case .unableToPresentLogin:
            return "present_login_failed"
        case .unableToSaveAccessToken:
            return "token_not_saved"
        case .unavailable:
            return "temporarily_unavailable"
        case .userCancelled:
            return "cancelled"
        }
    }
    
    var localizedDescriptionKey: String {
        switch self {
        case .accessDenied:
            return "The user denied the requested scopes."
        case .expiredJWT:
            return "The scope accept session expired."
        case .generalError:
            return "A general error occured."
        case .internalServerError:
            return "An internal server error occured."
        case .invalidAppSignature:
            return "The provided app signature did not match what was expected."
        case .invalidAuthCode:
            return "There was a problem authorizing you."
        case .invalidClientID:
            return "Invalid Client ID provided."
        case .invalidFlowError:
            return "There was a problem displaying the authorize screen."
        case .invalidJWT:
            return "There was a problem authorizing you."
        case .invalidJWTSignature:
            return "There was a problem authorizing you."
        case .invalidNonce:
            return "There was a problem authorizing you."
        case .invalidRedirect:
            return "Invalid Redirect URI provided."
        case .invalidRefreshToken:
            return "Invalid Refresh Token provided."
        case .invalidRequest:
            return "The server was unable to understand your request."
        case .invalidResponse:
            return "Unable to interpret the response from the server."
        case .invalidScope:
            return "Your app is not authorized for the requested scopes."
        case .invalidSSOResponse:
            return "The server responded with an invalid response."
        case .invalidUserID:
            return "There was a problem with your user ID."
        case .malformedRequest:
            return "There was a problem loading the authorize screen."
        case .mismatchingRedirect:
            return "The Redirect URI provided did not match what was expected."
        case .networkError:
            return "A network error occured."
        case .serverError:
            return "A server error occurred."
        case .unableToPresentLogin:
            return "Unable to present the login view."
        case .unableToSaveAccessToken:
            return "Unable to save the access token."
        case .unavailable:
            return "Login is temporarily unavailable."
        case .userCancelled:
            return "User cancelled the login process."
        }
    }
    
    func toLocalizedDescription() -> String {
        return NSLocalizedString(localizedDescriptionKey, bundle: Bundle(for: UberError.self), comment: toString())
    }
}

public class UberAuthenticationErrorFactory {
    
    static let errorDomain = "com.uber.rides-ios-sdk.ridesAuthenticationError"
    
    /**
     Creates a RidesAuthenticationError for the provided UberAuthenticationErrorType
     
     - parameter ridesAuthenticationErrorType: the UberAuthenticationErrorType of error to create
     
     - returns: An initialized RidesAuthenticationError
     */
    public static func errorForType(ridesAuthenticationErrorType : UberAuthenticationErrorType) -> NSError {
        return NSError(domain: errorDomain, code: ridesAuthenticationErrorType.rawValue, userInfo: [NSLocalizedDescriptionKey : ridesAuthenticationErrorType.toLocalizedDescription()])
    }
    
    public static func createRidesAuthenticationError(rawValue: String) -> NSError? {
        guard let ridesAuthenticationErrorType = ridesAuthenticationErrorType(rawValue) else {
            return nil
        }
        return UberAuthenticationErrorFactory.errorForType(ridesAuthenticationErrorType: ridesAuthenticationErrorType)
    }
    
    static func ridesAuthenticationErrorType(_ rawValue: String) -> UberAuthenticationErrorType? {
        switch rawValue {
        case "access_denied":
            return .accessDenied
        case "cancelled":
            return .userCancelled
        case "expired_jwt":
            return .expiredJWT
        case "general_error":
            return .generalError
        case "internal_server_error":
            return .internalServerError
        case "invalid_app_signature":
            return .invalidAppSignature
        case "invalid_auth_code":
            return .invalidAuthCode
        case "invalid_client_id":
            return .invalidClientID
        case "invalid_flow_error":
            return .invalidFlowError
        case "invalid_jwt":
            return .invalidJWT
        case "invalid_jwt_signature":
            return .invalidJWTSignature
        case "invalid_nonce":
            return .invalidNonce
        case "invalid_parameters":
            return .invalidRequest
        case "invalid_redirect_uri":
            return .invalidRedirect
        case "invalid_refresh_token":
            return .invalidRefreshToken
        case "invalid_response":
            return .invalidResponse
        case "invalid_scope":
            return .invalidScope
        case "invalid_sso_response":
            return .invalidSSOResponse
        case "invalid_user_id":
            return .invalidUserID
        case "malformed_request":
            return .malformedRequest
        case "mismatching_redirect_uri":
            return .mismatchingRedirect
        case "network_error":
            return .networkError
        case "present_login_failed":
            return .unableToPresentLogin
        case "server_error":
            return .serverError
        case "temporarily_unavailable":
            return .unavailable
        case "token_not_saved":
            return .unableToSaveAccessToken
        default:
            return nil
        }
    }
}
