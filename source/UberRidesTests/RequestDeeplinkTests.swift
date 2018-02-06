//
//  RequestDeeplinkTests.swift
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
import UberCore
@testable import UberRides

let clientID = "clientID1234"
let serverToken = "serverToken1234"
let redirectURI = "http://localhost:1234/"
let productID = "productID1234"
let pickupLat = 37.770
let pickupLong = -122.466
let dropoffLat = 37.791
let dropoffLong = -122.405
let pickupNickname = "California Academy of Science"
let pickupAddress = "55 Music Concourse Drive, San Francisco"
let dropoffNickname = "Pier 39"
let dropoffAddress = "Beach Street & The Embarcadero, San Francisco"
let surgeConfirm = "surgeConfirm"
let paymentMethod = "paymentMethod"

struct ExpectedDeeplink {
    static let uberScheme = "uber://?"
    static let clientIDQuery = "client_id=\(clientID)"
    static let productIDQuery = "product_id=\(productID)"
    static let setPickupAction = "action=setPickup"
    static let defaultPickupQuery = "pickup=my_location"
    static let pickupLatQuery = "pickup[latitude]=\(pickupLat)"
    static let pickupLongQuery = "pickup[longitude]=\(pickupLong)"
    static let pickupNicknameQuery = "pickup[nickname]=\(pickupNickname)"
    static let pickupAddressQuery = "pickup[formatted_address]=\(pickupAddress)"
    static let dropoffLatQuery = "dropoff[latitude]=\(dropoffLat)"
    static let dropoffLongQuery = "dropoff[longitude]=\(dropoffLong)"
    static let dropoffNicknameQuery = "dropoff[nickname]=\(dropoffNickname)"
    static let dropoffAddressQuery = "dropoff[formatted_address]=\(dropoffAddress)"
}

class UberRidesDeeplinkTests: XCTestCase {
    private var versionNumber: String?
    private var expectedDeeplinkUserAgent: String?
    private var expectedButtonUserAgent: String?
    let timeout: Double = 2
    
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
     Test to build an UberDeeplink with no PickupLatLng and assign user's current location as default
     */
    func testBuildDeeplinkWithClientIDHasDefaultParameters() {
        let deeplink = RequestDeeplink()
        let uri = deeplink.url.absoluteString
        
        XCTAssertTrue(uri.contains(ExpectedDeeplink.uberScheme))
        
        let components = URLComponents(string: uri)
        XCTAssertEqual(components?.queryItems?.count, 4)
        
        let query = components?.query
        XCTAssertTrue(query!.contains(ExpectedDeeplink.clientIDQuery))
        XCTAssertTrue(query!.contains(ExpectedDeeplink.setPickupAction))
        XCTAssertTrue(query!.contains(ExpectedDeeplink.defaultPickupQuery))
        XCTAssertTrue(query!.contains(expectedDeeplinkUserAgent!))
    }
    
    /**
     Test to build an UberDeeplink with a Pickup Latitude and Longitude.
     */
    func testBuildDeeplinkWithPickupLatLng() {
        let location = CLLocation(latitude: pickupLat, longitude: pickupLong)
        let builder = RideParametersBuilder()
        builder.pickupLocation = location
        let rideParams = builder.build()
        let deeplink = RequestDeeplink(rideParameters: rideParams)
        
        let components = URLComponents(url: deeplink.url, resolvingAgainstBaseURL: false)
        XCTAssertEqual(components?.queryItems?.count, 5)
        
        let query = components?.query
        XCTAssertTrue(query!.contains(ExpectedDeeplink.clientIDQuery))
        XCTAssertTrue(query!.contains(ExpectedDeeplink.setPickupAction))
        XCTAssertTrue(query!.contains(ExpectedDeeplink.pickupLatQuery))
        XCTAssertTrue(query!.contains(ExpectedDeeplink.pickupLongQuery))
        XCTAssertTrue(query!.contains(expectedDeeplinkUserAgent!))
    }
    
    /**
     Test to build an UberDeeplink with all optional Pickup Parameters.
     */
    func testBuildDeeplinkWithAllPickupParameters() {
        let location = CLLocation(latitude: pickupLat, longitude: pickupLong)
        let builder = RideParametersBuilder()
        builder.pickupLocation = location
        builder.pickupNickname = pickupNickname
        builder.pickupAddress = pickupAddress
        let rideParams = builder.build()
        let deeplink = RequestDeeplink(rideParameters: rideParams)
        
        let components = URLComponents(url: deeplink.url, resolvingAgainstBaseURL: false)
        XCTAssertEqual(components?.queryItems?.count, 7)
        
        let query = components?.query
        XCTAssertTrue(query!.contains(ExpectedDeeplink.clientIDQuery))
        XCTAssertTrue(query!.contains(ExpectedDeeplink.setPickupAction))
        XCTAssertTrue(query!.contains(ExpectedDeeplink.pickupLatQuery))
        XCTAssertTrue(query!.contains(ExpectedDeeplink.pickupLongQuery))
        XCTAssertTrue(query!.contains(ExpectedDeeplink.pickupNicknameQuery))
        XCTAssertTrue(query!.contains(ExpectedDeeplink.pickupAddressQuery))
        XCTAssertTrue(query!.contains(expectedDeeplinkUserAgent!))
    }
    
    /**
     Test to build an UberDeeplink with only Dropoff Parameters (set default Pickup Parameters).
     */
    func testBuildDeeplinkWithoutPickupParameters() {
        let location = CLLocation(latitude: dropoffLat, longitude: dropoffLong)
        let builder = RideParametersBuilder()
        builder.dropoffLocation = location
        let rideParams = builder.build()
        let deeplink = RequestDeeplink(rideParameters: rideParams)
        
        let components = URLComponents(url: deeplink.url, resolvingAgainstBaseURL: false)
        XCTAssertEqual(components?.queryItems?.count, 6)
        
        let query = components?.query
        XCTAssertTrue(query!.contains(ExpectedDeeplink.clientIDQuery))
        XCTAssertTrue(query!.contains(ExpectedDeeplink.setPickupAction))
        XCTAssertTrue(query!.contains(ExpectedDeeplink.defaultPickupQuery))
        XCTAssertTrue(query!.contains(ExpectedDeeplink.dropoffLatQuery))
        XCTAssertTrue(query!.contains(ExpectedDeeplink.dropoffLongQuery))
        XCTAssertTrue(query!.contains(expectedDeeplinkUserAgent!))
    }
    
    /**
     Test to build an UberDeeplink with all possible query parameters.
     */
    func testBuildDeeplinkWithAllParameters() {
        let pickupLocation = CLLocation(latitude: pickupLat, longitude: pickupLong)
        let dropoffLocation = CLLocation(latitude: dropoffLat, longitude: dropoffLong)
        let builder = RideParametersBuilder()
        builder.pickupLocation = pickupLocation
        builder.dropoffLocation = dropoffLocation
        builder.productID = productID
        builder.pickupNickname = pickupNickname
        builder.pickupAddress = pickupAddress
        builder.dropoffNickname = dropoffNickname
        builder.dropoffAddress = dropoffAddress
        let rideParams = builder.build()
        let deeplink = RequestDeeplink(rideParameters: rideParams)
        
        let components = URLComponents(url: deeplink.url, resolvingAgainstBaseURL: false)
        XCTAssertEqual(components?.queryItems?.count, 12)
        
        let query = components?.query
        XCTAssertTrue(query!.contains(ExpectedDeeplink.clientIDQuery))
        XCTAssertTrue(query!.contains(ExpectedDeeplink.productIDQuery))
        XCTAssertTrue(query!.contains(ExpectedDeeplink.setPickupAction))
        XCTAssertTrue(query!.contains(ExpectedDeeplink.pickupLatQuery))
        XCTAssertTrue(query!.contains(ExpectedDeeplink.pickupLongQuery))
        XCTAssertTrue(query!.contains(ExpectedDeeplink.pickupNicknameQuery))
        XCTAssertTrue(query!.contains(ExpectedDeeplink.pickupAddressQuery))
        XCTAssertTrue(query!.contains(ExpectedDeeplink.dropoffLatQuery))
        XCTAssertTrue(query!.contains(ExpectedDeeplink.dropoffLongQuery))
        XCTAssertTrue(query!.contains(ExpectedDeeplink.dropoffNicknameQuery))
        XCTAssertTrue(query!.contains(ExpectedDeeplink.dropoffAddressQuery))
        XCTAssertTrue(query!.contains(expectedDeeplinkUserAgent!))
    }
    
    func testDeeplinkDefaultSource() {
        let expectation = self.expectation(description: "Test Deeplink source parameter")
        let expectationClosure: (URL?) -> (Bool) = { url in
            expectation.fulfill()
            guard let url = url, let components = URLComponents(url: url, resolvingAgainstBaseURL: false), let items = components.queryItems else {
                XCTAssert(false)
                return false
            }
            XCTAssertTrue(items.count > 0)
            var foundUserAgent = false
            for item in items {
                if (item.name == "user-agent") {
                    if let value = item.value {
                        foundUserAgent = true
                        XCTAssertTrue(value.contains(RequestDeeplink.sourceString))
                        break
                    }
                }
            }
            XCTAssert(foundUserAgent)
            return false
        }
        
        let deeplink = RequestDeeplinkMock(rideParameters: RideParametersBuilder().build(), testClosure: expectationClosure)
        
        deeplink.execute()
        
        waitForExpectations(timeout: timeout, handler: { error in
            XCTAssertNil(error)
        })
    }

    func testRequestDeeplinkFallbackAppStore() {
        let deeplink = RequestDeeplink()
        XCTAssertEqual(deeplink.fallbackURLs.count, 3)
        XCTAssertEqual(deeplink.fallbackURLs[0].scheme, "uber-enterprise")
        XCTAssertEqual(deeplink.fallbackURLs[1].scheme, "uber-nightly")
        XCTAssertEqual(deeplink.fallbackURLs[2].scheme, "https")
        XCTAssertEqual(deeplink.fallbackURLs[2].host, "m.uber.com")
        XCTAssertEqual(deeplink.fallbackURLs[2].path, "/sign-up")
    }

    func testRequestDeeplinkFallbackDefaultsMuber() {
        let deeplink = RequestDeeplink(rideParameters: RideParametersBuilder().build(), fallbackType: .mobileWeb)
        XCTAssertEqual(deeplink.fallbackURLs.count, 3)
        XCTAssertEqual(deeplink.fallbackURLs[0].scheme, "uber-enterprise")
        XCTAssertEqual(deeplink.fallbackURLs[1].scheme, "uber-nightly")
        XCTAssertEqual(deeplink.fallbackURLs[2].scheme, "https")
        XCTAssertEqual(deeplink.fallbackURLs[2].host, "m.uber.com")
        XCTAssertEqual(deeplink.fallbackURLs[2].path, "")
    }

    func testRequestDeeplinkFallbackNone() {
        let deeplink = RequestDeeplink(rideParameters: RideParametersBuilder().build(), fallbackType: .none)
        XCTAssertEqual(deeplink.fallbackURLs.count, 2)
        XCTAssertEqual(deeplink.fallbackURLs[0].scheme, "uber-enterprise")
        XCTAssertEqual(deeplink.fallbackURLs[1].scheme, "uber-nightly")
    }
}
