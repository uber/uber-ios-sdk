//
//  RidesError.swift
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

import ObjectMapper

// MARK: RidesError

/// Base class for errors that can be mapped from HTTP responses.
@objc(UBSDKRidesError) public class RidesError : NSObject {
    /// HTTP status code for error.
    public internal(set) var status: Int = -1
    
    /// Human readable message which corresponds to the client error.
    public internal(set) var title: String?
    
    /// Underscore delimited string.
    public internal(set) var code: String?
    
    /// Additional information about errors. Can be "fields" or "meta" as the key.
    public internal(set) var meta: [String: AnyObject]?
    
    /// List of additional errors. This can be populated instead of status/code/title.
    public internal(set) var errors: [RidesError]?

    override init() {
    }
    
    public required init?(_ map: Map) {
    }
}

extension RidesError: UberModel {
    public func mapping(map: Map) {
        code    <- map["code"]
        status  <- map["status"]
        errors  <- map["errors"]
        
        if map["message"].currentValue != nil {
            title <- map["message"]
        } else if map["title"].currentValue != nil {
            title <- map["title"]
        }
        
        if map["fields"].currentValue != nil {
            meta  <- map["fields"]
        } else if map["meta"].currentValue != nil {
            meta  <- map["meta"]
        }
        
        if map["error"].currentValue != nil {
            title <- map["error"]
        }
    }
}

// MARK: RidesError subclasses

/// Client error 4xx.
@objc(UBSDKRidesClientError) public class RidesClientError: RidesError {

    public required init?(_ map: Map) {
        super.init(map)
    }
}

/// Server error 5xx.
@objc(UBSDKRidesServerError) public class RidesServerError: RidesError {
    
    public required init?(_ map: Map) {
        super.init(map)
    }
}

/// Unknown error type.
@objc(UBSDKRidesUnknownError) public class RidesUnknownError: RidesError {
    
    override init() {
        super.init()
    }
    
    public required init?(_ map: Map) {
        super.init(map)
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
@objc public enum RidesAuthenticationErrorType: Int {
    case AccessDenied
    case ExpiredJWT
    case GeneralError
    case InternalServerError
    case InvalidAppSignature
    case InvalidAuthCode
    case InvalidClientID
    case InvalidFlowError
    case InvalidJWT
    case InvalidJWTSignature
    case InvalidNonce
    case InvalidRedirect
    case InvalidRefreshToken
    case InvalidRequest
    case InvalidResponse
    case InvalidScope
    case InvalidSSOResponse
    case InvalidUserID
    case MalformedRequest
    case MismatchingRedirect
    case NetworkError
    case ServerError
    case UnableToPresentLogin
    case UnableToSaveAccessToken
    case Unavailable
    case UserCancelled
    
    func toString() -> String {
        switch self {
        case .AccessDenied:
            return "access_denied"
        case .ExpiredJWT:
            return "expired_jwt"
        case .GeneralError:
            return "general_error"
        case .InternalServerError:
            return "internal_server_error"
        case .InvalidAppSignature:
            return "invalid_app_signature"
        case .InvalidAuthCode:
            return "invalid_auth_code"
        case .InvalidClientID:
            return "invalid_client_id"
        case .InvalidFlowError:
            return "invalid_flow_error"
        case .InvalidJWT:
            return "invalid_jwt"
        case .InvalidJWTSignature:
            return "invalid_jwt_signature"
        case .InvalidNonce:
            return "invalid_nonce"
        case .InvalidRedirect:
            return "invalid_redirect_uri"
        case .InvalidRefreshToken:
            return "invalid_refresh_token"
        case .InvalidRequest:
            return "invalid_parameters"
        case .InvalidResponse:
            return "invalid_response"
        case .InvalidScope:
            return "invalid_scope"
        case .InvalidSSOResponse:
            return "invalid_sso_response"
        case .InvalidUserID:
            return "invalid_user_id"
        case .MalformedRequest:
            return "malformed_request"
        case .MismatchingRedirect:
            return "mismatching_redirect_uri"
        case .NetworkError:
            return "network_error"
        case .ServerError:
            return "server_error"
        case .UnableToPresentLogin:
            return "present_login_failed"
        case .UnableToSaveAccessToken:
            return "token_not_saved"
        case .Unavailable:
            return "temporarily_unavailable"
        case .UserCancelled:
            return "cancelled"
        }
    }
    
    var localizedDescriptionKey: String {
        switch self {
        case .AccessDenied:
            return "The user denied the requested scopes."
        case .ExpiredJWT:
            return "The scope accept session expired."
        case .GeneralError:
            return "A general error occured."
        case .InternalServerError:
            return "An internal server error occured."
        case .InvalidAppSignature:
            return "The provided app signature did not match what was expected."
        case .InvalidAuthCode:
            return "There was a problem authorizing you."
        case .InvalidClientID:
            return "Invalid Client ID provided."
        case .InvalidFlowError:
            return "There was a problem displaying the authorize screen."
        case .InvalidJWT:
            return "There was a problem authorizing you."
        case .InvalidJWTSignature:
            return "There was a problem authorizing you."
        case .InvalidNonce:
            return "There was a problem authorizing you."
        case .InvalidRedirect:
            return "Invalid Redirect URI provided."
        case .InvalidRefreshToken:
            return "Invalid Refresh TOken provided."
        case .InvalidRequest:
            return "The server was unable to understand your request."
        case .InvalidResponse:
            return "Unable to interpret the response from the server."
        case .InvalidScope:
            return "Your app is not authorized for the requested scopes."
        case .InvalidSSOResponse:
            return "The server responded with an invalid response."
        case .InvalidUserID:
            return "There was a problem with your user ID."
        case .MalformedRequest:
            return "There was a problem loading the authorize screen."
        case .MismatchingRedirect:
            return "The Redirect URI provided did not match what was expected."
        case .NetworkError:
            return "A network error occured."
        case .ServerError:
            return "A server error occurred."
        case .UnableToPresentLogin:
            return "Unable to present the login view."
        case .UnableToSaveAccessToken:
            return "Unable to save the access token."
        case .Unavailable:
            return "Login is temporarily unavailable."
        case .UserCancelled:
            return "User cancelled the login process."
        }
    }
    
    func toLocalizedDescription() -> String {
        return LocalizationUtil.localizedString(forKey: self.localizedDescriptionKey, comment: self.toString())
    }
}

class RidesAuthenticationErrorFactory : NSObject {
    
    static let errorDomain = "com.uber.rides-ios-sdk.ridesAuthenticationError"
    
    /**
     Creates a RidesAuthenticationError for the provided RidesAuthenticationErrorType
     
     - parameter ridesAuthenticationErrorType: the RidesAuthenticationErrorType of error to create
     
     - returns: An initialized RidesAuthenticationError
     */
    static func errorForType(ridesAuthenticationErrorType ridesAuthenticationErrorType : RidesAuthenticationErrorType) -> NSError {
        return NSError(domain: errorDomain, code: ridesAuthenticationErrorType.rawValue, userInfo: [NSLocalizedDescriptionKey : ridesAuthenticationErrorType.toLocalizedDescription()])
    }
    
    static func createRidesAuthenticationError(rawValue rawValue: String) -> NSError? {
        guard let ridesAuthenticationErrorType = ridesAuthenticationErrorType(rawValue) else {
            return nil
        }
        return RidesAuthenticationErrorFactory.errorForType(ridesAuthenticationErrorType: ridesAuthenticationErrorType)
    }
    
    static func ridesAuthenticationErrorType(rawValue: String) -> RidesAuthenticationErrorType? {
        switch rawValue {
        case "access_denied":
            return .AccessDenied
        case "cancelled":
            return .UserCancelled
        case "expired_jwt":
            return .ExpiredJWT
        case "general_error":
            return .GeneralError
        case "internal_server_error":
            return .InternalServerError
        case "invalid_app_signature":
            return .InvalidAppSignature
        case "invalid_auth_code":
            return .InvalidAuthCode
        case "invalid_client_id":
            return .InvalidClientID
        case "invalid_flow_error":
            return .InvalidFlowError
        case "invalid_jwt":
            return .InvalidJWT
        case "invalid_jwt_signature":
            return .InvalidJWTSignature
        case "invalid_nonce":
            return .InvalidNonce
        case "invalid_parameters":
            return .InvalidRequest
        case "invalid_redirect_uri":
            return .InvalidRedirect
        case "invalid_refresh_token":
            return .InvalidRefreshToken
        case "invalid_response":
            return .InvalidResponse
        case "invalid_scope":
            return .InvalidScope
        case "invalid_sso_response":
            return .InvalidSSOResponse
        case "invalid_user_id":
            return .InvalidUserID
        case "malformed_request":
            return .MalformedRequest
        case "mismatching_redirect_uri":
            return .MismatchingRedirect
        case "network_error":
            return .NetworkError
        case "present_login_failed":
            return .UnableToPresentLogin
        case "server_error":
            return .ServerError
        case "temporarily_unavailable":
            return .Unavailable
        case "token_not_saved":
            return .UnableToSaveAccessToken
        default:
            return nil
        }
    }
}
