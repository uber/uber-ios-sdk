//
//  RideRequestViewControllerTests.swift
//  UberRides
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
import CoreLocation
import WebKit
@testable import UberAuth
@testable import UberCore
@testable import UberRides

class RideRequestViewControllerTests: XCTestCase {
    private let timeout: Double = 2
    private let testIdentifier = "testAccessTokenIdentifier"
    private let tokenManager = TokenManager()
    private var accessGroup: String { TokenManager.defaultKeychainAccessGroup }
    
    override func setUp() {
        super.setUp()
        tokenManager.deleteToken(identifier: testIdentifier, accessGroup: accessGroup)
    }

    func testRideRequestViewLoads_withValidAccessToken() {
        var expectation = false

        let expectationClosure: () -> () = {
            expectation = true
        }
        let accessGroup = TokenManager.defaultKeychainAccessGroup
        let testToken = AccessToken(tokenString: "testTokenString")
        tokenManager.saveToken(testToken, identifier: testIdentifier, accessGroup: accessGroup)
        defer {
            tokenManager.deleteToken(identifier: testIdentifier, accessGroup: accessGroup)
        }
        let rideRequestVC = RideRequestViewController(
            rideParameters: RideParametersBuilder().build(),
            accessTokenIdentifier: testIdentifier,
            keychainAccessGroup: accessGroup
        )
        rideRequestVC.rideRequestView = RideRequestViewMock(rideRequestView: rideRequestVC.rideRequestView, testClosure: expectationClosure)
        XCTAssertNotNil(rideRequestVC.view)
        rideRequestVC.load()

        XCTAssertFalse(rideRequestVC.rideRequestView.isHidden)
        XCTAssertTrue(expectation)
    }

    func testLoginViewLoads_whenNoAccessToken() {
        tokenManager.deleteToken(identifier: testIdentifier, accessGroup: accessGroup)
        let rideRequestVC = RideRequestViewControllerMock(rideParameters: RideParametersBuilder().build())

        XCTAssertNotNil(rideRequestVC.view)

        rideRequestVC.load()

//        XCTAssert(loginManager.loggingIn)
    }

    func testRequestUsesCorrectSource_whenPresented() {
        var expectation = false

        let expectationClosure: (URLRequest) -> () = { request in
            expectation = true
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
                        XCTAssertTrue(value.contains(RideRequestViewController.sourceString))
                        break
                    }
                }
            }
            XCTAssert(foundUserAgent)
        }

        let testToken = AccessToken(tokenString: "testTokenString")
        tokenManager.saveToken(testToken, identifier: testIdentifier, accessGroup: accessGroup)
        defer {
            tokenManager.deleteToken(identifier: testIdentifier, accessGroup: accessGroup)
        }
        let rideRequestVC = RideRequestViewController(
            rideParameters: RideParametersBuilder().build(),
            accessTokenIdentifier: testIdentifier,
            keychainAccessGroup: accessGroup
        )
        
        XCTAssertNotNil(rideRequestVC.view)

        let webViewMock = WebViewMock(frame: CGRect.zero, configuration: WKWebViewConfiguration(), testClosure: expectationClosure)
        rideRequestVC.rideRequestView.webView = webViewMock

        rideRequestVC.load()

        XCTAssertFalse(rideRequestVC.rideRequestView.isHidden)
        XCTAssertTrue(expectation)
    }

    func testPresentNetworkErrorAlert_whenValidAccessToken_whenNetworkError() {
        var expectation = false

        let networkClosure: () -> () = {
            expectation = true
        }
        let testToken = AccessToken(tokenString: "testTokenString")
        tokenManager.saveToken(testToken, identifier: testIdentifier, accessGroup: accessGroup)
        defer {
            tokenManager.deleteToken(identifier: testIdentifier, accessGroup: accessGroup)
        }

        let rideRequestViewControllerMock = RideRequestViewControllerMock(rideParameters: RideParametersBuilder().build(), loadClosure: nil, networkClosure: networkClosure, presentViewControllerClosure: nil)

        (rideRequestViewControllerMock as RideRequestViewDelegate).rideRequestView(rideRequestViewControllerMock.rideRequestView, didReceiveError: RideRequestViewErrorFactory.errorForType(.networkError))

        XCTAssertTrue(expectation)
    }

    func testPresentNetworkErrorAlert_whenNoAccessToken_whenNetworkError() {
        var expectation = false

        let networkClosure: () -> () = {
            expectation = true
        }
        tokenManager.deleteToken(identifier: testIdentifier, accessGroup: accessGroup)

        let rideRequestViewControllerMock = RideRequestViewControllerMock(rideParameters: RideParametersBuilder().build(), loadClosure: nil, networkClosure: networkClosure, presentViewControllerClosure: nil)

        (rideRequestViewControllerMock as RideRequestViewDelegate).rideRequestView(rideRequestViewControllerMock.rideRequestView, didReceiveError: RideRequestViewErrorFactory.errorForType(.networkError))

        XCTAssertTrue(expectation)
    }

    func testPresentNetworkErrorAlert_cancelsLoads_presentsAlertView() {
        var expectation = false
        var requestViewExpectation = false

        let presentViewControllerClosure: ((UIViewController, Bool, (() -> Void)?) -> ()) = { (viewController, flag, completion) in
            expectation = true
            XCTAssertTrue(type(of: viewController) == UIAlertController.self)
        }
        let testToken = AccessToken(tokenString: "testTokenString")
        tokenManager.saveToken(testToken, identifier: testIdentifier, accessGroup: accessGroup)
        defer {
            tokenManager.deleteToken(identifier: testIdentifier, accessGroup: accessGroup)
        }

        let rideRequestViewControllerMock = RideRequestViewControllerMock(rideParameters: RideParametersBuilder().build(), loadClosure: nil, networkClosure: nil, presentViewControllerClosure: presentViewControllerClosure)

        let requestViewMock = RideRequestViewMock(rideRequestView: rideRequestViewControllerMock.rideRequestView) { () -> () in
            requestViewExpectation = true
        }

        rideRequestViewControllerMock.rideRequestView = requestViewMock

        (rideRequestViewControllerMock as RideRequestViewDelegate).rideRequestView(rideRequestViewControllerMock.rideRequestView, didReceiveError: RideRequestViewErrorFactory.errorForType(.networkError))

        XCTAssertTrue(expectation)
        XCTAssertTrue(requestViewExpectation)
    }

    func testPresentNotSupportedErrorAlert_whenNotSupportedError() {
        var expectation = false

        let notSupportedClosure: () -> () = {
            expectation = true
        }
        tokenManager.deleteToken(identifier: testIdentifier, accessGroup: accessGroup)

        let rideRequestViewControllerMock = RideRequestViewControllerMock(rideParameters: RideParametersBuilder().build(), notSupportedClosure: notSupportedClosure)

        (rideRequestViewControllerMock as RideRequestViewDelegate).rideRequestView(rideRequestViewControllerMock.rideRequestView, didReceiveError: RideRequestViewErrorFactory.errorForType(.notSupported))

        XCTAssertTrue(expectation)
    }

    func testPresentNotSupportedErrorAlert_presentsAlertView() {
        var expectation = false

        let presentViewControllerClosure: ((UIViewController, Bool, (() -> Void)?) -> ()) = { (viewController, flag, completion) in
            expectation = true
            XCTAssertTrue(type(of: viewController) == UIAlertController.self)
        }

        tokenManager.deleteToken(identifier: testIdentifier, accessGroup: accessGroup)

        let rideRequestViewControllerMock = RideRequestViewControllerMock(rideParameters: RideParametersBuilder().build(), presentViewControllerClosure: presentViewControllerClosure)

        (rideRequestViewControllerMock as RideRequestViewDelegate).rideRequestView(rideRequestViewControllerMock.rideRequestView, didReceiveError: RideRequestViewErrorFactory.errorForType(.notSupported))

        XCTAssertTrue(expectation)
    }
}

