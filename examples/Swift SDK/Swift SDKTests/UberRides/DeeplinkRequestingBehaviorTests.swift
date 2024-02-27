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
import UberCore
@testable import UberRides

class DeeplinkRequestingBehaviorTests : XCTestCase {
    
    private var versionNumber: String?
    private var expectedDeeplinkUserAgent: String?
    private var expectedButtonUserAgent: String?
    
    override func setUp() {
        super.setUp()
        Configuration.plistName = "testInfo"
        Configuration.restoreDefaults()
        Configuration.shared.clientID = clientID
        Configuration.shared.isSandbox = true
        versionNumber = Bundle(for: RideParameters.self).object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String
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

        let rideParameters = RideParametersBuilder().build()
        rideParameters.source = RideRequestButton.sourceString
        let requestingBehavior = DeeplinkRequestingBehavior(fallbackType: .appStore)
        
        let appStoreDeeplink = requestingBehavior.createDeeplink(rideParameters: rideParameters).fallbackURLs.last!
        
        let components = URLComponents(url: appStoreDeeplink, resolvingAgainstBaseURL: false)
        XCTAssertNotNil(components)
        
        XCTAssertEqual(expectedUrlString, appStoreDeeplink.absoluteString)
        XCTAssertEqual(components!.queryItems!.count, 2)
        XCTAssertTrue(components!.query!.contains("&user-agent=\(expectedButtonUserAgent!)"))
    }
    
    /**
     *  Test createURL with source deeplink.
     */
    func testCreateURLWithDeeplinkSource() {
        let expectedUrlString = "https://m.uber.com/sign-up?client_id=\(clientID)&user-agent=\(expectedDeeplinkUserAgent!)"

        let rideParameters = RideParametersBuilder().build()
        rideParameters.source = RequestDeeplink.sourceString
        let requestingBehavior = DeeplinkRequestingBehavior(fallbackType: .appStore)
        
        let appStoreDeeplink = requestingBehavior.createDeeplink(rideParameters: rideParameters).fallbackURLs.last!
        
        let components = URLComponents(url: appStoreDeeplink, resolvingAgainstBaseURL: false)
        XCTAssertNotNil(components)
        
        XCTAssertEqual(expectedUrlString, appStoreDeeplink.absoluteString)
        XCTAssertEqual(components!.queryItems!.count, 2)
        XCTAssertTrue(components!.query!.contains("&user-agent=\(expectedDeeplinkUserAgent!)"))
    }
    
    func testRequestRideExecutesDeeplink() {
        let rideParameters = RideParametersBuilder().build()
        rideParameters.source = RideRequestButton.sourceString
        let expectation = self.expectation(description: "Deeplink executed")
        let testClosure:((URL?) -> (Bool)) = { _ in
            expectation.fulfill()
            return false
        }
        let requestingBehavior = DeeplinkRequestingBehaviorMock(testClosure: testClosure)
        
        requestingBehavior.requestRide(parameters: rideParameters)
        
        waitForExpectations(timeout: 0.5, handler: nil)
    }
}


