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
        let expectation = expectationWithDescription("Test Token Missing delegate call")
        
        let expectationClosure: (RideRequestViewController, NSError) -> () = {vc, error in
            XCTAssertEqual(error.code, RideRequestViewErrorType.AccessTokenMissing.rawValue)
            XCTAssertEqual(error.domain, RideRequestViewErrorFactory.errorDomain)
            expectation.fulfill()
        }
        let loginManager = LoginManager()
        let rideRequestVC = RideRequestViewController(rideParameters: RideParametersBuilder().build(), loginManager: loginManager)
        let rideRequestVCDelegateMock = RideRequestViewControllerDelegateMock(testClosure: expectationClosure)
        rideRequestVC.delegate = rideRequestVCDelegateMock
        XCTAssertNotNil(rideRequestVC.view)
        rideRequestVC.loginManager.loginView(LoginView(scopes: [ RidesScope.RideWidgets ]), didFailWithError: RidesAuthenticationErrorFactory.errorForType(ridesAuthenticationErrorType: .UnableToSaveAccessToken))
        
        waitForExpectationsWithTimeout(timeout, handler: { error in
            XCTAssertNil(error)
        })
    }
    
    func testRideRequestViewLoads_withValidAccessToken() {
        let expectation = expectationWithDescription("Test RideRequestView load() call")
        
        let expectationClosure: () -> () = {
            expectation.fulfill()
        }
        let testIdentifier = "testAccessTokenIdentifier"
        let testToken = AccessToken(JSON: ["access_token" : "testTokenString"])
        TokenManager.saveToken(testToken!, tokenIdentifier: testIdentifier)
        defer {
            TokenManager.deleteToken(testIdentifier)
        }
        let loginManger = LoginManager(accessTokenIdentifier: testIdentifier)
        let rideRequestVC = RideRequestViewController(rideParameters: RideParametersBuilder().build(), loginManager: loginManger)
        rideRequestVC.rideRequestView = RideRequestViewMock(rideRequestView: rideRequestVC.rideRequestView, testClosure: expectationClosure)
        XCTAssertNotNil(rideRequestVC.view)
        rideRequestVC.load()
        
        
        waitForExpectationsWithTimeout(timeout, handler: { error in
            XCTAssertNil(error)
            XCTAssertTrue(rideRequestVC.loginView.hidden)
            XCTAssertFalse(rideRequestVC.rideRequestView.hidden)
        })
    }
    
    func testLoginViewLoads_withNoAccessToken() {
        let expectation = expectationWithDescription("Test LoginView load() call")
        
        let expectationClosure: () -> () = {
            expectation.fulfill()
        }
        let testIdentifier = "testAccessTokenIdentifier"
        TokenManager.deleteToken(testIdentifier)
        let loginManger = LoginManager(accessTokenIdentifier: testIdentifier)
        let rideRequestVC = RideRequestViewController(rideParameters: RideParametersBuilder().build(), loginManager: loginManger)

        XCTAssertNotNil(rideRequestVC.view)
        XCTAssertNotNil(rideRequestVC.loginView)
        rideRequestVC.loginView = LoginViewMock(scopes: rideRequestVC.loginView.scopes!, testClosure: expectationClosure)
        
        rideRequestVC.load()
        
        
        waitForExpectationsWithTimeout(timeout, handler: { error in
            XCTAssertNil(error)
            XCTAssertFalse(rideRequestVC.loginView.hidden)
            XCTAssertTrue(rideRequestVC.rideRequestView.hidden)
        })
    }
    
    func testLoginViewLoads_whenRideRequestViewErrors() {
        let expectation = expectationWithDescription("Test LoginView load() call")
        
        let expectationClosure: () -> () = {
            expectation.fulfill()
        }
        let testIdentifier = "testAccessTokenIdentifier"
        TokenManager.deleteToken(testIdentifier)
        let loginManger = LoginManager(accessTokenIdentifier: testIdentifier)
        let rideRequestVC = RideRequestViewController(rideParameters: RideParametersBuilder().build(), loginManager: loginManger)
        
        XCTAssertNotNil(rideRequestVC.view)
        XCTAssertNotNil(rideRequestVC.loginView)
        rideRequestVC.loginView = LoginViewMock(scopes: rideRequestVC.loginView.scopes!, testClosure: expectationClosure)
        
        rideRequestVC.rideRequestView(rideRequestVC.rideRequestView, didReceiveError: RideRequestViewErrorFactory.errorForType(.AccessTokenExpired))
        
        
        waitForExpectationsWithTimeout(timeout, handler: { error in
            XCTAssertNil(error)
            XCTAssertFalse(rideRequestVC.loginView.hidden)
            XCTAssertTrue(rideRequestVC.rideRequestView.hidden)
        })
    }
    
    func testLoginViewLoads_whenAuthenticationFails_whenViewControllerIsDismissed() {
        let expectation = expectationWithDescription("Test LoginView load() call")
        
        let expectationClosure: () -> () = {
            expectation.fulfill()
        }
        let testIdentifier = "testAccessTokenIdentifier"
        TokenManager.deleteToken(testIdentifier)
        let loginManger = LoginManager(accessTokenIdentifier: testIdentifier)
        let rideRequestVC = RideRequestViewController(rideParameters: RideParametersBuilder().build(), loginManager: loginManger)
        
        XCTAssertNotNil(rideRequestVC.view)
        XCTAssertNotNil(rideRequestVC.loginView)
        let loginMock = LoginViewMock(scopes: rideRequestVC.loginView.scopes!, testClosure: nil)
        rideRequestVC.loginView = loginMock
        
        rideRequestVC.rideRequestView(rideRequestVC.rideRequestView, didReceiveError: RideRequestViewErrorFactory.errorForType(.AccessTokenExpired))
        rideRequestVC.viewWillDisappear(false)
        rideRequestVC.viewDidDisappear(false)
        
        loginMock.testClosure = expectationClosure
        
        rideRequestVC.viewWillAppear(false)
        rideRequestVC.viewDidAppear(false)
        
        
        waitForExpectationsWithTimeout(timeout, handler: { error in
            XCTAssertNil(error)
            XCTAssertFalse(rideRequestVC.loginView.hidden)
            XCTAssertTrue(rideRequestVC.rideRequestView.hidden)
        })
    }
    
    func testLoginViewSkipsLoad_whenAuthenticationFailsTwice() {
        let expectation = expectationWithDescription("Test LoginView load() call")
        
        let expectationClosure: () -> () = {
            expectation.fulfill()
        }
        
        let failureClosure: () -> () = {
            XCTAssert(false)
        }
        
        let testIdentifier = "testAccessTokenIdentifier"
        TokenManager.deleteToken(testIdentifier)
        let loginManger = LoginManager(accessTokenIdentifier: testIdentifier)
        let rideRequestVC = RideRequestViewController(rideParameters: RideParametersBuilder().build(), loginManager: loginManger)
        
        XCTAssertNotNil(rideRequestVC.view)
        XCTAssertNotNil(rideRequestVC.loginView)
        let loginMock = LoginViewMock(scopes: rideRequestVC.loginView.scopes!, testClosure: expectationClosure)
        rideRequestVC.loginView = loginMock
        
        rideRequestVC.rideRequestView(rideRequestVC.rideRequestView, didReceiveError: RideRequestViewErrorFactory.errorForType(.AccessTokenExpired))
        
        loginMock.testClosure = failureClosure
        
        rideRequestVC.rideRequestView(rideRequestVC.rideRequestView, didReceiveError: RideRequestViewErrorFactory.errorForType(.AccessTokenExpired))
        
        waitForExpectationsWithTimeout(timeout, handler: { error in
            XCTAssertNil(error)
            XCTAssertFalse(rideRequestVC.loginView.hidden)
            XCTAssertTrue(rideRequestVC.rideRequestView.hidden)
        })
    }
    
    
    func testLoginViewStopsLoading_whenRideRequestViewControllerDismissed() {
        let loadExpectation = expectationWithDescription("Test LoginView load() call")
        let cancelLoadExpectation = expectationWithDescription("Test LoginView cancelLoad() call")
        
        let loadExpectationClosure: () -> () = {
            loadExpectation.fulfill()
        }
        
        let cancelLoadExpectationClosure: () -> () = {
            cancelLoadExpectation.fulfill()
        }
        
        let testIdentifier = "testAccessTokenIdentifier"
        TokenManager.deleteToken(testIdentifier)
        let loginManger = LoginManager(accessTokenIdentifier: testIdentifier)
        let rideRequestVC = RideRequestViewController(rideParameters: RideParametersBuilder().build(), loginManager: loginManger)
        
        XCTAssertNotNil(rideRequestVC.view)
        XCTAssertNotNil(rideRequestVC.loginView)
        let loginMock = LoginViewMock(scopes: rideRequestVC.loginView.scopes!, testClosure: loadExpectationClosure)
        rideRequestVC.loginView = loginMock
        
        rideRequestVC.rideRequestView(rideRequestVC.rideRequestView, didReceiveError: RideRequestViewErrorFactory.errorForType(.AccessTokenExpired))
        loginMock.testClosure = cancelLoadExpectationClosure
        
        rideRequestVC.viewWillDisappear(false)
        rideRequestVC.viewDidDisappear(false)
        
        waitForExpectationsWithTimeout(timeout, handler: { error in
            XCTAssertNil(error)
            XCTAssertFalse(rideRequestVC.loginView.hidden)
            XCTAssertTrue(rideRequestVC.rideRequestView.hidden)
        })
    }
    
    func testRequestViewStopsLoading_whenRideRequestViewControllerDismissed() {
        let loadExpectation = expectationWithDescription("Test RideRequestView load() call")
        let cancelLoadExpectation = expectationWithDescription("Test RideRequestView cancelLoad() call")
        
        let loadExpectationClosure: () -> () = {
            loadExpectation.fulfill()
        }
        
        let cancelLoadExpectationClosure: () -> () = {
            cancelLoadExpectation.fulfill()
        }
        
        let testIdentifier = "testAccessTokenIdentifier"
        let testToken = AccessToken(JSON: ["access_token" : "testTokenString"])
        TokenManager.saveToken(testToken!, tokenIdentifier: testIdentifier)
        defer {
            TokenManager.deleteToken(testIdentifier)
        }
        let loginManager = LoginManager(accessTokenIdentifier: testIdentifier)
        let rideRequestVC = RideRequestViewController(rideParameters: RideParametersBuilder().build(), loginManager: loginManager)
        let requestViewMock = RideRequestViewMock(rideRequestView: rideRequestVC.rideRequestView, testClosure: loadExpectationClosure)
        rideRequestVC.rideRequestView = requestViewMock
        XCTAssertNotNil(rideRequestVC.view)
        rideRequestVC.load()
        
        requestViewMock.testClosure = cancelLoadExpectationClosure
        
        rideRequestVC.viewWillDisappear(false)
        rideRequestVC.viewDidDisappear(false)
        
        waitForExpectationsWithTimeout(timeout, handler: { error in
            XCTAssertNil(error)
            XCTAssertTrue(rideRequestVC.loginView.hidden)
            XCTAssertFalse(rideRequestVC.rideRequestView.hidden)
        })
    }
    
    func testRequestUsesCorrectSource_whenPresented() {
        let expectation = expectationWithDescription("Test RideRequestView load() call")
        
        let expectationClosure: (NSURLRequest) -> () = { request in
            expectation.fulfill()
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
        let loginManger = LoginManager(accessTokenIdentifier: testIdentifier)
        let rideRequestVC = RideRequestViewController(rideParameters: RideParametersBuilder().build(), loginManager: loginManger)
        XCTAssertNotNil(rideRequestVC.view)
        
        let webViewMock = WebViewMock(frame: CGRectZero, configuration: WKWebViewConfiguration(), testClosure: expectationClosure)
        rideRequestVC.rideRequestView.webView = webViewMock
        
        rideRequestVC.load()
        
        
        waitForExpectationsWithTimeout(timeout, handler: { error in
            XCTAssertNil(error)
            XCTAssertTrue(rideRequestVC.loginView.hidden)
            XCTAssertFalse(rideRequestVC.rideRequestView.hidden)
        })
    }
    
    func testPresentNetworkErrorAlert_whenValidAccessToken_whenNetworkError() {
        let expectation = expectationWithDescription("Test presentNetworkAlert() call")
        
        let networkClosure: () -> () = {
            expectation.fulfill()
        }
        let testIdentifier = "testAccessTokenIdentifier"
        let testToken = AccessToken(JSON: ["access_token" : "testTokenString"])
        TokenManager.saveToken(testToken!, tokenIdentifier: testIdentifier)
        defer {
            TokenManager.deleteToken(testIdentifier)
        }
        let loginManager = LoginManager(accessTokenIdentifier: testIdentifier)
        
        let rideRequestViewControllerMock = RideRequestViewControllerMock(rideParameters: RideParametersBuilder().build(), loginManager: loginManager, loadClosure: nil, networkClosure: networkClosure, presentViewControllerClosure: nil)
        
        rideRequestViewControllerMock.rideRequestView(rideRequestViewControllerMock.rideRequestView, didReceiveError: RideRequestViewErrorFactory.errorForType(.NetworkError))
        
        waitForExpectationsWithTimeout(timeout, handler: { error in
            XCTAssertNil(error)
        })
    }
    
    func testPresentNetworkErrorAlert_whenNoAccessToken_whenNetworkError() {
        let expectation = expectationWithDescription("Test presentNetworkAlert() call")
        
        let networkClosure: () -> () = {
            expectation.fulfill()
        }
        let testIdentifier = "testAccessTokenIdentifier"
        TokenManager.deleteToken(testIdentifier)
        
        let loginManager = LoginManager(accessTokenIdentifier: testIdentifier)
        
        let rideRequestViewControllerMock = RideRequestViewControllerMock(rideParameters: RideParametersBuilder().build(), loginManager: loginManager, loadClosure: nil, networkClosure: networkClosure, presentViewControllerClosure: nil)
        
        rideRequestViewControllerMock.rideRequestView(rideRequestViewControllerMock.rideRequestView, didReceiveError: RideRequestViewErrorFactory.errorForType(.NetworkError))
        
        waitForExpectationsWithTimeout(timeout, handler: { error in
            XCTAssertNil(error)
        })
    }
    
    func testPresentNetworkErrorAlert_cancelsLoads_presentsAlertView() {
        let expectation = expectationWithDescription("Test presentNetworkAlert() call")
        let loginLoadExpecation = expectationWithDescription("LoginView cancelLoad() call")
        let requestViewExpectation = expectationWithDescription("RequestView cancelLoad() call")
        
        let presentViewControllerClosure: ((UIViewController, Bool, (() -> Void)?) -> ()) = { (viewController, flag, completion) in
            expectation.fulfill()
            XCTAssertTrue(viewController.dynamicType == UIAlertController.self)
        }
        let testIdentifier = "testAccessTokenIdentifier"
        let testToken = AccessToken(JSON: ["access_token" : "testTokenString"])
        TokenManager.saveToken(testToken!, tokenIdentifier: testIdentifier)
        defer {
            TokenManager.deleteToken(testIdentifier)
        }
        let loginManager = LoginManager(accessTokenIdentifier: testIdentifier)
        
        let rideRequestViewControllerMock = RideRequestViewControllerMock(rideParameters: RideParametersBuilder().build(), loginManager: loginManager, loadClosure: nil, networkClosure: nil, presentViewControllerClosure: presentViewControllerClosure)
        
        let loginViewMock = LoginViewMock(scopes: []) { () -> () in
            loginLoadExpecation.fulfill()
        }
        
        let requestViewMock = RideRequestViewMock(rideRequestView: rideRequestViewControllerMock.rideRequestView) { () -> () in
            requestViewExpectation.fulfill()
        }
        
        rideRequestViewControllerMock.rideRequestView = requestViewMock
        rideRequestViewControllerMock.loginView = loginViewMock
        
        rideRequestViewControllerMock.rideRequestView(rideRequestViewControllerMock.rideRequestView, didReceiveError: RideRequestViewErrorFactory.errorForType(.NetworkError))
        
        waitForExpectationsWithTimeout(timeout, handler: { error in
            XCTAssertNil(error)
        })
    }
    
}
