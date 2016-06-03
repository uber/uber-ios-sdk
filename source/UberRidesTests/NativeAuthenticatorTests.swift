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
    private var expectation: XCTestExpectation!
    private var accessToken: AccessToken?
    private var error: NSError?
    private let timeout: NSTimeInterval = 2
    private let tokenString = "accessToken1234"
    private var redirectURI: String = ""
    
    override func setUp() {
        super.setUp()
        Configuration.restoreDefaults()
        Configuration.plistName = "testInfo"
        Configuration.bundle = NSBundle(forClass: self.dynamicType)
        Configuration.setSandboxEnabled(true)
        redirectURI = Configuration.getCallbackURIString(.Native)
    }
    
    override func tearDown() {
        TokenManager.deleteToken()
        Configuration.restoreDefaults()
        super.tearDown()
    }
    
    func testNativeAuthenticator_usesNativeCallback() {
        let nativeAuthenticator = NativeAuthenticator(scopes: [])
        XCTAssertEqual(nativeAuthenticator.callbackURIType, CallbackURIType.Native)
    }
    
    func testNativeAuthenticator_deeplinkExecutedOnLogin() {
        let expectation = self.expectationWithDescription("Execute should be called")
        let executeClosure:((NSError?) -> ())? -> () = { _ in
            expectation.fulfill()
        }
        let nativeAuthenticator = NativeAuthenticator(scopes: [])
        XCTAssertNotNil(nativeAuthenticator.deeplink)
        let deeplinkMock = DeeplinkingProtocolMock(deeplinkingObject: nativeAuthenticator.deeplink)
        deeplinkMock.executeClosure = executeClosure
        nativeAuthenticator.deeplink = deeplinkMock
        
        nativeAuthenticator.login()
        
        waitForExpectationsWithTimeout(1, handler: nil)
    }
    
    func testNativeAuthenticator_loginCompletionCalled_whenExecuteFails() {
        let expectation = self.expectationWithDescription("Execute should be called")
        let loginCompletion: ((accessToken: AccessToken?, error: NSError?) -> Void) = { (_,_) in
            expectation.fulfill()
        }
        let nativeAuthenticator = NativeAuthenticator(scopes: [])
        nativeAuthenticator.loginCompletion = loginCompletion
        XCTAssertNotNil(nativeAuthenticator.deeplink)
        let deeplinkMock = DeeplinkingProtocolMock(deeplinkingObject: nativeAuthenticator.deeplink)
        deeplinkMock.overrideExecute = true
        deeplinkMock.overrideExecuteValue = DeeplinkErrorFactory.errorForType(.UnableToFollow)
        nativeAuthenticator.deeplink = deeplinkMock
        
        nativeAuthenticator.login()
        
        waitForExpectationsWithTimeout(1, handler: nil)
    }
}
