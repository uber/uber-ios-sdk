//
//  RequestURLUtilTests.swift
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

class RequestURLUtilTests: XCTestCase {
    
    private var versionNumber: String?
    private var baseUserAgent: String?
    
    override func setUp() {
        super.setUp()
        Configuration.plistName = "testInfo"
        Configuration.restoreDefaults()
        versionNumber = Bundle(for: RideParameters.self).object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String
        baseUserAgent = "rides-ios-v\(versionNumber!)"
    }
    
    override func tearDown() {
        Configuration.restoreDefaults()
        super.tearDown()
    }
    
    func testCreateQueryParameters_withDefaultRideParameters() {
        let parameters = RideParametersBuilder().build()
        let locationQueryItem = URLQueryItem(name: "pickup", value: "my_location")
        let actionQueryItem = URLQueryItem(name: "action", value: "setPickup")
        let clientIdQueryItem = URLQueryItem(name: "client_id", value: "testClientID")
        let userAgentQueryItem = URLQueryItem(name: "user-agent", value: baseUserAgent)
        let expectedQueryParameters = [clientIdQueryItem, actionQueryItem, locationQueryItem, userAgentQueryItem]
        let comparisonSet = NSSet(array: expectedQueryParameters)
        
        let testQueryParameters = RequestURLUtil.buildRequestQueryParameters(parameters)
        let testComparisonSet = NSSet(array:testQueryParameters)
        
        XCTAssertEqual(comparisonSet, testComparisonSet)
    }
    
    func testCreateQueryParameters_withAllParameters() {
        
        let testPickupLocation = CLLocation(latitude: 32.0, longitude: -32.0)
        let testDropoffLocation = CLLocation(latitude: 62.0, longitude: -62.0)
        let testPickupNickname = "testPickup"
        let testPickupAddress = "123 pickup address"
        let testDropoffNickname = "testDropoff"
        let testDropoffAddress = "123 dropoff address"
        let testProductID = "test ID"
        let testSource = "test source"
        let expectedUserAgent = "\(baseUserAgent!)-\(testSource)"
        
        let pickupLatitudeQueryItem = URLQueryItem(name: "pickup[latitude]", value: "\(testPickupLocation.coordinate.latitude)")
        let pickupLongitudeQueryItem = URLQueryItem(name: "pickup[longitude]", value: "\(testPickupLocation.coordinate.longitude)")
        let pickupNicknameQueryItem = URLQueryItem(name: "pickup[nickname]", value: testPickupNickname)
        let pickupAddressQueryItem = URLQueryItem(name: "pickup[formatted_address]", value: testPickupAddress)
        
        let dropoffLatitudeQueryItem = URLQueryItem(name: "dropoff[latitude]", value: "\(testDropoffLocation.coordinate.latitude)")
        let dropoffLongitudeQueryItem = URLQueryItem(name: "dropoff[longitude]", value: "\(testDropoffLocation.coordinate.longitude)")
        let dropoffNicknameQueryItem = URLQueryItem(name: "dropoff[nickname]", value: testDropoffNickname)
        let dropoffAddressQueryItem = URLQueryItem(name: "dropoff[formatted_address]", value: testDropoffAddress)
        
        let productIdQueryItem = URLQueryItem(name: "product_id", value: testProductID)
        let clientIdQueryItem = URLQueryItem(name: "client_id", value: "testClientID")
        let userAgentQueryItem = URLQueryItem(name: "user-agent", value: expectedUserAgent)
        let actionQueryItem = URLQueryItem(name: "action", value: "setPickup")
        
        let expectedQueryParameters = [pickupLatitudeQueryItem, pickupLongitudeQueryItem, pickupNicknameQueryItem, pickupAddressQueryItem,
                                       dropoffLatitudeQueryItem, dropoffLongitudeQueryItem, dropoffNicknameQueryItem, dropoffAddressQueryItem,
                                       productIdQueryItem, clientIdQueryItem, userAgentQueryItem, actionQueryItem]
        
        let parameters = RideParametersBuilder()
        parameters.pickupLocation = testPickupLocation
        parameters.dropoffLocation = testDropoffLocation
        parameters.pickupNickname = testPickupNickname
        parameters.pickupAddress = testPickupAddress
        parameters.dropoffNickname = testDropoffNickname
        parameters.dropoffAddress = testDropoffAddress
        parameters.productID = testProductID
        parameters.source = testSource
        
        let comparisonSet = NSSet(array: expectedQueryParameters)
        
        let testQueryParameters = RequestURLUtil.buildRequestQueryParameters(parameters.build())
        let testComparisonSet = NSSet(array:testQueryParameters)
        
        XCTAssertEqual(comparisonSet, testComparisonSet)
    }
    
    func testCreateQueryParameters_withoutNicknames() {
        
        let testPickupLocation = CLLocation(latitude: 32.0, longitude: -32.0)
        let testDropoffLocation = CLLocation(latitude: 62.0, longitude: -62.0)
        let testPickupAddress = "123 pickup address"
        let testDropoffAddress = "123 dropoff address"
        let testProductID = "test ID"
        let testSource = "test source"
        let expectedUserAgent = "\(baseUserAgent!)-\(testSource)"
        
        let pickupLatitudeQueryItem = URLQueryItem(name: "pickup[latitude]", value: "\(testPickupLocation.coordinate.latitude)")
        let pickupLongitudeQueryItem = URLQueryItem(name: "pickup[longitude]", value: "\(testPickupLocation.coordinate.longitude)")
        let pickupAddressQueryItem = URLQueryItem(name: "pickup[formatted_address]", value: testPickupAddress)
        
        let dropoffLatitudeQueryItem = URLQueryItem(name: "dropoff[latitude]", value: "\(testDropoffLocation.coordinate.latitude)")
        let dropoffLongitudeQueryItem = URLQueryItem(name: "dropoff[longitude]", value: "\(testDropoffLocation.coordinate.longitude)")
        let dropoffAddressQueryItem = URLQueryItem(name: "dropoff[formatted_address]", value: testDropoffAddress)
        
        let productIdQueryItem = URLQueryItem(name: "product_id", value: testProductID)
        let clientIdQueryItem = URLQueryItem(name: "client_id", value: "testClientID")
        let userAgentQueryItem = URLQueryItem(name: "user-agent", value: expectedUserAgent)
        let actionQueryItem = URLQueryItem(name: "action", value: "setPickup")
        
        let expectedQueryParameters = [pickupLatitudeQueryItem, pickupLongitudeQueryItem, pickupAddressQueryItem,
                                       dropoffLatitudeQueryItem, dropoffLongitudeQueryItem, dropoffAddressQueryItem,
                                       productIdQueryItem, clientIdQueryItem, userAgentQueryItem, actionQueryItem]

        let parameters = RideParametersBuilder()
        parameters.pickupLocation = testPickupLocation
        parameters.dropoffLocation = testDropoffLocation
        parameters.pickupAddress = testPickupAddress
        parameters.dropoffAddress = testDropoffAddress
        parameters.productID = testProductID
        parameters.source = testSource
        
        let comparisonSet = NSSet(array: expectedQueryParameters)
        
        let testQueryParameters = RequestURLUtil.buildRequestQueryParameters(parameters.build())
        let testComparisonSet = NSSet(array:testQueryParameters)
        
        XCTAssertEqual(comparisonSet, testComparisonSet)
    }
    
    func testCreateQueryParameters_withoutFormattedAddresses() {
        
        let testPickupLocation = CLLocation(latitude: 32.0, longitude: -32.0)
        let testDropoffLocation = CLLocation(latitude: 62.0, longitude: -62.0)
        let testPickupNickname = "testPickup"
        let testDropoffNickname = "testDropoff"
        let testProductID = "test ID"
        let testSource = "test source"
        let expectedUserAgent = "\(baseUserAgent!)-\(testSource)"
        
        let pickupLatitudeQueryItem = URLQueryItem(name: "pickup[latitude]", value: "\(testPickupLocation.coordinate.latitude)")
        let pickupLongitudeQueryItem = URLQueryItem(name: "pickup[longitude]", value: "\(testPickupLocation.coordinate.longitude)")
        let pickupNicknameQueryItem = URLQueryItem(name: "pickup[nickname]", value: testPickupNickname)
        
        let dropoffLatitudeQueryItem = URLQueryItem(name: "dropoff[latitude]", value: "\(testDropoffLocation.coordinate.latitude)")
        let dropoffLongitudeQueryItem = URLQueryItem(name: "dropoff[longitude]", value: "\(testDropoffLocation.coordinate.longitude)")
        let dropoffNicknameQueryItem = URLQueryItem(name: "dropoff[nickname]", value: testDropoffNickname)
        
        let productIdQueryItem = URLQueryItem(name: "product_id", value: testProductID)
        let clientIdQueryItem = URLQueryItem(name: "client_id", value: "testClientID")
        let userAgentQueryItem = URLQueryItem(name: "user-agent", value: expectedUserAgent)
        let actionQueryItem = URLQueryItem(name: "action", value: "setPickup")
        
        let expectedQueryParameters = [pickupLatitudeQueryItem, pickupLongitudeQueryItem, pickupNicknameQueryItem,
                                       dropoffLatitudeQueryItem, dropoffLongitudeQueryItem, dropoffNicknameQueryItem,
                                       productIdQueryItem, clientIdQueryItem, userAgentQueryItem, actionQueryItem]

        let parameters = RideParametersBuilder()
        parameters.pickupLocation = testPickupLocation
        parameters.dropoffLocation = testDropoffLocation
        parameters.pickupNickname = testPickupNickname
        parameters.dropoffNickname = testDropoffNickname
        parameters.productID = testProductID
        parameters.source = testSource
        
        let comparisonSet = NSSet(array: expectedQueryParameters)
        
        let testQueryParameters = RequestURLUtil.buildRequestQueryParameters(parameters.build())
        let testComparisonSet = NSSet(array:testQueryParameters)
        
        XCTAssertEqual(comparisonSet, testComparisonSet)
    }
    
    func testCreateQueryParameters_withNoDropoff() {
        
        let testPickupLocation = CLLocation(latitude: 32.0, longitude: -32.0)
        let testPickupNickname = "testPickup"
        let testPickupAddress = "123 pickup address"
        let testProductID = "test ID"
        let testSource = "test source"
        let expectedUserAgent = "\(baseUserAgent!)-\(testSource)"
        
        let pickupLatitudeQueryItem = URLQueryItem(name: "pickup[latitude]", value: "\(testPickupLocation.coordinate.latitude)")
        let pickupLongitudeQueryItem = URLQueryItem(name: "pickup[longitude]", value: "\(testPickupLocation.coordinate.longitude)")
        let pickupNicknameQueryItem = URLQueryItem(name: "pickup[nickname]", value: testPickupNickname)
        let pickupAddressQueryItem = URLQueryItem(name: "pickup[formatted_address]", value: testPickupAddress)
        
        let productIdQueryItem = URLQueryItem(name: "product_id", value: testProductID)
        let clientIdQueryItem = URLQueryItem(name: "client_id", value: "testClientID")
        let userAgentQueryItem = URLQueryItem(name: "user-agent", value: expectedUserAgent)
        let actionQueryItem = URLQueryItem(name: "action", value: "setPickup")
        
        let expectedQueryParameters = [pickupLatitudeQueryItem, pickupLongitudeQueryItem, pickupNicknameQueryItem, pickupAddressQueryItem,
                                       productIdQueryItem, clientIdQueryItem, userAgentQueryItem, actionQueryItem]

        let parameters = RideParametersBuilder()
        parameters.pickupLocation = testPickupLocation
        parameters.pickupNickname = testPickupNickname
        parameters.pickupAddress = testPickupAddress
        parameters.productID = testProductID
        parameters.source = testSource
        
        let comparisonSet = NSSet(array: expectedQueryParameters)
        
        let testQueryParameters = RequestURLUtil.buildRequestQueryParameters(parameters.build())
        let testComparisonSet = NSSet(array:testQueryParameters)
        
        XCTAssertEqual(comparisonSet, testComparisonSet)
    }
}
