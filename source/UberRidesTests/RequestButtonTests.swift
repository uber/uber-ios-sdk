//
//  RequestButtonTests.swift
//  UberRidesTests
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
import CoreLocation
import WebKit
@testable import UberRides

class RequestButtonTests: XCTestCase {
    var button: RideRequestButton!
    var expectation: XCTestExpectation!
    let timeout: Double = 2
    
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
    
    /**
     Test that title is initialized properly to default value.
     */
    func testInitRequestButtonDefaultText() {
        button = RideRequestButton()
        XCTAssertEqual(button.uberTitleLabel.text!, "Ride there with Uber")
    }
    
    func testCorrectSource_whenRideRequestViewRequestingBehavior() {
        let expectation = expectationWithDescription("Test RideRequestView source parameter")
        
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
                        XCTAssertTrue(value.containsString(RideRequestButton.sourceString))
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
        let baseViewController = UIViewControllerMock()
        let requestBehavior = RideRequestViewRequestingBehavior(presentingViewController: baseViewController)
        let button = RideRequestButton(rideParameters: RideParametersBuilder().build(), requestingBehavior: requestBehavior)
    
        let loginManger = LoginManager(accessTokenIdentifier: testIdentifier)
        let rideRequestVC = RideRequestViewController(rideParameters: RideParametersBuilder().build(), loginManager: loginManger)
        XCTAssertNotNil(rideRequestVC.view)
        
        let webViewMock = WebViewMock(frame: CGRectZero, configuration: WKWebViewConfiguration(), testClosure: expectationClosure)
        rideRequestVC.rideRequestView.webView = webViewMock

        requestBehavior.modalRideRequestViewController.rideRequestViewController = rideRequestVC
        
        button.uberButtonTapped(button)
        
        waitForExpectationsWithTimeout(timeout, handler: { error in
            XCTAssertNil(error)
            XCTAssertTrue(rideRequestVC.loginView.hidden)
            XCTAssertFalse(rideRequestVC.rideRequestView.hidden)
        })
    }
    
    func testCorrectSource_whenDeeplinkRequestingBehavior() {
        let expectation = expectationWithDescription("Test Deeplink source parameter")
        
        let expectationClosure: (NSURL?) -> (Bool) = { url in
            expectation.fulfill()
            guard let url = url, let components = NSURLComponents(URL: url, resolvingAgainstBaseURL: false), let items = components.queryItems else {
                XCTAssert(false)
                return false
            }
            XCTAssertTrue(items.count > 0)
            var foundUserAgent = false
            for item in items {
                if (item.name == "user-agent") {
                    if let value = item.value {
                        foundUserAgent = true
                        XCTAssertTrue(value.containsString(RideRequestButton.sourceString))
                        break
                    }
                }
            }
            XCTAssert(foundUserAgent)
            return false
        }
        
        let requestBehavior = DeeplinkRequestingBehaviorMock(testClosure: expectationClosure)
        let button = RideRequestButton(rideParameters: RideParametersBuilder().build(), requestingBehavior: requestBehavior)
    
        button.uberButtonTapped(button)
        
        waitForExpectationsWithTimeout(timeout, handler: { error in
            XCTAssertNil(error)
        })
    }
    
}

private class UIViewControllerMock : UIViewController {
    override func presentViewController(viewControllerToPresent: UIViewController, animated flag: Bool, completion: (() -> Void)?) {
        viewControllerToPresent.viewWillAppear(flag)
        viewControllerToPresent.viewDidAppear(flag)
        
        if let modal = viewControllerToPresent as? ModalRideRequestViewController {
            modal.rideRequestViewController.viewWillAppear(flag)
            modal.rideRequestViewController.viewDidAppear(flag)
        }
        
        return
    }
}
