//
//  RidesAuthenticationErrorFactoryTests.swift
//  UberRides
//
//  Copyright © 2015 Uber Technologies, Inc. All rights reserved.
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

import XCTest
@testable import UberRides

class RidesAuthenticationErrorFactoryTests: XCTestCase {
    
    let expectedErrorToStringMapping = [
        RidesAuthenticationErrorType.AccessDenied : "access_denied",
        RidesAuthenticationErrorType.ExpiredJWT : "expired_jwt",
        RidesAuthenticationErrorType.GeneralError : "general_error",
        RidesAuthenticationErrorType.InternalServerError : "internal_server_error",
        RidesAuthenticationErrorType.InvalidAppSignature : "invalid_app_signature",
        RidesAuthenticationErrorType.InvalidAuthCode : "invalid_auth_code",
        RidesAuthenticationErrorType.InvalidClientID : "invalid_client_id",
        RidesAuthenticationErrorType.InvalidFlowError : "invalid_flow_error",
        RidesAuthenticationErrorType.InvalidJWT : "invalid_jwt",
        RidesAuthenticationErrorType.InvalidJWTSignature : "invalid_jwt_signature",
        RidesAuthenticationErrorType.InvalidNonce : "invalid_nonce",
        RidesAuthenticationErrorType.InvalidRedirect : "invalid_redirect_uri",
        RidesAuthenticationErrorType.InvalidRefreshToken: "invalid_refresh_token",
        RidesAuthenticationErrorType.InvalidRequest : "invalid_parameters",
        RidesAuthenticationErrorType.InvalidResponse : "invalid_response",
        RidesAuthenticationErrorType.InvalidScope : "invalid_scope",
        RidesAuthenticationErrorType.InvalidSSOResponse : "invalid_sso_response",
        RidesAuthenticationErrorType.InvalidUserID : "invalid_user_id",
        RidesAuthenticationErrorType.MalformedRequest : "malformed_request",
        RidesAuthenticationErrorType.MismatchingRedirect : "mismatching_redirect_uri",
        RidesAuthenticationErrorType.NetworkError : "network_error",
        RidesAuthenticationErrorType.ServerError : "server_error",
        RidesAuthenticationErrorType.UnableToPresentLogin : "present_login_failed",
        RidesAuthenticationErrorType.UnableToSaveAccessToken : "token_not_saved",
        RidesAuthenticationErrorType.Unavailable : "temporarily_unavailable",
        RidesAuthenticationErrorType.UserCancelled : "cancelled",
    ]
    
    func testCreateErrorsByErrorType() {
        
        for errorType in expectedErrorToStringMapping.keys {
            let ridesAuthenticationError = RidesAuthenticationErrorFactory.errorForType(ridesAuthenticationErrorType: errorType)
            
            XCTAssertNotNil(ridesAuthenticationError)
            XCTAssertEqual(ridesAuthenticationError.code , errorType.rawValue)
            XCTAssertEqual(ridesAuthenticationError.domain , RidesAuthenticationErrorFactory.errorDomain)
            XCTAssertEqual(ridesAuthenticationError.localizedDescription, errorType.localizedDescriptionKey)
        }
    }
    
    func testCreateErrorsByRawValue() {
        for (errorType, rawValue) in expectedErrorToStringMapping {
            let ridesAuthenticationError = RidesAuthenticationErrorFactory.createRidesAuthenticationError(rawValue: rawValue)
            
            XCTAssertNotNil(ridesAuthenticationError)
            if let ridesAuthenticationError = ridesAuthenticationError {
                XCTAssertEqual(ridesAuthenticationError.code , errorType.rawValue)
                XCTAssertEqual(ridesAuthenticationError.domain, RidesAuthenticationErrorFactory.errorDomain)
                XCTAssertEqual(ridesAuthenticationError.localizedDescription, errorType.localizedDescriptionKey)
            }
        }
    }
    
    func testCreateErrorByRawValue_withUnknownValue() {
        let ridesAuthenticationError = RidesAuthenticationErrorFactory.createRidesAuthenticationError(rawValue: "not.real.error")
        
        XCTAssertNil(ridesAuthenticationError)
    }
}
