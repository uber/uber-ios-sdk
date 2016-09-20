//
//  RideParametersTest.swift
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
import MapKit
@testable import UberRides

class RideParametersTest: XCTestCase {
    fileprivate var versionNumber: String?
    fileprivate var baseUserAgent: String?
    
    fileprivate var builder: RideParametersBuilder = RideParametersBuilder()
    
    override func setUp() {
        super.setUp()
        builder = RideParametersBuilder()
        versionNumber = Bundle(forClass: RideParameters.self).objectForInfoDictionaryKey("CFBundleShortVersionString") as? String
        baseUserAgent = "rides-ios-v\(versionNumber!)"
    }
    
    func testBuilder_withNoParams() {
        let params = builder.build()
        XCTAssertNotNil(params)
        XCTAssertTrue(params.useCurrentLocationForPickup)
        XCTAssertNil(params.pickupLocation)
        XCTAssertNil(params.pickupAddress)
        XCTAssertNil(params.pickupNickname)
        XCTAssertNil(params.dropoffLocation)
        XCTAssertNil(params.dropoffAddress)
        XCTAssertNil(params.dropoffNickname)
        XCTAssertNil(params.productID)
        XCTAssertEqual(params.userAgent, baseUserAgent)
    }
    
    func testBuilder_correctUseCurrentLocation() {
        let testPickup = CLLocation(latitude: 32.0, longitude: -32.0)
        builder.setPickupLocation(testPickup)
        let params = builder.build()
        XCTAssertFalse(params.useCurrentLocationForPickup)
        XCTAssertEqual(testPickup, params.pickupLocation)
        XCTAssertNil(params.pickupAddress)
        XCTAssertNil(params.pickupNickname)
        XCTAssertNil(params.dropoffLocation)
        XCTAssertNil(params.dropoffAddress)
        XCTAssertNil(params.dropoffNickname)
        XCTAssertNil(params.productID)
        XCTAssertEqual(params.userAgent, baseUserAgent)
    }
    
    func testBuilder_withAllParameters() {

        let testPickupLocation = CLLocation(latitude: 32.0, longitude: -32.0)
        let testDropoffLocation = CLLocation(latitude: 62.0, longitude: -62.0)
        let testPickupNickname = "testPickup"
        let testPickupAddress = "123 pickup address"
        let testDropoffNickname = "testDropoff"
        let testDropoffAddress = "123 dropoff address"
        let testProductID = "test ID"
        let testSource = "test source"
        let testPaymentID = "test payment id"
        let testSurgeConfirm = "test surge confirm"
        let expectedUserAgent = "\(baseUserAgent!)-\(testSource)"
        builder.setPickupLocation(testPickupLocation, nickname: testPickupNickname, address: testPickupAddress)
        builder.setDropoffLocation(testDropoffLocation, nickname: testDropoffNickname, address: testDropoffAddress)
        builder.setPaymentMethod(testPaymentID)
        builder.setSurgeConfirmationID(testSurgeConfirm)
        builder.setProductID(testProductID).setSource(testSource)
        let params = builder.build()
        
        XCTAssertFalse(params.useCurrentLocationForPickup)
        XCTAssertEqual(params.pickupLocation, testPickupLocation)
        XCTAssertEqual(params.pickupAddress, testPickupAddress)
        XCTAssertEqual(params.pickupNickname, testPickupNickname)
        XCTAssertEqual(params.dropoffLocation, testDropoffLocation)
        XCTAssertEqual(params.dropoffAddress, testDropoffAddress)
        XCTAssertEqual(params.dropoffNickname, testDropoffNickname)
        XCTAssertEqual(params.productID, testProductID)
        XCTAssertEqual(params.userAgent, expectedUserAgent)
        XCTAssertEqual(params.paymentMethod, testPaymentID)
        XCTAssertEqual(params.surgeConfirmationID, testSurgeConfirm)
    }
    
    func testBuilder_withAllParams_usingPlaceIDs() {
        let testPickupPlace = "home"
        let testDropoffPlace = "work"
        let testProductID = "test ID"
        let testSource = "test source"
        let testPaymentID = "test payment id"
        let testSurgeConfirm = "test surge confirm"
        let expectedUserAgent = "\(baseUserAgent!)-\(testSource)"
        builder.setPickupPlaceID(testPickupPlace)
        builder.setDropoffPlaceID(testDropoffPlace)
        builder.setPaymentMethod(testPaymentID)
        builder.setSurgeConfirmationID(testSurgeConfirm)
        builder.setProductID(testProductID).setSource(testSource)
        let params = builder.build()
        
        XCTAssertEqual(params.pickupPlaceID, testPickupPlace)
        XCTAssertEqual(params.dropoffPlaceID, testDropoffPlace)
        XCTAssertNil(params.dropoffNickname)
        XCTAssertNil(params.dropoffAddress)
        XCTAssertNil(params.dropoffLocation)
        XCTAssertNil(params.pickupLocation)
        XCTAssertNil(params.pickupAddress)
        XCTAssertNil(params.pickupNickname)
        XCTAssertFalse(params.useCurrentLocationForPickup)
        XCTAssertEqual(params.productID, testProductID)
        XCTAssertEqual(params.userAgent, expectedUserAgent)
        XCTAssertEqual(params.paymentMethod, testPaymentID)
        XCTAssertEqual(params.surgeConfirmationID, testSurgeConfirm)
    }
    
    func testBuilder_updateParameter() {
        let testPickupLocation1 = CLLocation(latitude: 32.0, longitude: -32.0)
        let testPickupLocation2 = CLLocation(latitude: 62.0, longitude: -62.0)
        builder.setPickupLocation(testPickupLocation1)
        builder.setPickupLocation(testPickupLocation2)
        let params = builder.build()
        XCTAssertFalse(params.useCurrentLocationForPickup)
        XCTAssertEqual(params.pickupLocation, testPickupLocation2)
        XCTAssertNil(params.pickupAddress)
        XCTAssertNil(params.pickupNickname)
        XCTAssertNil(params.dropoffLocation)
        XCTAssertNil(params.dropoffAddress)
        XCTAssertNil(params.dropoffNickname)
        XCTAssertNil(params.productID)
        XCTAssertNil(params.paymentMethod)
        XCTAssertNil(params.surgeConfirmationID)
        XCTAssertNil(params.pickupPlaceID)
        XCTAssertNil(params.dropoffPlaceID)
        XCTAssertEqual(params.userAgent, baseUserAgent)
    }
    
    func testBuilder_useCurrentLocation() {
        let testPickupLocation = CLLocation(latitude: 32.0, longitude: -32.0)
        let testPickupNickname = "testPickup nickname"
        let testPickupAddress = "123 test pickup st"
        builder.setPickupLocation(testPickupLocation, nickname: testPickupNickname, address: testPickupAddress)
        builder.setPickupToCurrentLocation()
        let params = builder.build()
        XCTAssertTrue(params.useCurrentLocationForPickup)
        XCTAssertNil(params.pickupLocation)
        XCTAssertNil(params.pickupAddress)
        XCTAssertNil(params.pickupNickname)
        XCTAssertNil(params.dropoffLocation)
        XCTAssertNil(params.dropoffAddress)
        XCTAssertNil(params.dropoffNickname)
        XCTAssertNil(params.productID)
        XCTAssertNil(params.paymentMethod)
        XCTAssertNil(params.surgeConfirmationID)
        XCTAssertNil(params.pickupPlaceID)
        XCTAssertNil(params.dropoffPlaceID)
        XCTAssertEqual(params.userAgent, baseUserAgent)
    }
    
    func testBuilder_withExistingParameters() {
        let expectedBuilder = RideParametersBuilder()
        let testPickupLocation = CLLocation(latitude: 32.0, longitude: -32.0)
        let testDropoffLocation = CLLocation(latitude: 62.0, longitude: -62.0)
        let testPickupNickname = "testPickup"
        let testPickupAddress = "123 pickup address"
        let testDropoffNickname = "testDropoff"
        let testDropoffAddress = "123 dropoff address"
        let testProductID = "test ID"
        let testSource = "test source"
        let testPaymentID = "test payment id"
        let testSurgeConfirm = "test surge confirm"
        
        expectedBuilder.setPickupLocation(testPickupLocation, nickname: testPickupNickname, address: testPickupAddress)
        expectedBuilder.setDropoffLocation(testDropoffLocation, nickname: testDropoffNickname, address: testDropoffAddress)
        expectedBuilder.setPaymentMethod(testPaymentID)
        expectedBuilder.setSurgeConfirmationID(testSurgeConfirm)
        expectedBuilder.setProductID(testProductID).setSource(testSource)
        let expectedParams = expectedBuilder.build()
        let params = RideParametersBuilder(rideParameters: expectedParams).build()
        
        XCTAssertEqual(params.useCurrentLocationForPickup, expectedParams.useCurrentLocationForPickup)
        XCTAssertEqual(params.pickupLocation, expectedParams.pickupLocation)
        XCTAssertEqual(params.pickupAddress, expectedParams.pickupAddress)
        XCTAssertEqual(params.pickupNickname, expectedParams.pickupNickname)
        XCTAssertEqual(params.dropoffLocation, expectedParams.dropoffLocation)
        XCTAssertEqual(params.dropoffAddress, expectedParams.dropoffAddress)
        XCTAssertEqual(params.dropoffNickname, expectedParams.dropoffNickname)
        XCTAssertEqual(params.productID, expectedParams.productID)
        XCTAssertEqual(params.userAgent, expectedParams.userAgent)
        XCTAssertEqual(params.surgeConfirmationID, expectedParams.surgeConfirmationID)
        XCTAssertEqual(params.paymentMethod, expectedParams.paymentMethod)
    }
    
    func testBuilder_withPickupPlaceID_hasNoPickupLocation() {
        let expectedBuilder = RideParametersBuilder()
        let testPickupLocation = CLLocation(latitude: 32.0, longitude: -32.0)
        let testPickupNickname = "testPickup"
        let testPickupAddress = "123 pickup address"

        let testPlaceID = "home"
        
        expectedBuilder.setPickupLocation(testPickupLocation, nickname: testPickupNickname, address: testPickupAddress)
        expectedBuilder.setPickupPlaceID(testPlaceID)
        
        let params = expectedBuilder.build()
        XCTAssertNil(params.pickupLocation)
        XCTAssertNil(params.pickupNickname)
        XCTAssertNil(params.pickupAddress)
        XCTAssertEqual(params.pickupPlaceID, testPlaceID)
    }
    
    func testBuilder_withDropoffPlaceID_hasNoDropoffLocation() {
        let expectedBuilder = RideParametersBuilder()
        let testDropoffLocation = CLLocation(latitude: 32.0, longitude: -32.0)
        let testDropoffNickname = "testDropoff"
        let testDropoffAddress = "123 dropoff address"
        
        let testPlaceID = "home"
        
        expectedBuilder.setDropoffLocation(testDropoffLocation, nickname: testDropoffNickname, address: testDropoffAddress)
        expectedBuilder.setDropoffPlaceID(testPlaceID)
        
        let params = expectedBuilder.build()
        XCTAssertNil(params.dropoffLocation)
        XCTAssertNil(params.dropoffNickname)
        XCTAssertNil(params.dropoffAddress)
        XCTAssertEqual(params.dropoffPlaceID, testPlaceID)
    }
}
