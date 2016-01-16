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
@testable import UberRides

let clientID = "clientID1234"
let productID = "productID1234"
let pickupLat = "37.770"
let pickupLong = "-122.466"
let dropoffLat = "37.791"
let dropoffLong = "-122.405"
let pickupNickname = "California Academy of Science"
let pickupAddress = "55 Music Concourse Drive, San Francisco"
let dropoffNickname = "Pier 39"
let dropoffAddress = "Beach Street & The Embarcadero, San Francisco"

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
    
    override func setUp() {
        super.setUp()
    }
    
    override func tearDown() {
        super.tearDown()
    }
    
    /**
     Test that PickupLocationSet check returns False if no Pickup Parameters were added
     */
    func testPickupLocationSetIsFalseWithNoPickupParameters() {
        let deeplink = RequestDeeplink(withClientID: clientID)
        XCTAssertFalse(deeplink.pickupLocationSet())
    }
    
    /**
     Test that PickupLocationSet check returns True if Pickup Parameters are added
     */
    func testPickupLocationSetIsTrueWithPickupParameters() {
        let deeplink = RequestDeeplink(withClientID: clientID)
        deeplink.setPickupLocation(latitude: pickupLat, longitude: pickupLong)
        XCTAssertTrue(deeplink.pickupLocationSet())
    }
    
    /**
     Test to build an UberDeeplink with no PickupLatLng and assign user's current location as default
     */
    func testBuildDeeplinkWithClientIDHasDefaultParameters() {
        let deeplink = RequestDeeplink(withClientID: clientID)
        let uri = deeplink.build()
        XCTAssertTrue(uri.containsString(ExpectedDeeplink.uberScheme))
        
        let components = NSURLComponents(string: uri)
        XCTAssertEqual(components?.queryItems?.count, 3)
        
        let query = components?.query
        XCTAssertTrue(query!.containsString(ExpectedDeeplink.clientIDQuery))
        XCTAssertTrue(query!.containsString(ExpectedDeeplink.setPickupAction))
        XCTAssertTrue(query!.containsString(ExpectedDeeplink.defaultPickupQuery))
    }
    
    /**
     Test to build an UberDeeplink with a Pickup Latitude and Longitude.
     */
    func testBuildDeeplinkWithPickupLatLng() {
        let deeplink = RequestDeeplink(withClientID: clientID)
        deeplink.setPickupLocation(latitude: pickupLat, longitude: pickupLong)
        
        let components = NSURLComponents(URL: NSURL(string: deeplink.build())!, resolvingAgainstBaseURL: false)
        XCTAssertEqual(components?.queryItems?.count, 4)
        
        let query = components?.query
        XCTAssertTrue(query!.containsString(ExpectedDeeplink.clientIDQuery))
        XCTAssertTrue(query!.containsString(ExpectedDeeplink.setPickupAction))
        XCTAssertTrue(query!.containsString(ExpectedDeeplink.pickupLatQuery))
        XCTAssertTrue(query!.containsString(ExpectedDeeplink.pickupLongQuery))
    }
    
    /**
     Test to build an UberDeeplink with all optional Pickup Parameters.
     */
    func testBuildDeeplinkWithAllPickupParameters() {
        let deeplink = RequestDeeplink(withClientID: clientID)
        deeplink.setPickupLocation(latitude: pickupLat, longitude: pickupLong, nickname: pickupNickname, address: pickupAddress)
        
        let components = NSURLComponents(URL: NSURL(string: deeplink.build())!, resolvingAgainstBaseURL: false)
        XCTAssertEqual(components?.queryItems?.count, 6)
        
        let query = components?.query
        XCTAssertTrue(query!.containsString(ExpectedDeeplink.clientIDQuery))
        XCTAssertTrue(query!.containsString(ExpectedDeeplink.setPickupAction))
        XCTAssertTrue(query!.containsString(ExpectedDeeplink.pickupLatQuery))
        XCTAssertTrue(query!.containsString(ExpectedDeeplink.pickupLongQuery))
        XCTAssertTrue(query!.containsString(ExpectedDeeplink.pickupNicknameQuery))
        XCTAssertTrue(query!.containsString(ExpectedDeeplink.pickupAddressQuery))
    }
    
    /**
     Test to build an UberDeeplink with only Dropoff Parameters (set default Pickup Parameters).
     */
    func testBuildDeeplinkWithoutPickupParameters() {
        let deeplink = RequestDeeplink(withClientID: clientID)
        deeplink.setDropoffLocation(latitude: dropoffLat, longitude: dropoffLong)
        
        let components = NSURLComponents(URL: NSURL(string: deeplink.build())!, resolvingAgainstBaseURL: false)
        XCTAssertEqual(components?.queryItems?.count, 5)
        
        let query = components?.query
        XCTAssertTrue(query!.containsString(ExpectedDeeplink.clientIDQuery))
        XCTAssertTrue(query!.containsString(ExpectedDeeplink.setPickupAction))
        XCTAssertTrue(query!.containsString(ExpectedDeeplink.defaultPickupQuery))
        XCTAssertTrue(query!.containsString(ExpectedDeeplink.dropoffLatQuery))
        XCTAssertTrue(query!.containsString(ExpectedDeeplink.dropoffLongQuery))
    }
    
    /**
     Test to build an UberDeeplink with all possible query parameters.
     */
    func testBuildDeeplinkWithAllParameters() {
        let deeplink = RequestDeeplink(withClientID: clientID)
        deeplink.setProductID(productID)
        deeplink.setPickupLocation(latitude: pickupLat, longitude: pickupLong, nickname: pickupNickname, address: pickupAddress)
        deeplink.setDropoffLocation(latitude: dropoffLat, longitude: dropoffLong, nickname: dropoffNickname, address: dropoffAddress)
        
        let components = NSURLComponents(URL: NSURL(string: deeplink.build())!, resolvingAgainstBaseURL: false)
        XCTAssertEqual(components?.queryItems?.count, 11)
        
        let query = components?.query
        XCTAssertTrue(query!.containsString(ExpectedDeeplink.clientIDQuery))
        XCTAssertTrue(query!.containsString(ExpectedDeeplink.productIDQuery))
        XCTAssertTrue(query!.containsString(ExpectedDeeplink.setPickupAction))
        XCTAssertTrue(query!.containsString(ExpectedDeeplink.pickupLatQuery))
        XCTAssertTrue(query!.containsString(ExpectedDeeplink.pickupLongQuery))
        XCTAssertTrue(query!.containsString(ExpectedDeeplink.pickupNicknameQuery))
        XCTAssertTrue(query!.containsString(ExpectedDeeplink.pickupAddressQuery))
        XCTAssertTrue(query!.containsString(ExpectedDeeplink.dropoffLatQuery))
        XCTAssertTrue(query!.containsString(ExpectedDeeplink.dropoffLongQuery))
        XCTAssertTrue(query!.containsString(ExpectedDeeplink.dropoffNicknameQuery))
        XCTAssertTrue(query!.containsString(ExpectedDeeplink.dropoffAddressQuery))
    }
    
    /**
     Test to set deeplink to default location, then override with another location.
     Test ensures deeplink removes original default location parameter.
     */
    func testOverrideDefaultPickupWithPickupLocation() {
        let deeplink = RequestDeeplink(withClientID: clientID)
        deeplink.setPickupLocationToCurrentLocation()
        
        var components = NSURLComponents(URL: NSURL(string: deeplink.build())!, resolvingAgainstBaseURL: false)
        XCTAssertEqual(components?.queryItems?.count, 3)
        
        var query = components?.query
        XCTAssertTrue(query!.containsString(ExpectedDeeplink.defaultPickupQuery))
        
        deeplink.setPickupLocation(latitude: pickupLat, longitude: pickupLong)
        components = NSURLComponents(URL: NSURL(string: deeplink.build())!, resolvingAgainstBaseURL: false)
        query = components?.query
        
        XCTAssertEqual(components?.queryItems?.count, 4)
        XCTAssertFalse(query!.containsString(ExpectedDeeplink.defaultPickupQuery))
    }
    
    /**
     Test to set deeplink to pickup location, then override with current location.
     Test ensures deeplink removes original pickup location parameters.
     */
    func testOverridePickupLocationWithDefault() {
        let deeplink = RequestDeeplink(withClientID: clientID)
        deeplink.setPickupLocation(latitude: pickupLat, longitude: pickupLong, nickname: pickupNickname, address: pickupAddress)
        
        var components = NSURLComponents(URL: NSURL(string: deeplink.build())!, resolvingAgainstBaseURL: false)
        XCTAssertEqual(components?.queryItems?.count, 6)
        
        deeplink.setPickupLocationToCurrentLocation()
        components = NSURLComponents(URL: NSURL(string: deeplink.build())!, resolvingAgainstBaseURL: false)
        let query = components?.query
        
        XCTAssertEqual(components?.queryItems?.count, 3)
        XCTAssertTrue(query!.containsString(ExpectedDeeplink.defaultPickupQuery))
    }
    
    /**
     Test to rebuild deep link without making changes and verify that the same string is returned.
     */
    func testRebuildingDeeplinkWithoutChanges() {
        let deeplink = RequestDeeplink(withClientID: clientID)
        deeplink.setPickupLocation(latitude: pickupLat, longitude: pickupLong, nickname: pickupNickname, address: pickupAddress)
        
        let originalAddress = unsafeAddressOf(deeplink.build())
        let rebuiltAddress = unsafeAddressOf(deeplink.build())
        
        XCTAssertEqual(originalAddress, rebuiltAddress)
    }
    
    /**
     Test to rebuild deep link after making changes and verify that the deep link has been built again.
     */
    func testRebuildingDeeplinWithChanges() {
        let deeplink = RequestDeeplink(withClientID: clientID)
        deeplink.setPickupLocation(latitude: pickupLat, longitude: pickupLong, nickname: pickupNickname, address: pickupAddress)
        
        let originalAddress = unsafeAddressOf(deeplink.build())
        deeplink.setProductID(productID)
        let rebuiltAddress = unsafeAddressOf(deeplink.build())
        
        XCTAssertNotEqual(originalAddress, rebuiltAddress)
    }
}
