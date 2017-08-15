//
//  NativeAuthenticatorTests.swift
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

class NativeAuthenticatorTests: XCTestCase {
    private var testExpectation: XCTestExpectation!
    private var accessToken: AccessToken?
    private var error: NSError?
    private let timeout: TimeInterval = 2
    private let tokenString = "accessToken1234"
    private var redirectURI: String = ""
    
    override func setUp() {
        super.setUp()
        Configuration.bundle = Bundle(for: type(of: self))
        Configuration.plistName = "testInfo"
        Configuration.restoreDefaults()
        Configuration.shared.isSandbox = true
        redirectURI = Configuration.shared.getCallbackURIString(for: .native)
    }
    
    override func tearDown() {
        _ = TokenManager.deleteToken()
        Configuration.restoreDefaults()
        super.tearDown()
    }
    
    func testNativeAuthenticator_usesNativeCallback() {
        let nativeAuthenticator = NativeAuthenticator(scopes: [])
        XCTAssertEqual(nativeAuthenticator.callbackURIType, CallbackURIType.native)
    }
    
    func testNativeAuthenticator_deeplinkExecutedOnLogin() {
        testExpectation =  self.expectation(description: "Execute should be called")
        let executeClosure:(((NSError?) -> ())?) -> () = { _ in
            self.testExpectation.fulfill()
        }
        let nativeAuthenticator = NativeAuthenticator(scopes: [])
        XCTAssertNotNil(nativeAuthenticator.deeplink)
        let deeplinkMock = DeeplinkingProtocolMock(deeplinkingObject: nativeAuthenticator.deeplink)
        deeplinkMock.executeClosure = executeClosure
        nativeAuthenticator.deeplink = deeplinkMock
        
        nativeAuthenticator.login()
        
        waitForExpectations(timeout: 1, handler: nil)
    }
    
    func testNativeAuthenticator_loginCompletionCalled_whenExecuteFails() {
        testExpectation =  expectation(description: "Execute should be called")
        let loginCompletion: ((_ accessToken: AccessToken?, _ error: NSError?) -> Void) = { (_,_) in
            self.testExpectation.fulfill()
        }
        let nativeAuthenticator = NativeAuthenticator(scopes: [])
        nativeAuthenticator.loginCompletion = loginCompletion
        XCTAssertNotNil(nativeAuthenticator.deeplink)
        let deeplinkMock = DeeplinkingProtocolMock(deeplinkingObject: nativeAuthenticator.deeplink)
        deeplinkMock.overrideExecute = true
        deeplinkMock.overrideExecuteValue = DeeplinkErrorFactory.errorForType(.unableToFollow)
        nativeAuthenticator.deeplink = deeplinkMock
        
        nativeAuthenticator.login()
        
        waitForExpectations(timeout: 1, handler: nil)
    }
}
