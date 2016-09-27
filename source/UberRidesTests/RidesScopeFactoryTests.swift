//
//  RidesScopeFactoryTests.swift
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
@testable import UberRides

class RidesScopeFactoryTests: XCTestCase {
    let expectedRidesScopeToStringMapping = [
        RidesScopeType.Profile : RidesScopeType.Profile.toString(),
        RidesScopeType.History : RidesScopeType.History.toString(),
        RidesScopeType.HistoryLite : RidesScopeType.HistoryLite.toString(),
        RidesScopeType.Places : RidesScopeType.Places.toString(),
        RidesScopeType.RideWidgets : RidesScopeType.RideWidgets.toString(),
        RidesScopeType.AllTrips : RidesScopeType.AllTrips.toString(),
        RidesScopeType.Request : RidesScopeType.Request.toString(),
        RidesScopeType.RequestReceipt : RidesScopeType.RequestReceipt.toString(),
    ]
    
    func testCreateRidesScopeByRidesScopeType() {
        
        for (ridesScopeType, rawValue) in expectedRidesScopeToStringMapping {
            let ridesScope = RidesScopeFactory.ridesScopeForType(ridesScopeType)
            
            XCTAssertNotNil(ridesScope)
            XCTAssertEqual(ridesScope.ridesScopeType, ridesScopeType)
            XCTAssertEqual(ridesScope.rawValue, rawValue)
            XCTAssertEqual(ridesScope.scopeType, ridesScopeType.type)
        }
    }
    
    func testCreateRidesScopeByRawValue() {
        for (ridesScopeType, rawValue) in expectedRidesScopeToStringMapping {
            guard let ridesScope = RidesScopeFactory.ridesScopeForString(rawValue) else {
                XCTAssert(false)
                return
            }
            
            XCTAssertEqual(ridesScope.ridesScopeType, ridesScopeType)
            XCTAssertEqual(ridesScope.rawValue, rawValue)
            XCTAssertEqual(ridesScope.scopeType, ridesScopeType.type)
        }
    }
    
    func testCreateRidesScopeByRawValue_withUnknownValue() {
        let ridesScope = RidesScopeFactory.ridesScopeForString("not.real.error")
        XCTAssertNil(ridesScope)
    }
}
