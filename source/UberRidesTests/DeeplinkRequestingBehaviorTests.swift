//
//  DeeplinkRequestingBehaviorTests.swift
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
@testable import UberRides

class DeeplinkRequestingBehaviorTests : XCTestCase {
    
    private var versionNumber: String?
    private var expectedDeeplinkUserAgent: String?
    private var expectedButtonUserAgent: String?
    
    override func setUp() {
        super.setUp()
        Configuration.restoreDefaults()
        Configuration.plistName = "testInfo"
        Configuration.bundle = NSBundle(forClass: self.dynamicType)
        Configuration.setClientID(clientID)
        Configuration.setSandboxEnabled(true)
        versionNumber = NSBundle(forClass: RideParameters.self).objectForInfoDictionaryKey("CFBundleShortVersionString") as? String
        expectedDeeplinkUserAgent = "rides-ios-v\(versionNumber!)-deeplink"
        expectedButtonUserAgent = "rides-ios-v\(versionNumber!)-button"
    }
    
    override func tearDown() {
        Configuration.restoreDefaults()
        super.tearDown()
    }
    
    /**
     *  Test createURL with source button.
     */
    func testCreateAppStoreDeeplinkWithButtonSource() {
        let expectedUrlString = "https://m.uber.com/sign-up?client_id=\(clientID)&user-agent=\(expectedButtonUserAgent!)"
        
        let rideParameters = RideParametersBuilder().setSource(RideRequestButton.sourceString).build()
        let requestingBehavior = DeeplinkRequestingBehavior()
        
        let appStoreDeeplink = requestingBehavior.createAppStoreDeeplink(rideParameters)
        
        let components = NSURLComponents(URL: appStoreDeeplink.deeplinkURL, resolvingAgainstBaseURL: false)
        XCTAssertNotNil(components)
        
        XCTAssertEqual(expectedUrlString, appStoreDeeplink.deeplinkURL.absoluteString)
        XCTAssertEqual(components!.queryItems!.count, 2)
        XCTAssertTrue(components!.query!.containsString("&user-agent=\(expectedButtonUserAgent!)"))
    }
    
    /**
     *  Test createURL with source deeplink.
     */
    func testCreateURLWithDeeplinkSource() {
        let expectedUrlString = "https://m.uber.com/sign-up?client_id=\(clientID)&user-agent=\(expectedDeeplinkUserAgent!)"
        
        let rideParameters = RideParametersBuilder().setSource(RequestDeeplink.sourceString).build()
        let requestingBehavior = DeeplinkRequestingBehavior()
        
        let appStoreDeeplink = requestingBehavior.createAppStoreDeeplink(rideParameters)
        
        let components = NSURLComponents(URL: appStoreDeeplink.deeplinkURL, resolvingAgainstBaseURL: false)
        XCTAssertNotNil(components)
        
        XCTAssertEqual(expectedUrlString, appStoreDeeplink.deeplinkURL.absoluteString)
        XCTAssertEqual(components!.queryItems!.count, 2)
        XCTAssertTrue(components!.query!.containsString("&user-agent=\(expectedDeeplinkUserAgent!)"))
    }
    
    func testRequestRideExecutesDeeplink() {
        let rideParameters = RideParametersBuilder().setSource(RideRequestButton.sourceString).build()
        let expectation = expectationWithDescription("Deeplink executed")
        let testClosure:((NSURL?) -> (Bool)) = { _ in
            expectation.fulfill()
            return false
        }
        let requestingBehavior = DeeplinkRequestingBehaviorMock(testClosure: testClosure)
        
        requestingBehavior.requestRide(rideParameters)
        
        waitForExpectationsWithTimeout(0.5, handler: nil)
    }
}


