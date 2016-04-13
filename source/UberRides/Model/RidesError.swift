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
    public internal(set) var status: Int?
    
    /// Human readable message which corresponds to the client error.
    public internal(set) var title: String?
    
    /// Underscore delimited string.
    public internal(set) var code: String?
    
    /// Additional information about errors. Can be "fields" or "meta" as the key.
    public internal(set) var meta: [String: AnyObject]?
    
    /// List of additional errors. This can be populated instead of status/code/title.
    public internal(set) var errors: [RidesError]?

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
    
    public required init?(_ map: Map) {
        super.init(map)
    }
}

// MARK: RidesAuthenticationError

/**
Possible authentication errors.

- InvalidClientID:     Invalid client ID provided for authentication.
- InvalidRedirect:     Redirect URI provided was invalid
- InvalidRequest:      General case for invalid requests.
- InvalidResponse:     The response from the server was un-parseable
- InvalidScope:        Scopes provided contains an invalid scope.
- MismatchingRedirect: Redirect URI provided doesn't match one registered for client ID.
- NetworkError:        A network error occured
- ServerError:         A server error occurred during authentication.
- UnableToPresentLogin      Unable to present the login screen
- UnableToSaveAccessToken   There was a problem saving the access token
- Unavailable:         Authentication services temporarily unavailable.
- UserCancelled:       User cancelled the auth process
*/
@objc public enum RidesAuthenticationErrorType: Int {
    case InvalidClientID
    case InvalidRedirect
    case InvalidRequest
    case InvalidResponse
    case InvalidScope
    case MismatchingRedirect
    case NetworkError
    case ServerError
    case UnableToPresentLogin
    case UnableToSaveAccessToken
    case Unavailable
    case UserCancelled
    
    func toString() -> String {
        switch self {
        case .InvalidClientID:
            return "invalid_client_id"
        case .InvalidRedirect:
            return "invalid_redirect_uri"
        case .InvalidRequest:
            return "invalid_parameters"
        case .InvalidResponse:
            return "invalid_response"
        case .InvalidScope:
            return "invalid_scope"
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
        case .InvalidClientID:
            return "Invalid Client ID provided."
        case .InvalidRedirect:
            return "Invalid Redirect URI provided."
        case .InvalidRequest:
            return "The server was unable to understand your request."
        case .InvalidResponse:
            return "Unable to interpret the response from the server."
        case .InvalidScope:
            return "Your app is not authorized for the requested scopes."
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
        case "cancelled":
            return .UserCancelled
        case "invalid_client_id":
            return .InvalidClientID
        case "invalid_parameters":
            return .InvalidRequest
        case "invalid_redirect_uri":
            return .InvalidRedirect
        case "invalid_response":
            return .InvalidResponse
        case "invalid_scope":
            return .InvalidScope
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
