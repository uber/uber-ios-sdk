//
//  BaseAuthenticatorTests.swift
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

class BaseAuthenticatorTests: XCTestCase {
    private var expectation: XCTestExpectation!
    private var accessToken: AccessToken?
    private var error: NSError?
    private let timeout: TimeInterval = 2
    private let tokenString = "accessToken1234"
    private var incomingURLComponents: URLComponents?
    private var baseAuthenticator = BaseAuthenticator(scopes: [])
    
    override func setUp() {
        super.setUp()
        Configuration.plistName = "testInfo"
        Configuration.restoreDefaults()
        Configuration.shared.isSandbox = true
        incomingURLComponents = URLComponents(url: Configuration.shared.getCallbackURI(for: .general), resolvingAgainstBaseURL: false)
        baseAuthenticator = BaseAuthenticator(scopes: [])
    }
    
    override func tearDown() {
        _ = TokenManager.deleteToken()
        Configuration.restoreDefaults()
        super.tearDown()
    }
    
    func testBaseAuthenticator_correctlySavesScopes() {
        let scopes = [UberScope.profile, UberScope.allTrips]
        baseAuthenticator = BaseAuthenticator(scopes: scopes)
        XCTAssertEqual(scopes, baseAuthenticator.scopes);
    }

    func testBaseAuthenticatorCreatesAccessTokenFromValidRedirectURL() {
        incomingURLComponents?.fragment = "access_token=\(tokenString)"
        guard let incomingURL = incomingURLComponents?.url else {
            XCTFail("Error setting up test")
            return
        }

        self.expectation = expectation(description: "The valid token should be parsed")

        baseAuthenticator.consumeResponse(url: incomingURL) { accessToken, error in
            XCTAssertEqual(accessToken?.tokenString, self.tokenString)
            XCTAssertNil(error)
            self.expectation.fulfill()
        }
        waitForExpectations(timeout: 1, handler: nil)
    }

    func testBaseAuthenticatorCreatesErrorFromValidRedirectURL() {
        incomingURLComponents?.fragment = "error=invalid_grant&error_description=Invalid%20Password"
        guard let incomingURL = incomingURLComponents?.url else {
            XCTFail("Error setting up test")
            return
        }

        self.expectation = expectation(description: "The error should be parsed")

        baseAuthenticator.consumeResponse(url: incomingURL) { accessToken, error in
            XCTAssertNil(accessToken)
            XCTAssertEqual(error?.domain, "com.uber.rides-ios-sdk.ridesAuthenticationError")
            self.expectation.fulfill()
        }
        waitForExpectations(timeout: 1, handler: nil)
    }

    func testBaseAuthenticatorCreatesErrorFromInvalidRedirectURL() {
        incomingURLComponents?.fragment = "WOLOLO"
        guard let incomingURL = incomingURLComponents?.url else {
            XCTFail("Error setting up test")
            return
        }

        self.expectation = expectation(description: "The invalid response should result in an error.")

        baseAuthenticator.consumeResponse(url: incomingURL) { accessToken, error in
            XCTAssertNil(accessToken)
            XCTAssertEqual(error, UberAuthenticationErrorFactory.errorForType(ridesAuthenticationErrorType: .invalidResponse))
            self.expectation.fulfill()
        }
        waitForExpectations(timeout: 1, handler: nil)
    }
}
