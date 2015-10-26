//
//  UberDeeplinkTests.swift
//  sdkTests
//
//  Copyright © 2015 Uber Technologies, Inc. All rights reserved.
//

import XCTest
@testable import sdk

struct ExpectedDeeplink {
    static let defaultParameters = "uber://?client_id=clientID1234&action=setPickup&pickup=my_location"
    static let pickupLatLng = "uber://?client_id=clientID1234&action=setPickup&pickup[latitude]=37.770&pickup[longitude]=-122.466"
    static let allPickupParameters = "uber://?client_id=clientID1234&action=setPickup&pickup[latitude]=37.770&pickup[longitude]=-122.466&pickup[nickname]=California%20Academy%20of%20Science&pickup[formatted_address]=55%20Music%20Concourse%20Drive%2C%20San%20Francisco"
    static let dropoffLatLng = "uber://?client_id=clientID1234&dropoff[latitude]=37.791&dropoff[longitude]=-122.405&action=setPickup&pickup=my_location"
    static let allParameters = "uber://?client_id=clientID1234&product_id=productID1234&action=setPickup&pickup[latitude]=37.770&pickup[longitude]=-122.466&pickup[nickname]=California%20Academy%20of%20Science&pickup[formatted_address]=55%20Music%20Concourse%20Drive%2C%20San%20Francisco&dropoff[latitude]=37.791&dropoff[longitude]=-122.405&dropoff[nickname]=Pier%2039&dropoff[formatted_address]=Beach%20Street%20%26%20The%20Embarcadero%2C%20San%20Francisco"
}

class UberDeeplinkTests: XCTestCase {
    
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
        let deeplink = UberDeeplink(clientID: "clientID1234")
        XCTAssertFalse(deeplink.PickupLocationSet())
    }
    
    /**
    Test that PickupLocationSet check returns True if Pickup Parameters are added
    */
    func testPickupLocationSetIsTrueWithPickupParameters() {
        let deeplink = UberDeeplink(clientID: "clientID1234")
        deeplink.setPickupLocation("37.770", longitude: "-122.466")
        XCTAssertTrue(deeplink.PickupLocationSet())
    }
    
    /**
    Test to build an UberDeeplink with no PickupLatLng and assign user's current location as default
    */
    func testBuildDeeplinkWithClientIDHasDefaultParameters() {
        let deeplink = UberDeeplink(clientID: "clientID1234")
        XCTAssertEqual(ExpectedDeeplink.defaultParameters, deeplink.build())
    }
    
    /**
    Test to build an UberDeeplink with a Pickup Latitude and Longitude.
    */
    func testBuildDeeplinkWithPickupLatLng() {
        let deeplink = UberDeeplink(clientID: "clientID1234")
        deeplink.setPickupLocation("37.770", longitude: "-122.466")
        XCTAssertEqual(ExpectedDeeplink.pickupLatLng, deeplink.build())
    }
    
    /**
    Test to build an UberDeeplink with all optional Pickup Parameters.
    */
    func testBuildDeeplinkWithAllPickupParamerets() {
        let deeplink = UberDeeplink(clientID: "clientID1234")
        deeplink.setPickupLocation("37.770", longitude: "-122.466", nickname: "California Academy of Science", address: "55 Music Concourse Drive, San Francisco")
        XCTAssertEqual(ExpectedDeeplink.allPickupParameters, deeplink.build())
    }
    
    /**
    Test to build an UberDeeplink with only Dropoff Parameters (set default Pickup Parameters).
    */
    func testBuildDeeplinkWithoutPickupParameters() {
        let deeplink = UberDeeplink(clientID: "clientID1234")
        deeplink.setDropoffLocation("37.791", longitude: "-122.405")
        XCTAssertEqual(ExpectedDeeplink.dropoffLatLng, deeplink.build())
    }
    
    /**
    Test to build an UberDeeplink with all possible query parameters.
    */
    func testBuildDeeplinkWithAllParameters() {
        let deeplink = UberDeeplink(clientID: "clientID1234")
        deeplink.setProductID("productID1234")
        deeplink.setPickupLocation("37.770", longitude: "-122.466", nickname: "California Academy of Science", address: "55 Music Concourse Drive, San Francisco")
        deeplink.setDropoffLocation("37.791", longitude: "-122.405", nickname: "Pier 39", address: "Beach Street & The Embarcadero, San Francisco")
        XCTAssertEqual(ExpectedDeeplink.allParameters, deeplink.build())
    }
}
