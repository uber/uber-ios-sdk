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
    private var versionNumber: String?
    private var baseUserAgent: String?
    
    override func setUp() {
        super.setUp()
        versionNumber = Bundle(for: RideParameters.self).object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String
        baseUserAgent = "rides-ios-v\(versionNumber!)"
    }
    
    func testBuilder_withNoParams() {
        let params = RideParameters()
        XCTAssertNotNil(params)
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
        let params = RideParameters(pickupLocation: testPickup, dropoffLocation: nil)
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
        let params = RideParameters(pickupLocation: testPickupLocation, dropoffLocation: testDropoffLocation)
        params.pickupNickname = testPickupNickname
        params.pickupAddress = testPickupAddress
        params.dropoffNickname = testDropoffNickname
        params.dropoffAddress = testDropoffAddress
        params.paymentMethod = testPaymentID
        params.surgeConfirmationID = testSurgeConfirm
        params.productID = testProductID
        params.source = testSource

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
        let params = RideParameters(pickupPlaceID: testPickupPlace, dropoffPlaceID: testDropoffPlace)
        params.paymentMethod = testPaymentID
        params.surgeConfirmationID = testSurgeConfirm
        params.productID = testProductID
        params.source = testSource
        
        XCTAssertEqual(params.pickupPlaceID, testPickupPlace)
        XCTAssertEqual(params.dropoffPlaceID, testDropoffPlace)
        XCTAssertNil(params.dropoffNickname)
        XCTAssertNil(params.dropoffAddress)
        XCTAssertNil(params.dropoffLocation)
        XCTAssertNil(params.pickupLocation)
        XCTAssertNil(params.pickupAddress)
        XCTAssertNil(params.pickupNickname)
        XCTAssertEqual(params.productID, testProductID)
        XCTAssertEqual(params.userAgent, expectedUserAgent)
        XCTAssertEqual(params.paymentMethod, testPaymentID)
        XCTAssertEqual(params.surgeConfirmationID, testSurgeConfirm)
    }
}
