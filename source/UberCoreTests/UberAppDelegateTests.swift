//
//  RidesAppDelegateTests.swift
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
@testable import UberCore

class UberAppDelegateTests : XCTestCase {
    
    private var versionNumber: String?
    private var expectedDeeplinkUserAgent: String?
    private var expectedButtonUserAgent: String?
    
    override func setUp() {
        super.setUp()
        Configuration.plistName = "testInfo"
        Configuration.restoreDefaults()
        Configuration.shared.clientID = "testClientID"
        Configuration.shared.isSandbox = true
        versionNumber = Bundle(for: UberAppDelegate.self).object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String
        expectedDeeplinkUserAgent = "rides-ios-v\(versionNumber!)-deeplink"
        expectedButtonUserAgent = "rides-ios-v\(versionNumber!)-button"
    }
    
    override func tearDown() {
        Configuration.restoreDefaults()
        super.tearDown()
        
    }
    
    func testOpenUrlReturnsFalse_whenNoLoginManager() {
        let appDelegate = UberAppDelegate.shared
        
        let testApp = UIApplication.shared
        guard let url = URL(string: "http://www.google.com") else {
            XCTFail()
            return
        }
        
        XCTAssertFalse(appDelegate.application(testApp, open: url, sourceApplication: nil, annotation: ""))
    }
    
    func testOpenUrlReturnsTrue_callsOpenURLOnLoginManager() {
        let expectation = self.expectation(description: "open URL called")
        let appDelegate = UberAppDelegate.shared
        let loginManagerMock = LoginManagingProtocolMock()
        let testApp = UIApplication.shared
        guard let testURL = URL(string: "http://www.google.com") else {
            XCTFail()
            return
        }
        let testSourceApplication = "testSource"
        let testAnnotation = "annotation"
        
        let urlClosure: ((UIApplication, URL, String?, Any?) -> Bool) = { application, url, source, annotation in
            XCTAssertEqual(application, testApp)
            XCTAssertEqual(url, testURL)
            XCTAssertEqual(source, testSourceApplication)
            XCTAssertEqual(annotation as? String, testAnnotation)
            expectation.fulfill()
            return true
        }
        
        loginManagerMock.openURLClosure = urlClosure
        appDelegate.loginManager = loginManagerMock
        XCTAssertTrue(appDelegate.application(testApp, open: testURL, sourceApplication: testSourceApplication, annotation: testAnnotation))
        XCTAssertNil(appDelegate.loginManager)
        waitForExpectations(timeout: 0.2, handler: nil)
    }
    
    func testDidFinishLaunchingReturnsFalse_whenNoLaunchOptions() {
        let appDelegate = UberAppDelegate.shared
        let testApp = UIApplication.shared
        XCTAssertFalse(appDelegate.application(testApp, didFinishLaunchingWithOptions: nil))
    }
    
    func testDidFinishLaunchingCallsOpenURL_whenLaunchURL() {
        let expectation = self.expectation(description: "open URL called")
        let appDelegate = UberAppDelegate.shared
        let testApp = UIApplication.shared
        let loginManagerMock = LoginManagingProtocolMock()
        guard let testURL = URL(string: "http://www.google.com") else {
            XCTFail()
            return
        }
        let testSourceApplication = "testSource"
        let testAnnotation = "annotation"
        var launchOptions = [UIApplicationLaunchOptionsKey: Any]()
        launchOptions[UIApplicationLaunchOptionsKey.url] = testURL as Any
        launchOptions[UIApplicationLaunchOptionsKey.sourceApplication] = testSourceApplication as Any
        launchOptions[UIApplicationLaunchOptionsKey.annotation] = testAnnotation as Any
        
        let urlClosure: ((UIApplication, URL, String?, Any?) -> Bool) = { application, url, source, annotation in
            XCTAssertEqual(application, testApp)
            XCTAssertEqual(url, testURL)
            XCTAssertEqual(source, testSourceApplication)
            XCTAssertEqual(annotation as? String, testAnnotation)
            expectation.fulfill()
            return true
        }
        
        loginManagerMock.openURLClosure = urlClosure
        appDelegate.loginManager = loginManagerMock
        XCTAssertTrue(appDelegate.application(testApp, didFinishLaunchingWithOptions: launchOptions))
        XCTAssertNil(appDelegate.loginManager)
        waitForExpectations(timeout: 0.2, handler: nil)
    }
    
    func testDidBecomeActiveCallsLoginManager_whenDidBecomeActiveNotification() {
        let expectation = self.expectation(description: "didBecomeActive called")
        let appDelegate = UberAppDelegate.shared
        let loginManagerMock = LoginManagingProtocolMock()
        
        let didBecomeActiveClosure: () -> () = {
            expectation.fulfill()
        }
        
        loginManagerMock.didBecomeActiveClosure = didBecomeActiveClosure
        appDelegate.loginManager = loginManagerMock

        NotificationCenter.default.post(name: NSNotification.Name.UIApplicationWillEnterForeground, object: nil)
        NotificationCenter.default.post(name: NSNotification.Name.UIApplicationDidBecomeActive, object: nil)
        
        waitForExpectations(timeout: 0.2)
    }
    
}
