//
//  UberScopeFactoryTests.swift
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
@testable import UberCore

class UberScopeFactoryTests: XCTestCase {
    let expectedUberScopeToStringMapping = [
        UberScopeType.profile : UberScopeType.profile.toString(),
        UberScopeType.history : UberScopeType.history.toString(),
        UberScopeType.historyLite : UberScopeType.historyLite.toString(),
        UberScopeType.places : UberScopeType.places.toString(),
        UberScopeType.rideWidgets : UberScopeType.rideWidgets.toString(),
        UberScopeType.allTrips : UberScopeType.allTrips.toString(),
        UberScopeType.request : UberScopeType.request.toString(),
        UberScopeType.requestReceipt : UberScopeType.requestReceipt.toString(),
    ]
    
    func testCreateUberScopeByUberScopeType() {
        
        for (uberScopeType, rawValue) in expectedUberScopeToStringMapping {
            let uberScope = UberScopeFactory.uberScopeForType(uberScopeType)
            
            XCTAssertNotNil(uberScope)
            XCTAssertEqual(uberScope.uberScopeType, uberScopeType)
            XCTAssertEqual(uberScope.rawValue, rawValue)
            XCTAssertEqual(uberScope.scopeType, uberScopeType.type)
        }
    }
    
    func testCreateUberScopeByRawValue() {
        for (uberScopeType, rawValue) in expectedUberScopeToStringMapping {
            guard let uberScope = UberScopeFactory.uberScopeForString(rawValue) else {
                XCTAssert(false)
                return
            }
            
            XCTAssertEqual(uberScope.uberScopeType, uberScopeType)
            XCTAssertEqual(uberScope.rawValue, rawValue)
            XCTAssertEqual(uberScope.scopeType, uberScopeType.type)
        }
    }
    
    func testCreateUberScopeByRawValue_withUnknownValue() {
        let uberScope = UberScopeFactory.uberScopeForString("not.real.error")
        XCTAssertNil(uberScope)
    }
}
