//
//  RideRequestViewErrorFactoryTests.swift
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

class RideRequestViewErrorFactoryTests: XCTestCase {
    let expectedErrorToStringMapping = [
        RideRequestViewErrorType.AccessTokenExpired : RideRequestViewErrorType.AccessTokenExpired.toString(),
        RideRequestViewErrorType.AccessTokenMissing : RideRequestViewErrorType.AccessTokenMissing.toString(),
        RideRequestViewErrorType.NetworkError : RideRequestViewErrorType.NetworkError.toString(),
        RideRequestViewErrorType.NotSupported : RideRequestViewErrorType.NotSupported.toString(),
        RideRequestViewErrorType.Unknown : RideRequestViewErrorType.Unknown.toString()
    ]
    
    func testCreateErrorsByErrorType() {
        
        for errorType in expectedErrorToStringMapping.keys {
            let rideRequestViewError = RideRequestViewErrorFactory.errorForType(errorType)
            
            XCTAssertNotNil(rideRequestViewError)
            XCTAssertEqual(rideRequestViewError.code , errorType.rawValue)
            XCTAssertEqual(rideRequestViewError.domain , RideRequestViewErrorFactory.errorDomain)
        }
    }
    
    func testCreateErrorsByRawValue() {
        for (errorType, rawValue) in expectedErrorToStringMapping {
            let rideRequestViewError = RideRequestViewErrorFactory.errorForString(rawValue)
            
            XCTAssertNotNil(rideRequestViewError)
            XCTAssertEqual(rideRequestViewError.code , errorType.rawValue)
            XCTAssertEqual(rideRequestViewError.domain , RideRequestViewErrorFactory.errorDomain)
        }
    }
    
    func testCreateErrorByRawValue_withUnknownValue() {
        let rideRequestViewError = RideRequestViewErrorFactory.errorForString("not.real.error")
        
        XCTAssertEqual(rideRequestViewError.code, RideRequestViewErrorType.Unknown.rawValue)
    }
}
