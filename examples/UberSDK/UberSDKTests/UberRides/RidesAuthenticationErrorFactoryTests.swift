//
//  UberAuthenticationErrorFactoryTests.swift
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
@testable import UberCore
@testable import UberRides

class UberAuthenticationErrorFactoryTests: XCTestCase {
    
    let expectedErrorToStringMapping = [
        UberAuthenticationErrorType.accessDenied : "access_denied",
        UberAuthenticationErrorType.expiredJWT : "expired_jwt",
        UberAuthenticationErrorType.generalError : "general_error",
        UberAuthenticationErrorType.internalServerError : "internal_server_error",
        UberAuthenticationErrorType.invalidAppSignature : "invalid_app_signature",
        UberAuthenticationErrorType.invalidAuthCode : "invalid_auth_code",
        UberAuthenticationErrorType.invalidClientID : "invalid_client_id",
        UberAuthenticationErrorType.invalidFlowError : "invalid_flow_error",
        UberAuthenticationErrorType.invalidJWT : "invalid_jwt",
        UberAuthenticationErrorType.invalidJWTSignature : "invalid_jwt_signature",
        UberAuthenticationErrorType.invalidNonce : "invalid_nonce",
        UberAuthenticationErrorType.invalidRedirect : "invalid_redirect_uri",
        UberAuthenticationErrorType.invalidRefreshToken: "invalid_refresh_token",
        UberAuthenticationErrorType.invalidRequest : "invalid_parameters",
        UberAuthenticationErrorType.invalidResponse : "invalid_response",
        UberAuthenticationErrorType.invalidScope : "invalid_scope",
        UberAuthenticationErrorType.invalidSSOResponse : "invalid_sso_response",
        UberAuthenticationErrorType.invalidUserID : "invalid_user_id",
        UberAuthenticationErrorType.malformedRequest : "malformed_request",
        UberAuthenticationErrorType.mismatchingRedirect : "mismatching_redirect_uri",
        UberAuthenticationErrorType.networkError : "network_error",
        UberAuthenticationErrorType.serverError : "server_error",
        UberAuthenticationErrorType.unableToPresentLogin : "present_login_failed",
        UberAuthenticationErrorType.unableToSaveAccessToken : "token_not_saved",
        UberAuthenticationErrorType.unavailable : "temporarily_unavailable",
        UberAuthenticationErrorType.userCancelled : "cancelled",
    ]
    
    func testCreateErrorsByErrorType() {
        
        for errorType in expectedErrorToStringMapping.keys {
            let ridesAuthenticationError = UberAuthenticationErrorFactory.errorForType(ridesAuthenticationErrorType: errorType)
            
            XCTAssertNotNil(ridesAuthenticationError)
            XCTAssertEqual(ridesAuthenticationError.code , errorType.rawValue)
            XCTAssertEqual(ridesAuthenticationError.domain , UberAuthenticationErrorFactory.errorDomain)
            XCTAssertEqual(ridesAuthenticationError.localizedDescription, errorType.localizedDescriptionKey)
        }
    }
    
    func testCreateErrorsByRawValue() {
        for (errorType, rawValue) in expectedErrorToStringMapping {
            let ridesAuthenticationError = UberAuthenticationErrorFactory.createRidesAuthenticationError(rawValue: rawValue)
            
            XCTAssertNotNil(ridesAuthenticationError)
            if let ridesAuthenticationError = ridesAuthenticationError {
                XCTAssertEqual(ridesAuthenticationError.code , errorType.rawValue)
                XCTAssertEqual(ridesAuthenticationError.domain, UberAuthenticationErrorFactory.errorDomain)
                XCTAssertEqual(ridesAuthenticationError.localizedDescription, errorType.localizedDescriptionKey)
            }
        }
    }
    
    func testCreateErrorByRawValue_withUnknownValue() {
        let ridesAuthenticationError = UberAuthenticationErrorFactory.createRidesAuthenticationError(rawValue: "not.real.error")
        
        XCTAssertNil(ridesAuthenticationError)
    }
}
