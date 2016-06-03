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
        Configuration.restoreDefaults()
        Configuration.plistName = "testInfo"
        Configuration.bundle = NSBundle(forClass: self.dynamicType)
        Configuration.setSandboxEnabled(true)
    }
    
    override func tearDown() {
        Configuration.restoreDefaults()
        super.tearDown()
    }
    
    func testAccessTokenMissing_whenNoAccessToken_loginFailed() {
        var expectation = false
        
        let expectationClosure: (RideRequestViewController, NSError) -> () = {vc, error in
            XCTAssertEqual(error.code, RideRequestViewErrorType.AccessTokenMissing.rawValue)
            XCTAssertEqual(error.domain, RideRequestViewErrorFactory.errorDomain)
            expectation = true
        }
        let loginManager = LoginManager(loginType: .Implicit)
        let rideRequestVC = RideRequestViewController(rideParameters: RideParametersBuilder().build(), loginManager: loginManager)
        let rideRequestVCDelegateMock = RideRequestViewControllerDelegateMock(testClosure: expectationClosure)
        rideRequestVC.delegate = rideRequestVCDelegateMock
        XCTAssertNotNil(rideRequestVC.view)
        rideRequestVC.loginView.loginAuthenticator.loginCompletion?(accessToken: nil, error: RidesAuthenticationErrorFactory.errorForType(ridesAuthenticationErrorType: .UnableToSaveAccessToken))
        
        XCTAssertTrue(expectation)
    }
    
    func testRideRequestViewLoads_withValidAccessToken() {
        var expectation = false
        
        let expectationClosure: () -> () = {
            expectation = true
        }
        let testIdentifier = "testAccessTokenIdentifier"
        let testToken = AccessToken(JSON: ["access_token" : "testTokenString"])
        TokenManager.saveToken(testToken!, tokenIdentifier: testIdentifier)
        defer {
            TokenManager.deleteToken(testIdentifier)
        }
        let loginManger = LoginManager(accessTokenIdentifier: testIdentifier, keychainAccessGroup: Configuration.getDefaultKeychainAccessGroup(), loginType: .Implicit)
        let rideRequestVC = RideRequestViewController(rideParameters: RideParametersBuilder().build(), loginManager: loginManger)
        rideRequestVC.rideRequestView = RideRequestViewMock(rideRequestView: rideRequestVC.rideRequestView, testClosure: expectationClosure)
        XCTAssertNotNil(rideRequestVC.view)
        rideRequestVC.load()
        
        XCTAssertTrue(rideRequestVC.loginView.hidden)
        XCTAssertFalse(rideRequestVC.rideRequestView.hidden)
        XCTAssertTrue(expectation)
    }
    
    func testLoginViewLoads_withNoAccessToken_usingImplicit() {
        var expectation = false
        
        let expectationClosure: () -> () = {
            expectation = true
        }
        let testIdentifier = "testAccessTokenIdentifier"
        TokenManager.deleteToken(testIdentifier)
        let loginManger = LoginManager(accessTokenIdentifier: testIdentifier, keychainAccessGroup: Configuration.getDefaultKeychainAccessGroup(), loginType: .Implicit)
        let rideRequestVC = RideRequestViewController(rideParameters: RideParametersBuilder().build(), loginManager: loginManger)

        XCTAssertNotNil(rideRequestVC.view)
        XCTAssertNotNil(rideRequestVC.loginView)
        rideRequestVC.loginView = LoginViewMock(loginBehavior: rideRequestVC.loginView.loginAuthenticator, testClosure: expectationClosure)
        
        rideRequestVC.load()
        
        XCTAssertFalse(rideRequestVC.loginView.hidden)
        XCTAssertTrue(rideRequestVC.rideRequestView.hidden)
        XCTAssertTrue(expectation)
    }
    
    func testNativeLoginLoads_withNoAccessToken_usingNative() {
        var expectation = false
        
        let testIdentifier = "testAccessTokenIdentifier"
        TokenManager.deleteToken(testIdentifier)
        let loginManger = LoginManager(accessTokenIdentifier: testIdentifier, keychainAccessGroup: Configuration.getDefaultKeychainAccessGroup(), loginType: .Native)
        let rideRequestVC = RideRequestViewControllerMock(rideParameters: RideParametersBuilder().build(), loginManager: loginManger)
        
        let expectationClosure: () -> () = {
            expectation = true
        }
        
        rideRequestVC.executeNativeClosure = expectationClosure
        
        XCTAssertNotNil(rideRequestVC.view)
        XCTAssertNotNil(rideRequestVC.loginView)
        
        rideRequestVC.load()
        
        XCTAssertTrue(expectation)
        XCTAssertFalse(rideRequestVC.loginView.hidden)
        XCTAssertFalse(rideRequestVC.rideRequestView.hidden)
    }
    
    func testLoginViewLoads_whenNativeUnavailable() {
        var expectation = true
        
        let testIdentifier = "testAccessTokenIdentifier"
        TokenManager.deleteToken(testIdentifier)
        let loginManger = LoginManager(accessTokenIdentifier: testIdentifier, keychainAccessGroup: Configuration.getDefaultKeychainAccessGroup(), loginType: .Native)
        let rideRequestVC = RideRequestViewControllerMock(rideParameters: RideParametersBuilder().build(), loginManager: loginManger)
        
        let expectationClosure: () -> () = {
            XCTAssertEqual(loginManger.loginType, LoginType.Implicit)
            expectation = true
        }
        
        rideRequestVC.executeNativeClosure = {
            rideRequestVC.loadClosure = expectationClosure
            rideRequestVC.nativeAuthenticator.loginCompletion?(accessToken: nil, error: RidesAuthenticationErrorFactory.errorForType(ridesAuthenticationErrorType: RidesAuthenticationErrorType.Unavailable))
        }
        
        XCTAssertNotNil(rideRequestVC.view)
        XCTAssertNotNil(rideRequestVC.loginView)
        
        rideRequestVC.load()
        
        XCTAssertEqual(loginManger.loginType, LoginType.Native)
        XCTAssertTrue(expectation)
    }
    
    func testWidgetLoads_whenNativeSuccess() {
        var expectation = false
        
        let testIdentifier = "testAccessTokenIdentifier"
        let testToken = AccessToken(JSON: ["access_token" : "test"])
        
        TokenManager.deleteToken(testIdentifier)
        let loginManger = LoginManager(accessTokenIdentifier: testIdentifier, keychainAccessGroup: Configuration.getDefaultKeychainAccessGroup(), loginType: .Native)
        let rideRequestVC = RideRequestViewControllerMock(rideParameters: RideParametersBuilder().build(), loginManager: loginManger)
        
        let expectationClosure: () -> () = {
            XCTAssertEqual(loginManger.loginType, LoginType.Native)
            expectation = true
        }
        
        rideRequestVC.executeNativeClosure = {
            rideRequestVC.loadClosure = expectationClosure
            rideRequestVC.nativeAuthenticator.loginCompletion?(accessToken: testToken, error: nil)
        }
        
        XCTAssertNotNil(rideRequestVC.view)
        XCTAssertNotNil(rideRequestVC.loginView)
        
        rideRequestVC.load()
        
        XCTAssertEqual(loginManger.loginType, LoginType.Native)
        XCTAssertTrue(rideRequestVC.loginView.hidden)
        XCTAssertFalse(rideRequestVC.rideRequestView.hidden)
        XCTAssertEqual(rideRequestVC.rideRequestView.accessToken, testToken)
        XCTAssertTrue(expectation)
    }
    
    func testLoginViewLoads_whenRideRequestViewErrors() {
        var expectation = false
        
        let expectationClosure: () -> () = {
            expectation = true
        }
        let testIdentifier = "testAccessTokenIdentifier"
        TokenManager.deleteToken(testIdentifier)
        let loginManger = LoginManager(accessTokenIdentifier: testIdentifier, keychainAccessGroup: Configuration.getDefaultKeychainAccessGroup(), loginType: .Implicit)
        let rideRequestVC = RideRequestViewController(rideParameters: RideParametersBuilder().build(), loginManager: loginManger)
        
        XCTAssertNotNil(rideRequestVC.view)
        XCTAssertNotNil(rideRequestVC.loginView)
        rideRequestVC.loginView = LoginViewMock(loginBehavior: rideRequestVC.loginView.loginAuthenticator, testClosure: expectationClosure)
        
        rideRequestVC.rideRequestView(rideRequestVC.rideRequestView, didReceiveError: RideRequestViewErrorFactory.errorForType(.AccessTokenExpired))
        
        XCTAssertFalse(rideRequestVC.loginView.hidden)
        XCTAssertTrue(rideRequestVC.rideRequestView.hidden)
        XCTAssertTrue(expectation)
    }
    
    func testLoginViewLoads_whenAuthenticationFails_whenViewControllerIsDismissed() {
        var expectation = false
        
        let expectationClosure: () -> () = {
            expectation = true
        }
        let testIdentifier = "testAccessTokenIdentifier"
        TokenManager.deleteToken(testIdentifier)
        let loginManger = LoginManager(accessTokenIdentifier: testIdentifier, keychainAccessGroup: Configuration.getDefaultKeychainAccessGroup(), loginType: .Implicit)
        let rideRequestVC = RideRequestViewController(rideParameters: RideParametersBuilder().build(), loginManager: loginManger)
        
        XCTAssertNotNil(rideRequestVC.view)
        XCTAssertNotNil(rideRequestVC.loginView)
        let loginMock = LoginViewMock(loginBehavior: rideRequestVC.loginView.loginAuthenticator, testClosure: nil)
        rideRequestVC.loginView = loginMock
        
        rideRequestVC.rideRequestView(rideRequestVC.rideRequestView, didReceiveError: RideRequestViewErrorFactory.errorForType(.AccessTokenExpired))
        rideRequestVC.viewWillDisappear(false)
        rideRequestVC.viewDidDisappear(false)
        
        loginMock.testClosure = expectationClosure
        
        rideRequestVC.viewWillAppear(false)
        rideRequestVC.viewDidAppear(false)
        
        XCTAssertFalse(rideRequestVC.loginView.hidden)
        XCTAssertTrue(rideRequestVC.rideRequestView.hidden)
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
        TokenManager.deleteToken(testIdentifier)
        let loginManger = LoginManager(accessTokenIdentifier: testIdentifier, keychainAccessGroup: Configuration.getDefaultKeychainAccessGroup(), loginType: .Implicit)
        let rideRequestVC = RideRequestViewController(rideParameters: RideParametersBuilder().build(), loginManager: loginManger)
        
        XCTAssertNotNil(rideRequestVC.view)
        XCTAssertNotNil(rideRequestVC.loginView)
        let loginMock = LoginViewMock(loginBehavior: rideRequestVC.loginView.loginAuthenticator, testClosure: expectationClosure)
        rideRequestVC.loginView = loginMock
        
        rideRequestVC.rideRequestView(rideRequestVC.rideRequestView, didReceiveError: RideRequestViewErrorFactory.errorForType(.AccessTokenExpired))
        
        loginMock.testClosure = failureClosure
        
        rideRequestVC.rideRequestView(rideRequestVC.rideRequestView, didReceiveError: RideRequestViewErrorFactory.errorForType(.AccessTokenExpired))
        
        XCTAssertFalse(rideRequestVC.loginView.hidden)
        XCTAssertTrue(rideRequestVC.rideRequestView.hidden)
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
        TokenManager.deleteToken(testIdentifier)
        let loginManger = LoginManager(accessTokenIdentifier: testIdentifier, keychainAccessGroup: Configuration.getDefaultKeychainAccessGroup(), loginType: .Implicit)
        let rideRequestVC = RideRequestViewController(rideParameters: RideParametersBuilder().build(), loginManager: loginManger)
        
        XCTAssertNotNil(rideRequestVC.view)
        XCTAssertNotNil(rideRequestVC.loginView)
        let loginMock = LoginViewMock(loginBehavior: rideRequestVC.loginView.loginAuthenticator, testClosure: loadExpectationClosure)
        rideRequestVC.loginView = loginMock
        
        rideRequestVC.rideRequestView(rideRequestVC.rideRequestView, didReceiveError: RideRequestViewErrorFactory.errorForType(.AccessTokenExpired))
        loginMock.testClosure = cancelLoadExpectationClosure
        
        rideRequestVC.viewWillDisappear(false)
        rideRequestVC.viewDidDisappear(false)
        
        XCTAssertFalse(rideRequestVC.loginView.hidden)
        XCTAssertTrue(rideRequestVC.rideRequestView.hidden)
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
        let testToken = AccessToken(JSON: ["access_token" : "testTokenString"])
        TokenManager.saveToken(testToken!, tokenIdentifier: testIdentifier)
        defer {
            TokenManager.deleteToken(testIdentifier)
        }
        let loginManager = LoginManager(accessTokenIdentifier: testIdentifier, keychainAccessGroup: Configuration.getDefaultKeychainAccessGroup(), loginType: .Implicit)
        let rideRequestVC = RideRequestViewController(rideParameters: RideParametersBuilder().build(), loginManager: loginManager)
        let requestViewMock = RideRequestViewMock(rideRequestView: rideRequestVC.rideRequestView, testClosure: loadExpectationClosure)
        rideRequestVC.rideRequestView = requestViewMock
        XCTAssertNotNil(rideRequestVC.view)
        rideRequestVC.load()
        
        requestViewMock.testClosure = cancelLoadExpectationClosure
        
        rideRequestVC.viewWillDisappear(false)
        rideRequestVC.viewDidDisappear(false)
        
        XCTAssertTrue(rideRequestVC.loginView.hidden)
        XCTAssertFalse(rideRequestVC.rideRequestView.hidden)
        XCTAssertTrue(loadExpectation)
        XCTAssertTrue(cancelLoadExpectation)
    }
    
    func testRequestUsesCorrectSource_whenPresented() {
        var expectation = false
        
        let expectationClosure: (NSURLRequest) -> () = { request in
            expectation = true
            guard let url = request.URL, let components = NSURLComponents(URL: url, resolvingAgainstBaseURL: false), let items = components.queryItems else {
                XCTAssert(false)
                return
            }
            XCTAssertTrue(items.count > 0)
            var foundUserAgent = false
            for item in items {
                if (item.name == "user-agent") {
                    if let value = item.value {
                        foundUserAgent = true
                        XCTAssertTrue(value.containsString(RideRequestViewController.sourceString))
                        break
                    }
                }
            }
            XCTAssert(foundUserAgent)
        }
        
        let testIdentifier = "testAccessTokenIdentifier"
        let testToken = AccessToken(JSON: ["access_token" : "testTokenString"])
        TokenManager.saveToken(testToken!, tokenIdentifier: testIdentifier)
        defer {
            TokenManager.deleteToken(testIdentifier)
        }
        let loginManger = LoginManager(accessTokenIdentifier: testIdentifier, keychainAccessGroup: Configuration.getDefaultKeychainAccessGroup(), loginType: .Implicit)
        let rideRequestVC = RideRequestViewController(rideParameters: RideParametersBuilder().build(), loginManager: loginManger)
        XCTAssertNotNil(rideRequestVC.view)
        
        let webViewMock = WebViewMock(frame: CGRectZero, configuration: WKWebViewConfiguration(), testClosure: expectationClosure)
        rideRequestVC.rideRequestView.webView = webViewMock
        
        rideRequestVC.load()
        
        XCTAssertTrue(rideRequestVC.loginView.hidden)
        XCTAssertFalse(rideRequestVC.rideRequestView.hidden)
        XCTAssertTrue(expectation)
    }
    
    func testPresentNetworkErrorAlert_whenValidAccessToken_whenNetworkError() {
        var expectation = false
        
        let networkClosure: () -> () = {
            expectation = true
        }
        let testIdentifier = "testAccessTokenIdentifier"
        let testToken = AccessToken(JSON: ["access_token" : "testTokenString"])
        TokenManager.saveToken(testToken!, tokenIdentifier: testIdentifier)
        defer {
            TokenManager.deleteToken(testIdentifier)
        }
        let loginManager = LoginManager(accessTokenIdentifier: testIdentifier, keychainAccessGroup: Configuration.getDefaultKeychainAccessGroup(), loginType: .Implicit)
        
        let rideRequestViewControllerMock = RideRequestViewControllerMock(rideParameters: RideParametersBuilder().build(), loginManager: loginManager, loadClosure: nil, networkClosure: networkClosure, presentViewControllerClosure: nil)
        
        rideRequestViewControllerMock.rideRequestView(rideRequestViewControllerMock.rideRequestView, didReceiveError: RideRequestViewErrorFactory.errorForType(.NetworkError))
        
        XCTAssertTrue(expectation)
    }
    
    func testPresentNetworkErrorAlert_whenNoAccessToken_whenNetworkError() {
        var expectation = false
        
        let networkClosure: () -> () = {
            expectation = true
        }
        let testIdentifier = "testAccessTokenIdentifier"
        TokenManager.deleteToken(testIdentifier)
        
        let loginManager = LoginManager(accessTokenIdentifier: testIdentifier, keychainAccessGroup: Configuration.getDefaultKeychainAccessGroup(), loginType: .Implicit)
        
        let rideRequestViewControllerMock = RideRequestViewControllerMock(rideParameters: RideParametersBuilder().build(), loginManager: loginManager, loadClosure: nil, networkClosure: networkClosure, presentViewControllerClosure: nil)
        
        rideRequestViewControllerMock.rideRequestView(rideRequestViewControllerMock.rideRequestView, didReceiveError: RideRequestViewErrorFactory.errorForType(.NetworkError))
        
        XCTAssertTrue(expectation)
    }
    
    func testPresentNetworkErrorAlert_cancelsLoads_presentsAlertView() {
        var expectation = false
        var loginLoadExpecation = false
        var requestViewExpectation = false
        
        let presentViewControllerClosure: ((UIViewController, Bool, (() -> Void)?) -> ()) = { (viewController, flag, completion) in
            expectation = true
            XCTAssertTrue(viewController.dynamicType == UIAlertController.self)
        }
        let testIdentifier = "testAccessTokenIdentifier"
        let testToken = AccessToken(JSON: ["access_token" : "testTokenString"])
        TokenManager.saveToken(testToken!, tokenIdentifier: testIdentifier)
        defer {
            TokenManager.deleteToken(testIdentifier)
        }
        let loginManager = LoginManager(accessTokenIdentifier: testIdentifier, keychainAccessGroup: Configuration.getDefaultKeychainAccessGroup(), loginType: .Implicit)
        
        let rideRequestViewControllerMock = RideRequestViewControllerMock(rideParameters: RideParametersBuilder().build(), loginManager: loginManager, loadClosure: nil, networkClosure: nil, presentViewControllerClosure: presentViewControllerClosure)
        
        let loginAuthenticator = LoginViewAuthenticator(presentingViewController: UIViewController(), scopes: [])
        let loginViewMock = LoginViewMock(loginBehavior: loginAuthenticator) { () -> () in
            loginLoadExpecation = true
        }
        
        let requestViewMock = RideRequestViewMock(rideRequestView: rideRequestViewControllerMock.rideRequestView) { () -> () in
            requestViewExpectation = true
        }
        
        rideRequestViewControllerMock.rideRequestView = requestViewMock
        rideRequestViewControllerMock.loginView = loginViewMock
        
        rideRequestViewControllerMock.rideRequestView(rideRequestViewControllerMock.rideRequestView, didReceiveError: RideRequestViewErrorFactory.errorForType(.NetworkError))
        
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
        TokenManager.deleteToken(testIdentifier)
        
        let loginManager = LoginManager(accessTokenIdentifier: testIdentifier, keychainAccessGroup: Configuration.getDefaultKeychainAccessGroup(), loginType: .Implicit)
        
        let rideRequestViewControllerMock = RideRequestViewControllerMock(rideParameters: RideParametersBuilder().build(), loginManager: loginManager, notSupportedClosure: notSupportedClosure)
        
        rideRequestViewControllerMock.rideRequestView(rideRequestViewControllerMock.rideRequestView, didReceiveError: RideRequestViewErrorFactory.errorForType(.NotSupported))
        
        XCTAssertTrue(expectation)
    }
    
    func testPresentNotSupportedErrorAlert_presentsAlertView() {
        var expectation = false
        
        let presentViewControllerClosure: ((UIViewController, Bool, (() -> Void)?) -> ()) = { (viewController, flag, completion) in
            expectation = true
            XCTAssertTrue(viewController.dynamicType == UIAlertController.self)
        }
        
        let testIdentifier = "testAccessTokenIdentifier"
        TokenManager.deleteToken(testIdentifier)
        
        let loginManager = LoginManager(accessTokenIdentifier: testIdentifier, keychainAccessGroup: Configuration.getDefaultKeychainAccessGroup(), loginType: .Implicit)
        
        let rideRequestViewControllerMock = RideRequestViewControllerMock(rideParameters: RideParametersBuilder().build(), loginManager: loginManager, presentViewControllerClosure: presentViewControllerClosure)
        
        rideRequestViewControllerMock.rideRequestView(rideRequestViewControllerMock.rideRequestView, didReceiveError: RideRequestViewErrorFactory.errorForType(.NotSupported))
        
        XCTAssertTrue(expectation)
    }
}
