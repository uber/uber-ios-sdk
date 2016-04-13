//
//  WidgetsEndpointTests.swift
//  UberRides
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
@testable import UberRides

class WidgetsEndpointTests: XCTestCase {

    override func setUp() {
        super.setUp()
        Configuration.restoreDefaults()
        Configuration.plistName = "testInfo"
        Configuration.bundle = NSBundle(forClass: self.dynamicType)
    }
    
    override func tearDown() {
        Configuration.restoreDefaults()
        super.tearDown()
    }
    
    func testERRC_withNoLocation() {
        Configuration.setSandboxEnabled(true)
        Configuration.setRegion(Region.Default)
        
        let expectedHost = "https://components.uber.com"
        let expectedPath = "/rides/"
        let expectedQueryItems = queryBuilder( ("env", "sandbox") )
        
        let rideRequestWidget = Components.RideRequestWidget(rideParameters: nil)
        
        XCTAssertEqual(rideRequestWidget.host, expectedHost)
        XCTAssertEqual(rideRequestWidget.path, expectedPath)
        XCTAssertEqual(rideRequestWidget.query, expectedQueryItems)
    }
    
    func testERRC_withRegionDefault_withSandboxEnabled() {
        Configuration.setSandboxEnabled(true)
        Configuration.setRegion(Region.Default)
        
        let expectedLat = 33.2
        let expectedLong = -41.2
        let expectedHost = "https://components.uber.com"
        let expectedPath = "/rides/"
        let expectedQueryItems = queryBuilder( ("env", "sandbox"),
            ("pickup[latitude]", "\(expectedLat)" ),
            ("pickup[longitude]", "\(expectedLong)")
        )
        let rideParameters = RideParametersBuilder().setPickupLocation(CLLocation(latitude: expectedLat, longitude: expectedLong)).build()
        let rideRequestWidget = Components.RideRequestWidget(rideParameters: rideParameters)
        
        XCTAssertEqual(rideRequestWidget.host, expectedHost)
        XCTAssertEqual(rideRequestWidget.path, expectedPath)
        
        for item in expectedQueryItems {
            XCTAssertTrue(rideRequestWidget.query.contains(item))
        }
    }
    
    func testERRC_withRegionChina_withSandboxEnabled() {
        Configuration.setSandboxEnabled(true)
        Configuration.setRegion(Region.China)
        
        let expectedHost = "https://components.uber.com.cn"
        let expectedPath = "/rides/"
        let expectedQueryItems = queryBuilder( ("env", "sandbox") )
        
        let rideRequestWidget = Components.RideRequestWidget(rideParameters: nil)
        
        XCTAssertEqual(rideRequestWidget.host, expectedHost)
        XCTAssertEqual(rideRequestWidget.path, expectedPath)
        XCTAssertEqual(rideRequestWidget.query, expectedQueryItems)
    }
    
    func testERRC_withRegionDefault_withSandboxDisabled() {
        Configuration.setSandboxEnabled(false)
        Configuration.setRegion(Region.Default)
        
        let expectedHost = "https://components.uber.com"
        let expectedPath = "/rides/"
        let expectedQueryItems = queryBuilder( ("env", "production") )
        
        let rideRequestWidget = Components.RideRequestWidget(rideParameters: nil)
        
        XCTAssertEqual(rideRequestWidget.host, expectedHost)
        XCTAssertEqual(rideRequestWidget.path, expectedPath)
        XCTAssertEqual(rideRequestWidget.query, expectedQueryItems)
    }
    
    func testERRC_withRegionChina_withSandboxDisabled() {
        Configuration.setSandboxEnabled(false)
        Configuration.setRegion(Region.China)
        
        let expectedHost = "https://components.uber.com.cn"
        let expectedPath = "/rides/"
        let expectedQueryItems = queryBuilder( ("env", "production") )
        
        let rideRequestWidget = Components.RideRequestWidget(rideParameters: nil)
        
        XCTAssertEqual(rideRequestWidget.host, expectedHost)
        XCTAssertEqual(rideRequestWidget.path, expectedPath)
        XCTAssertEqual(rideRequestWidget.query, expectedQueryItems)
    }
    
}
