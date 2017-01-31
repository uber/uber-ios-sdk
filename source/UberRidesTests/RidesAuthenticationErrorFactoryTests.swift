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
        RidesAuthenticationErrorType.accessDenied : "access_denied",
        RidesAuthenticationErrorType.expiredJWT : "expired_jwt",
        RidesAuthenticationErrorType.generalError : "general_error",
        RidesAuthenticationErrorType.internalServerError : "internal_server_error",
        RidesAuthenticationErrorType.invalidAppSignature : "invalid_app_signature",
        RidesAuthenticationErrorType.invalidAuthCode : "invalid_auth_code",
        RidesAuthenticationErrorType.invalidClientID : "invalid_client_id",
        RidesAuthenticationErrorType.invalidFlowError : "invalid_flow_error",
        RidesAuthenticationErrorType.invalidJWT : "invalid_jwt",
        RidesAuthenticationErrorType.invalidJWTSignature : "invalid_jwt_signature",
        RidesAuthenticationErrorType.invalidNonce : "invalid_nonce",
        RidesAuthenticationErrorType.invalidRedirect : "invalid_redirect_uri",
        RidesAuthenticationErrorType.invalidRefreshToken: "invalid_refresh_token",
        RidesAuthenticationErrorType.invalidRequest : "invalid_parameters",
        RidesAuthenticationErrorType.invalidResponse : "invalid_response",
        RidesAuthenticationErrorType.invalidScope : "invalid_scope",
        RidesAuthenticationErrorType.invalidSSOResponse : "invalid_sso_response",
        RidesAuthenticationErrorType.invalidUserID : "invalid_user_id",
        RidesAuthenticationErrorType.malformedRequest : "malformed_request",
        RidesAuthenticationErrorType.mismatchingRedirect : "mismatching_redirect_uri",
        RidesAuthenticationErrorType.networkError : "network_error",
        RidesAuthenticationErrorType.serverError : "server_error",
        RidesAuthenticationErrorType.unableToPresentLogin : "present_login_failed",
        RidesAuthenticationErrorType.unableToSaveAccessToken : "token_not_saved",
        RidesAuthenticationErrorType.unavailable : "temporarily_unavailable",
        RidesAuthenticationErrorType.userCancelled : "cancelled",
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
