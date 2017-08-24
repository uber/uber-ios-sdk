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
@testable import UberRides

class RideRequestViewControllerTests: XCTestCase {
    private let timeout: Double = 2
    
    override func setUp() {
        super.setUp()
        Configuration.bundle = Bundle(for: type(of: self))
        Configuration.plistName = "testInfo"
        Configuration.restoreDefaults()
        Configuration.shared.isSandbox = true
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
        let rideRequestVC = RideRequestViewController(rideParameters: RideParameters(), loginManager: loginManager)
        let rideRequestVCDelegateMock = RideRequestViewControllerDelegateMock(testClosure: expectationClosure)
        rideRequestVC.delegate = rideRequestVCDelegateMock
        XCTAssertNotNil(rideRequestVC.view)
        rideRequestVC.loginView.loginAuthenticator.loginCompletion?(nil, RidesAuthenticationErrorFactory.errorForType(ridesAuthenticationErrorType: .unableToSaveAccessToken))
        
        XCTAssertTrue(expectation)
    }
    
    func testRideRequestViewLoads_withValidAccessToken() {
        var expectation = false
        
        let expectationClosure: () -> () = {
            expectation = true
        }
        let testIdentifier = "testAccessTokenIdentifier"
        let testToken = AccessToken(tokenString: "testTokenString")
        _ = TokenManager.save(accessToken: testToken, tokenIdentifier: testIdentifier)
        defer {
            _ = TokenManager.deleteToken(identifier: testIdentifier)
        }
        let loginManger = LoginManager(accessTokenIdentifier: testIdentifier, keychainAccessGroup: Configuration.shared.defaultKeychainAccessGroup, loginType: .implicit)
        let rideRequestVC = RideRequestViewController(rideParameters: RideParameters(), loginManager: loginManger)
        rideRequestVC.rideRequestView = RideRequestViewMock(rideRequestView: rideRequestVC.rideRequestView, testClosure: expectationClosure)
        XCTAssertNotNil(rideRequestVC.view)
        rideRequestVC.load()
        
        XCTAssertTrue(rideRequestVC.loginView.isHidden)
        XCTAssertFalse(rideRequestVC.rideRequestView.isHidden)
        XCTAssertTrue(expectation)
    }
    
    func testLoginViewLoads_withNoAccessToken_usingImplicit() {
        var expectation = false
        
        let expectationClosure: () -> () = {
            expectation = true
        }
        let testIdentifier = "testAccessTokenIdentifier"
        _ = TokenManager.deleteToken(identifier: testIdentifier)
        let loginManger = LoginManager(accessTokenIdentifier: testIdentifier, keychainAccessGroup: Configuration.shared.defaultKeychainAccessGroup, loginType: .implicit)
        let rideRequestVC = RideRequestViewController(rideParameters: RideParameters(), loginManager: loginManger)

        XCTAssertNotNil(rideRequestVC.view)
        XCTAssertNotNil(rideRequestVC.loginView)
        rideRequestVC.loginView = LoginViewMock(loginBehavior: rideRequestVC.loginView.loginAuthenticator, testClosure: expectationClosure)
        
        rideRequestVC.load()
        
        XCTAssertFalse(rideRequestVC.loginView.isHidden)
        XCTAssertTrue(rideRequestVC.rideRequestView.isHidden)
        XCTAssertTrue(expectation)
    }
    
    func testNativeLoginLoads_withNoAccessToken_usingNative() {
        var expectation = false
        
        let testIdentifier = "testAccessTokenIdentifier"
        _ = TokenManager.deleteToken(identifier: testIdentifier)
        let loginManger = LoginManager(accessTokenIdentifier: testIdentifier, keychainAccessGroup: Configuration.shared.defaultKeychainAccessGroup, loginType: .native)
        let rideRequestVC = RideRequestViewControllerMock(rideParameters: RideParameters(), loginManager: loginManger)
        
        let expectationClosure: () -> () = {
            expectation = true
        }
        
        rideRequestVC.executeNativeClosure = expectationClosure
        
        XCTAssertNotNil(rideRequestVC.view)
        XCTAssertNotNil(rideRequestVC.loginView)
        
        rideRequestVC.load()
        
        XCTAssertTrue(expectation)
        XCTAssertFalse(rideRequestVC.loginView.isHidden)
        XCTAssertFalse(rideRequestVC.rideRequestView.isHidden)
    }
    
    func testLoginViewLoads_whenNativeUnavailable() {
        var expectation = true
        
        let testIdentifier = "testAccessTokenIdentifier"
        _ = TokenManager.deleteToken(identifier: testIdentifier)
        let loginManger = LoginManager(accessTokenIdentifier: testIdentifier, keychainAccessGroup: Configuration.shared.defaultKeychainAccessGroup, loginType: .native)
        let rideRequestVC = RideRequestViewControllerMock(rideParameters: RideParameters(), loginManager: loginManger)
        
        let expectationClosure: () -> () = {
            XCTAssertEqual(loginManger.loginType, LoginType.implicit)
            expectation = true
        }
        
        rideRequestVC.executeNativeClosure = {
            rideRequestVC.loadClosure = expectationClosure
            rideRequestVC.nativeAuthenticator.loginCompletion?(nil, RidesAuthenticationErrorFactory.errorForType(ridesAuthenticationErrorType: RidesAuthenticationErrorType.unavailable))
        }
        
        XCTAssertNotNil(rideRequestVC.view)
        XCTAssertNotNil(rideRequestVC.loginView)
        
        rideRequestVC.load()
        
        XCTAssertEqual(loginManger.loginType, LoginType.native)
        XCTAssertTrue(expectation)
    }
    
    func testWidgetLoads_whenNativeSuccess() {
        var expectation = false
        
        let testIdentifier = "testAccessTokenIdentifier"
        let testToken = AccessToken(tokenString: "test")
        
        _ = TokenManager.deleteToken(identifier: testIdentifier)
        let loginManger = LoginManager(accessTokenIdentifier: testIdentifier, keychainAccessGroup: Configuration.shared.defaultKeychainAccessGroup, loginType: .native)
        let rideRequestVC = RideRequestViewControllerMock(rideParameters: RideParameters(), loginManager: loginManger)
        
        let expectationClosure: () -> () = {
            XCTAssertEqual(loginManger.loginType, LoginType.native)
            expectation = true
        }
        
        rideRequestVC.executeNativeClosure = {
            rideRequestVC.loadClosure = expectationClosure
            rideRequestVC.nativeAuthenticator.loginCompletion?(testToken, nil)
        }
        
        XCTAssertNotNil(rideRequestVC.view)
        XCTAssertNotNil(rideRequestVC.loginView)
        
        rideRequestVC.load()
        
        XCTAssertEqual(loginManger.loginType, LoginType.native)
        XCTAssertTrue(rideRequestVC.loginView.isHidden)
        XCTAssertFalse(rideRequestVC.rideRequestView.isHidden)
        XCTAssertEqual(rideRequestVC.rideRequestView.accessToken, testToken)
        XCTAssertTrue(expectation)
    }
    
    func testLoginViewLoads_whenRideRequestViewErrors() {
        var expectation = false
        
        let expectationClosure: () -> () = {
            expectation = true
        }
        let testIdentifier = "testAccessTokenIdentifier"
        _ = TokenManager.deleteToken(identifier: testIdentifier)
        let loginManger = LoginManager(accessTokenIdentifier: testIdentifier, keychainAccessGroup: Configuration.shared.defaultKeychainAccessGroup, loginType: .implicit)
        let rideRequestVC = RideRequestViewController(rideParameters: RideParameters(), loginManager: loginManger)
        
        XCTAssertNotNil(rideRequestVC.view)
        XCTAssertNotNil(rideRequestVC.loginView)
        rideRequestVC.loginView = LoginViewMock(loginBehavior: rideRequestVC.loginView.loginAuthenticator, testClosure: expectationClosure)
        
        (rideRequestVC as RideRequestViewDelegate).rideRequestView(rideRequestVC.rideRequestView, didReceiveError: RideRequestViewErrorFactory.errorForType(.accessTokenExpired))
        
        XCTAssertFalse(rideRequestVC.loginView.isHidden)
        XCTAssertTrue(rideRequestVC.rideRequestView.isHidden)
        XCTAssertTrue(expectation)
    }
    
    func testLoginViewLoads_whenAuthenticationFails_whenViewControllerIsDismissed() {
        var expectation = false
        
        let expectationClosure: () -> () = {
            expectation = true
        }
        let testIdentifier = "testAccessTokenIdentifier"
        _ = TokenManager.deleteToken(identifier: testIdentifier)
        let loginManger = LoginManager(accessTokenIdentifier: testIdentifier, keychainAccessGroup: Configuration.shared.defaultKeychainAccessGroup, loginType: .implicit)
        let rideRequestVC = RideRequestViewController(rideParameters: RideParameters(), loginManager: loginManger)
        
        XCTAssertNotNil(rideRequestVC.view)
        XCTAssertNotNil(rideRequestVC.loginView)
        let loginMock = LoginViewMock(loginBehavior: rideRequestVC.loginView.loginAuthenticator, testClosure: nil)
        rideRequestVC.loginView = loginMock
        
        (rideRequestVC as RideRequestViewDelegate).rideRequestView(rideRequestVC.rideRequestView, didReceiveError: RideRequestViewErrorFactory.errorForType(.accessTokenExpired))
        rideRequestVC.viewWillDisappear(false)
        rideRequestVC.viewDidDisappear(false)
        
        loginMock.testClosure = expectationClosure
        
        rideRequestVC.viewWillAppear(false)
        rideRequestVC.viewDidAppear(false)
        
        XCTAssertFalse(rideRequestVC.loginView.isHidden)
        XCTAssertTrue(rideRequestVC.rideRequestView.isHidden)
        XCTAssertTrue(expectation)
    }
    
    func testLoginViewSkipsLoad_whenAuthenticationFailsTwice() {
        var expectation = false
        
        let expectationClosure: () -> () = {
            expectation = true
        }
        
        let failureClosure: () -> () = {
            XCTAssert(false)
        }
        
        let testIdentifier = "testAccessTokenIdentifier"
        _ = TokenManager.deleteToken(identifier: testIdentifier)
        let loginManger = LoginManager(accessTokenIdentifier: testIdentifier, keychainAccessGroup: Configuration.shared.defaultKeychainAccessGroup, loginType: .implicit)
        let rideRequestVC = RideRequestViewController(rideParameters: RideParameters(), loginManager: loginManger)
        
        XCTAssertNotNil(rideRequestVC.view)
        XCTAssertNotNil(rideRequestVC.loginView)
        let loginMock = LoginViewMock(loginBehavior: rideRequestVC.loginView.loginAuthenticator, testClosure: expectationClosure)
        rideRequestVC.loginView = loginMock
        
        (rideRequestVC as RideRequestViewDelegate).rideRequestView(rideRequestVC.rideRequestView, didReceiveError: RideRequestViewErrorFactory.errorForType(.accessTokenExpired))
        
        loginMock.testClosure = failureClosure
        
        (rideRequestVC as RideRequestViewDelegate).rideRequestView(rideRequestVC.rideRequestView, didReceiveError: RideRequestViewErrorFactory.errorForType(.accessTokenExpired))
        
        XCTAssertFalse(rideRequestVC.loginView.isHidden)
        XCTAssertTrue(rideRequestVC.rideRequestView.isHidden)
        XCTAssertTrue(expectation)
    }
    
    
    func testLoginViewStopsLoading_whenRideRequestViewControllerDismissed() {
        var loadExpectation = false
        var cancelLoadExpectation = false
        
        let loadExpectationClosure: () -> () = {
            loadExpectation = true
        }
        
        let cancelLoadExpectationClosure: () -> () = {
            cancelLoadExpectation = true
        }
        
        let testIdentifier = "testAccessTokenIdentifier"
        _ = TokenManager.deleteToken(identifier: testIdentifier)
        let loginManger = LoginManager(accessTokenIdentifier: testIdentifier, keychainAccessGroup: Configuration.shared.defaultKeychainAccessGroup, loginType: .implicit)
        let rideRequestVC = RideRequestViewController(rideParameters: RideParameters(), loginManager: loginManger)
        
        XCTAssertNotNil(rideRequestVC.view)
        XCTAssertNotNil(rideRequestVC.loginView)
        let loginMock = LoginViewMock(loginBehavior: rideRequestVC.loginView.loginAuthenticator, testClosure: loadExpectationClosure)
        rideRequestVC.loginView = loginMock
        
        (rideRequestVC as RideRequestViewDelegate).rideRequestView(rideRequestVC.rideRequestView, didReceiveError: RideRequestViewErrorFactory.errorForType(.accessTokenExpired))
        loginMock.testClosure = cancelLoadExpectationClosure
        
        rideRequestVC.viewWillDisappear(false)
        rideRequestVC.viewDidDisappear(false)
        
        XCTAssertFalse(rideRequestVC.loginView.isHidden)
        XCTAssertTrue(rideRequestVC.rideRequestView.isHidden)
        XCTAssertTrue(loadExpectation)
        XCTAssertTrue(cancelLoadExpectation)
    }
    
    func testRequestViewStopsLoading_whenRideRequestViewControllerDismissed() {
        var loadExpectation = false
        var cancelLoadExpectation = false
        
        let loadExpectationClosure: () -> () = {
            loadExpectation = true
        }
        
        let cancelLoadExpectationClosure: () -> () = {
            cancelLoadExpectation = true
        }
        
        let testIdentifier = "testAccessTokenIdentifier"
        let testToken = AccessToken(tokenString: "testTokenString")
        _ = TokenManager.save(accessToken: testToken, tokenIdentifier: testIdentifier)
        defer {
            _ = TokenManager.deleteToken(identifier: testIdentifier)
        }
        let loginManager = LoginManager(accessTokenIdentifier: testIdentifier, keychainAccessGroup: Configuration.shared.defaultKeychainAccessGroup, loginType: .implicit)
        let rideRequestVC = RideRequestViewController(rideParameters: RideParameters(), loginManager: loginManager)
        let requestViewMock = RideRequestViewMock(rideRequestView: rideRequestVC.rideRequestView, testClosure: loadExpectationClosure)
        rideRequestVC.rideRequestView = requestViewMock
        XCTAssertNotNil(rideRequestVC.view)
        rideRequestVC.load()
        
        requestViewMock.testClosure = cancelLoadExpectationClosure
        
        rideRequestVC.viewWillDisappear(false)
        rideRequestVC.viewDidDisappear(false)
        
        XCTAssertTrue(rideRequestVC.loginView.isHidden)
        XCTAssertFalse(rideRequestVC.rideRequestView.isHidden)
        XCTAssertTrue(loadExpectation)
        XCTAssertTrue(cancelLoadExpectation)
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
        
        let testIdentifier = "testAccessTokenIdentifier"
        let testToken = AccessToken(tokenString: "testTokenString")
        _ = TokenManager.save(accessToken: testToken, tokenIdentifier: testIdentifier)
        defer {
            _ = TokenManager.deleteToken(identifier: testIdentifier)
        }
        let loginManger = LoginManager(accessTokenIdentifier: testIdentifier, keychainAccessGroup: Configuration.shared.defaultKeychainAccessGroup, loginType: .implicit)
        let rideRequestVC = RideRequestViewController(rideParameters: RideParameters(), loginManager: loginManger)
        XCTAssertNotNil(rideRequestVC.view)
        
        let webViewMock = WebViewMock(frame: CGRect.zero, configuration: WKWebViewConfiguration(), testClosure: expectationClosure)
        rideRequestVC.rideRequestView.webView = webViewMock
        
        rideRequestVC.load()
        
        XCTAssertTrue(rideRequestVC.loginView.isHidden)
        XCTAssertFalse(rideRequestVC.rideRequestView.isHidden)
        XCTAssertTrue(expectation)
    }
    
    func testPresentNetworkErrorAlert_whenValidAccessToken_whenNetworkError() {
        var expectation = false
        
        let networkClosure: () -> () = {
            expectation = true
        }
        let testIdentifier = "testAccessTokenIdentifier"
        let testToken = AccessToken(tokenString: "testTokenString")
        _ = TokenManager.save(accessToken: testToken, tokenIdentifier: testIdentifier)
        defer {
            _ = TokenManager.deleteToken(identifier: testIdentifier)
        }
        let loginManager = LoginManager(accessTokenIdentifier: testIdentifier, keychainAccessGroup: Configuration.shared.defaultKeychainAccessGroup, loginType: .implicit)
        
        let rideRequestViewControllerMock = RideRequestViewControllerMock(rideParameters: RideParameters(), loginManager: loginManager, loadClosure: nil, networkClosure: networkClosure, presentViewControllerClosure: nil)
        
        (rideRequestViewControllerMock as RideRequestViewDelegate).rideRequestView(rideRequestViewControllerMock.rideRequestView, didReceiveError: RideRequestViewErrorFactory.errorForType(.networkError))
        
        XCTAssertTrue(expectation)
    }
    
    func testPresentNetworkErrorAlert_whenNoAccessToken_whenNetworkError() {
        var expectation = false
        
        let networkClosure: () -> () = {
            expectation = true
        }
        let testIdentifier = "testAccessTokenIdentifier"
        _ = TokenManager.deleteToken(identifier: testIdentifier)
        
        let loginManager = LoginManager(accessTokenIdentifier: testIdentifier, keychainAccessGroup: Configuration.shared.defaultKeychainAccessGroup, loginType: .implicit)
        
        let rideRequestViewControllerMock = RideRequestViewControllerMock(rideParameters: RideParameters(), loginManager: loginManager, loadClosure: nil, networkClosure: networkClosure, presentViewControllerClosure: nil)
        
        (rideRequestViewControllerMock as RideRequestViewDelegate).rideRequestView(rideRequestViewControllerMock.rideRequestView, didReceiveError: RideRequestViewErrorFactory.errorForType(.networkError))
        
        XCTAssertTrue(expectation)
    }
    
    func testPresentNetworkErrorAlert_cancelsLoads_presentsAlertView() {
        var expectation = false
        var loginLoadExpecation = false
        var requestViewExpectation = false
        
        let presentViewControllerClosure: ((UIViewController, Bool, (() -> Void)?) -> ()) = { (viewController, flag, completion) in
            expectation = true
            XCTAssertTrue(type(of: viewController) == UIAlertController.self)
        }
        let testIdentifier = "testAccessTokenIdentifier"
        let testToken = AccessToken(tokenString: "testTokenString")
        _ = TokenManager.save(accessToken: testToken, tokenIdentifier: testIdentifier)
        defer {
            _ = TokenManager.deleteToken(identifier: testIdentifier)
        }
        let loginManager = LoginManager(accessTokenIdentifier: testIdentifier, keychainAccessGroup: Configuration.shared.defaultKeychainAccessGroup, loginType: .implicit)
        
        let rideRequestViewControllerMock = RideRequestViewControllerMock(rideParameters: RideParameters(), loginManager: loginManager, loadClosure: nil, networkClosure: nil, presentViewControllerClosure: presentViewControllerClosure)
        
        let loginAuthenticator = LoginViewAuthenticator(presentingViewController: UIViewController(), scopes: [])
        let loginViewMock = LoginViewMock(loginBehavior: loginAuthenticator) { () -> () in
            loginLoadExpecation = true
        }
        
        let requestViewMock = RideRequestViewMock(rideRequestView: rideRequestViewControllerMock.rideRequestView) { () -> () in
            requestViewExpectation = true
        }
        
        rideRequestViewControllerMock.rideRequestView = requestViewMock
        rideRequestViewControllerMock.loginView = loginViewMock
        
        (rideRequestViewControllerMock as RideRequestViewDelegate).rideRequestView(rideRequestViewControllerMock.rideRequestView, didReceiveError: RideRequestViewErrorFactory.errorForType(.networkError))
        
        XCTAssertTrue(expectation)
        XCTAssertTrue(loginLoadExpecation)
        XCTAssertTrue(requestViewExpectation)
    }
    
    func testPresentNotSupportedErrorAlert_whenNotSupportedError() {
        var expectation = false
        
        let notSupportedClosure: () -> () = {
            expectation = true
        }
        let testIdentifier = "testAccessTokenIdentifier"
        _ = TokenManager.deleteToken(identifier: testIdentifier)
        
        let loginManager = LoginManager(accessTokenIdentifier: testIdentifier, keychainAccessGroup: Configuration.shared.defaultKeychainAccessGroup, loginType: .implicit)
        
        let rideRequestViewControllerMock = RideRequestViewControllerMock(rideParameters: RideParameters(), loginManager: loginManager, notSupportedClosure: notSupportedClosure)
        
        (rideRequestViewControllerMock as RideRequestViewDelegate).rideRequestView(rideRequestViewControllerMock.rideRequestView, didReceiveError: RideRequestViewErrorFactory.errorForType(.notSupported))
        
        XCTAssertTrue(expectation)
    }
    
    func testPresentNotSupportedErrorAlert_presentsAlertView() {
        var expectation = false
        
        let presentViewControllerClosure: ((UIViewController, Bool, (() -> Void)?) -> ()) = { (viewController, flag, completion) in
            expectation = true
            XCTAssertTrue(type(of: viewController) == UIAlertController.self)
        }
        
        let testIdentifier = "testAccessTokenIdentifier"
        _ = TokenManager.deleteToken(identifier: testIdentifier)
        
        let loginManager = LoginManager(accessTokenIdentifier: testIdentifier, keychainAccessGroup: Configuration.shared.defaultKeychainAccessGroup, loginType: .implicit)
        
        let rideRequestViewControllerMock = RideRequestViewControllerMock(rideParameters: RideParameters(), loginManager: loginManager, presentViewControllerClosure: presentViewControllerClosure)
        
        (rideRequestViewControllerMock as RideRequestViewDelegate).rideRequestView(rideRequestViewControllerMock.rideRequestView, didReceiveError: RideRequestViewErrorFactory.errorForType(.notSupported))
        
        XCTAssertTrue(expectation)
    }

    func testNativeLogin_handlesError_whenAccessTokenAndErrorAreNotNil() {
        let testIdentifier = "testAccessTokenIdentifier"
        let loginManger = LoginManager(accessTokenIdentifier: testIdentifier, keychainAccessGroup: Configuration.shared.defaultKeychainAccessGroup, loginType: .native)
        let rideRequestVC = RideRequestViewController(rideParameters: RideParameters(), loginManager: loginManger)
        var delegateCalled = false
        let mock = RideRequestViewControllerDelegateMock { (_, _) in
            delegateCalled = true
        }
        rideRequestVC.delegate = mock

        let accessToken = AccessToken(tokenString: "testToken")
        let error = RidesAuthenticationErrorFactory.errorForType(ridesAuthenticationErrorType: .unableToSaveAccessToken)

        XCTAssertNotNil(rideRequestVC.view)

        rideRequestVC.nativeAuthenticator.loginCompletion?(accessToken, error)

        XCTAssertTrue(delegateCalled)
    }

    func testImplicitLogin_handlesError_whenAccessTokenAndErrorAreNotNil() {
        let testIdentifier = "testAccessTokenIdentifier"
        let loginManger = LoginManager(accessTokenIdentifier: testIdentifier, keychainAccessGroup: Configuration.shared.defaultKeychainAccessGroup, loginType: .implicit)
        let rideRequestVC = RideRequestViewController(rideParameters: RideParameters(), loginManager: loginManger)
        var delegateCalled = false
        let mock = RideRequestViewControllerDelegateMock { (_, _) in
            delegateCalled = true
        }
        rideRequestVC.delegate = mock

        let accessToken = AccessToken(tokenString: "testToken")
        let error = RidesAuthenticationErrorFactory.errorForType(ridesAuthenticationErrorType: .unableToSaveAccessToken)

        XCTAssertNotNil(rideRequestVC.view)

        loginManger.authenticator?.loginCompletion?(accessToken, error)

        XCTAssertTrue(delegateCalled)
    }
}
