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
@testable import UberCore
@testable import UberRides

class RideRequestViewControllerTests: XCTestCase {
    private let timeout: Double = 2
    private let testIdentifier = "testAccessTokenIdentifier"

    override func setUp() {
        super.setUp()
        Configuration.plistName = "testInfo"
        Configuration.restoreDefaults()
        Configuration.shared.isSandbox = true
        _ = TokenManager.deleteToken(identifier: testIdentifier)
    }

    override func tearDown() {
        Configuration.restoreDefaults()
        super.tearDown()
    }

    func testAccessTokenMissing_whenNoAccessToken_loginFailed() {
        var expectation = false

        let expectationClosure: (RideRequestViewController, NSError) -> () = {vc, error in
            XCTAssertEqual(error.code, RideRequestViewErrorType.accessTokenMissing.rawValue)
            XCTAssertEqual(error.domain, RideRequestViewErrorFactory.errorDomain)
            expectation = true
        }
        let loginManager = LoginManager(loginType: .implicit)
        let rideRequestVC = RideRequestViewController(rideParameters: RideParametersBuilder().build(), loginManager: loginManager)
        let rideRequestVCDelegateMock = RideRequestViewControllerDelegateMock(testClosure: expectationClosure)
        rideRequestVC.delegate = rideRequestVCDelegateMock
        XCTAssertNotNil(rideRequestVC.view)
        rideRequestVC.load()
        loginManager.loginCompletion(accessToken: nil, error: UberAuthenticationErrorFactory.errorForType(ridesAuthenticationErrorType: .unableToSaveAccessToken))

        XCTAssertTrue(expectation)
    }

    func testRideRequestViewLoads_withValidAccessToken() {
        var expectation = false

        let expectationClosure: () -> () = {
            expectation = true
        }
        let testToken = AccessToken(tokenString: "testTokenString")
        _ = TokenManager.save(accessToken: testToken, tokenIdentifier: testIdentifier)
        defer {
            _ = TokenManager.deleteToken(identifier: testIdentifier)
        }
        let loginManager = LoginManager(accessTokenIdentifier: testIdentifier, keychainAccessGroup: Configuration.shared.defaultKeychainAccessGroup, loginType: .implicit)
        let rideRequestVC = RideRequestViewController(rideParameters: RideParametersBuilder().build(), loginManager: loginManager)
        rideRequestVC.rideRequestView = RideRequestViewMock(rideRequestView: rideRequestVC.rideRequestView, testClosure: expectationClosure)
        XCTAssertNotNil(rideRequestVC.view)
        rideRequestVC.load()

        XCTAssertFalse(rideRequestVC.rideRequestView.isHidden)
        XCTAssertTrue(expectation)
    }

    func testLoginViewLoads_whenNoAccessToken() {
        _ = TokenManager.deleteToken(identifier: testIdentifier)
        let loginManager = LoginManager(accessTokenIdentifier: testIdentifier, keychainAccessGroup: Configuration.shared.defaultKeychainAccessGroup, loginType: .native)
        let rideRequestVC = RideRequestViewControllerMock(rideParameters: RideParametersBuilder().build(), loginManager: loginManager)

        XCTAssertNotNil(rideRequestVC.view)

        rideRequestVC.load()

        XCTAssert(loginManager.loggingIn)
    }

    func testWidgetLoads_whenLoginSuccess() {
        let testToken = AccessToken(tokenString: "test")

        _ = TokenManager.deleteToken(identifier: testIdentifier)
        let loginManager = LoginManager(accessTokenIdentifier: testIdentifier, keychainAccessGroup: Configuration.shared.defaultKeychainAccessGroup, loginType: .native)
        let rideRequestVC = RideRequestViewControllerMock(rideParameters: RideParametersBuilder().build(), loginManager: loginManager)

        XCTAssertNotNil(rideRequestVC.view)

        rideRequestVC.load()
        loginManager.loginCompletion(accessToken: testToken, error: nil)

        XCTAssertFalse(rideRequestVC.rideRequestView.isHidden)
        XCTAssertEqual(rideRequestVC.rideRequestView.accessToken, testToken)
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
        _ = TokenManager.save(accessToken: testToken, tokenIdentifier: testIdentifier)
        defer {
            _ = TokenManager.deleteToken(identifier: testIdentifier)
        }
        let loginManager = LoginManager(accessTokenIdentifier: testIdentifier, keychainAccessGroup: Configuration.shared.defaultKeychainAccessGroup, loginType: .implicit)
        let rideRequestVC = RideRequestViewController(rideParameters: RideParametersBuilder().build(), loginManager: loginManager)
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
        _ = TokenManager.save(accessToken: testToken, tokenIdentifier: testIdentifier)
        defer {
            _ = TokenManager.deleteToken(identifier: testIdentifier)
        }
        let loginManager = LoginManager(accessTokenIdentifier: testIdentifier, keychainAccessGroup: Configuration.shared.defaultKeychainAccessGroup, loginType: .implicit)

        let rideRequestViewControllerMock = RideRequestViewControllerMock(rideParameters: RideParametersBuilder().build(), loginManager: loginManager, loadClosure: nil, networkClosure: networkClosure, presentViewControllerClosure: nil)

        (rideRequestViewControllerMock as RideRequestViewDelegate).rideRequestView(rideRequestViewControllerMock.rideRequestView, didReceiveError: RideRequestViewErrorFactory.errorForType(.networkError))

        XCTAssertTrue(expectation)
    }

    func testPresentNetworkErrorAlert_whenNoAccessToken_whenNetworkError() {
        var expectation = false

        let networkClosure: () -> () = {
            expectation = true
        }
        _ = TokenManager.deleteToken(identifier: testIdentifier)

        let loginManager = LoginManager(accessTokenIdentifier: testIdentifier, keychainAccessGroup: Configuration.shared.defaultKeychainAccessGroup, loginType: .implicit)

        let rideRequestViewControllerMock = RideRequestViewControllerMock(rideParameters: RideParametersBuilder().build(), loginManager: loginManager, loadClosure: nil, networkClosure: networkClosure, presentViewControllerClosure: nil)

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
        _ = TokenManager.save(accessToken: testToken, tokenIdentifier: testIdentifier)
        defer {
            _ = TokenManager.deleteToken(identifier: testIdentifier)
        }
        let loginManager = LoginManager(accessTokenIdentifier: testIdentifier, keychainAccessGroup: Configuration.shared.defaultKeychainAccessGroup, loginType: .implicit)

        let rideRequestViewControllerMock = RideRequestViewControllerMock(rideParameters: RideParametersBuilder().build(), loginManager: loginManager, loadClosure: nil, networkClosure: nil, presentViewControllerClosure: presentViewControllerClosure)

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
        _ = TokenManager.deleteToken(identifier: testIdentifier)

        let loginManager = LoginManager(accessTokenIdentifier: testIdentifier, keychainAccessGroup: Configuration.shared.defaultKeychainAccessGroup, loginType: .implicit)

        let rideRequestViewControllerMock = RideRequestViewControllerMock(rideParameters: RideParametersBuilder().build(), loginManager: loginManager, notSupportedClosure: notSupportedClosure)

        (rideRequestViewControllerMock as RideRequestViewDelegate).rideRequestView(rideRequestViewControllerMock.rideRequestView, didReceiveError: RideRequestViewErrorFactory.errorForType(.notSupported))

        XCTAssertTrue(expectation)
    }

    func testPresentNotSupportedErrorAlert_presentsAlertView() {
        var expectation = false

        let presentViewControllerClosure: ((UIViewController, Bool, (() -> Void)?) -> ()) = { (viewController, flag, completion) in
            expectation = true
            XCTAssertTrue(type(of: viewController) == UIAlertController.self)
        }

        _ = TokenManager.deleteToken(identifier: testIdentifier)

        let loginManager = LoginManager(accessTokenIdentifier: testIdentifier, keychainAccessGroup: Configuration.shared.defaultKeychainAccessGroup, loginType: .implicit)

        let rideRequestViewControllerMock = RideRequestViewControllerMock(rideParameters: RideParametersBuilder().build(), loginManager: loginManager, presentViewControllerClosure: presentViewControllerClosure)

        (rideRequestViewControllerMock as RideRequestViewDelegate).rideRequestView(rideRequestViewControllerMock.rideRequestView, didReceiveError: RideRequestViewErrorFactory.errorForType(.notSupported))

        XCTAssertTrue(expectation)
    }
}

