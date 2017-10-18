//
//  RideRequestViewTests.swift
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

import XCTest
import WebKit
import UberCore
@testable import UberRides

class RideRequestViewTests: XCTestCase {
    var testExpectation: XCTestExpectation!
    var error: NSError?
    let timeout: TimeInterval = 10
    
    override func setUp() {
        super.setUp()
        Configuration.plistName = "testInfo"
        Configuration.restoreDefaults()
        Configuration.shared.isSandbox = true
    }
    
    override func tearDown() {
        Configuration.restoreDefaults()
        super.tearDown()
    }
    
    /**
     Test that access token expiration is routed to delegate.
     */
    func testAccessTokenExpired() {
        testExpectation = expectation(description: "access token expired delegate call")
        let view = RideRequestView(rideParameters: RideParametersBuilder().build())
        view.delegate = self
        let request = URLRequest(url: URL(string: "uberConnect://oauth#error=unauthorized")!)
        view.webView.load(request)
        
        waitForExpectations(timeout: timeout, handler: { error in
            XCTAssertNil(error)
        })
    }
    
    /**
     Test the an unknown error message is routed to delegate.
     */
    func testUnkownError() {
        testExpectation = expectation(description: "unknown error delegate call")
        let view = RideRequestView()
        view.delegate = self
        let request = URLRequest(url: URL(string: "uberConnect://oauth#error=on_fire")!)
        view.webView.load(request)
        
        waitForExpectations(timeout: timeout, handler: { error in
            XCTAssertNil(error)
            XCTAssertNotNil(self.error)
            XCTAssertEqual(self.error?.code, RideRequestViewErrorType.unknown.rawValue)
            XCTAssertEqual(self.error?.domain, RideRequestViewErrorFactory.errorDomain)
        })
    }
    
    /**
     Test that no exception is thrown for authorization if custom access token is passed.
     */
    func testAuthorizeWithCustomAccessToken() {
        let token = AccessToken(tokenString: "accessToken1234")
        let view = RideRequestView(rideParameters: RideParametersBuilder().build(), accessToken: token, frame: CGRect.zero)
        XCTAssertNotNil(view.accessToken)
        XCTAssertEqual(view.accessToken, token)
    }
    
    /**
     Test that authorization passes with token in token manager.
     */
    func testAuthorizeWithTokenManagerAccessToken() {
        let token = AccessToken(tokenString: "accessToken1234")
        _ = TokenManager.save(accessToken: token)
        
        let view = RideRequestView()
        XCTAssertNotNil(view.accessToken)
        XCTAssertEqual(view.accessToken?.tokenString, TokenManager.fetchToken()?.tokenString)
        
        _ = TokenManager.deleteToken()
    }
    
    /**
     Test that load is successful when access token is set after initialization.
     */
    func testAuthorizeWithTokenSetAfterInitialization() {
        let token = AccessToken(tokenString: "accessToken1234")
        let view = RideRequestView()
        view.accessToken = token
        XCTAssertNotNil(view.accessToken)
    }
    
    /**
     Test that exception is thrown without passing in custom access token (and none in TokenManager).
     */
    func testAuthorizeFailsWithoutAccessToken() {
        testExpectation = expectation(description: "access token missing delegate call")
        let view = RideRequestView()
        view.delegate = self
        _ = TokenManager.deleteToken()
        
        view.load()
        
        waitForExpectations(timeout: timeout, handler: { error in
            XCTAssertEqual(self.error?.code, RideRequestViewErrorType.accessTokenMissing.rawValue)
            XCTAssertEqual(self.error?.domain, RideRequestViewErrorFactory.errorDomain)
            XCTAssertNil(error)
        })
    }

    func testRequestUsesCorrectSource_whenPresented() {
        testExpectation = expectation(description: "Test RideRequestView source call")
        
        let expectationClosure: (URLRequest) -> () = { request in
            self.testExpectation.fulfill()
            guard let url = request.url, let components = URLComponents(url: url, resolvingAgainstBaseURL: false), let items = components.queryItems else {
                XCTAssert(false)
                return
            }
            XCTAssertTrue(items.count > 0)
            var foundUserAgent = false
            for item in items {
                if (item.name == "user-agent") {
                    if let value = item.value {
                        foundUserAgent = true
                        XCTAssertTrue(value.contains(RideRequestView.sourceString))
                        break
                    }
                }
            }
            XCTAssert(foundUserAgent)
        }
        
        let testIdentifier = "testAccessTokenIdentifier"
        _ = TokenManager.deleteToken(identifier: testIdentifier)
        let testToken = AccessToken(tokenString: "testTokenString")
        _ = TokenManager.save(accessToken: testToken, tokenIdentifier: testIdentifier)
        defer {
            _ = TokenManager.deleteToken(identifier: testIdentifier)
        }
        
        let rideRequestView = RideRequestView(rideParameters: RideParametersBuilder().build(), accessToken: TokenManager.fetchToken(identifier: testIdentifier), frame: CGRect.zero)
        XCTAssertNotNil(rideRequestView)
        
        let webViewMock = WebViewMock(frame: CGRect.zero, configuration: WKWebViewConfiguration(), testClosure: expectationClosure)
        rideRequestView.webView.scrollView.delegate = nil
        rideRequestView.webView = webViewMock

        rideRequestView.load()
        
        
        waitForExpectations(timeout: timeout, handler: { error in
            XCTAssertNil(error)
        })
    }
    
    func testNotSupportedDelegateCalled_whenTel() {
        testExpectation = expectation(description: "Delegate called")
        let cancelRequestExpectation = expectation(description: "Request was cancelled")
        
        let rideRequestView = RideRequestView(rideParameters: RideParametersBuilder().build(), accessToken:nil, frame:CGRect.zero)
        rideRequestView.delegate = self
        let telURLString = "tel:5555555555"
        guard let telURL = URL(string: telURLString) else {
            XCTAssert(false)
            return
        }
        let telURLRequest = URLRequest(url: telURL)
        let navigationActionMock = WKNavigationActionMock(urlRequest: telURLRequest)
        
        if let delegate = rideRequestView.webView.navigationDelegate {
            delegate.webView!(rideRequestView.webView, decidePolicyFor: navigationActionMock, decisionHandler: { (policy: WKNavigationActionPolicy) -> Void in
                XCTAssertEqual(policy, WKNavigationActionPolicy.cancel)
                cancelRequestExpectation.fulfill()
            })
            
            waitForExpectations(timeout: timeout, handler: { error in
                XCTAssertNotNil(self.error)
                XCTAssertEqual(self.error?.code, RideRequestViewErrorType.notSupported.rawValue)
            })
        } else {
            XCTAssert(false)
        }
    }
}

private class WKNavigationActionMock : WKNavigationAction {
    override var request: URLRequest {
        return backingRequest
    }
    var backingRequest: URLRequest

    init(urlRequest: URLRequest) {
        backingRequest = urlRequest
        super.init()
    }
}

extension RideRequestViewTests: RideRequestViewDelegate {
    func rideRequestView(_ rideRequestView: RideRequestView, didReceiveError error: NSError) {
        self.error = error
        testExpectation.fulfill()
    }
}
