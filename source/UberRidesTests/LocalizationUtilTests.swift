//
//  LocalizationUtilTests.swift
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
@testable import UberRides

class LocalizationUtilTests : XCTestCase {
    
    override func setUp() {
        super.setUp()
    }
    
    override func tearDown() {
        super.tearDown()
    }
    
    func testRequestButtonTitleText() {
        let localizationKey = "Ride there with Uber";
        let expectedString = "Ride there with Uber";
        XCTAssertEqual(LocalizationUtil.localizedString(forKey: localizationKey, comment: "asdf"), expectedString)
    }
    
    func testAuthorizationTitleTest() {
        let localizationKey = "Sign in with Uber"
        let expectedString = "Sign in with Uber";
        XCTAssertEqual(LocalizationUtil.localizedString(forKey: localizationKey, comment: "asdf"), expectedString)
    }
    
    func testAuthenticationErrorMessageText() {
        let localizationKey = "There was a problem authenticating you. Please try again."
        let expectedString  = "There was a problem authenticating you. Please try again.";
        XCTAssertEqual(LocalizationUtil.localizedString(forKey: localizationKey, comment: "asdf"), expectedString)
    }
    
    func testRideRequestUnknownError() {
        let localizationKey = "The Ride Request Widget encountered a problem. Please try again."
        let expectedString  = "The Ride Request Widget encountered a problem. Please try again.";
        XCTAssertEqual(LocalizationUtil.localizedString(forKey: localizationKey, comment: "asdf"), expectedString)
    }
    
    func testOkayButtonTitleText() {
        let localizationKey = "OK"
        let expectedString  = "OK";
        XCTAssertEqual(LocalizationUtil.localizedString(forKey: localizationKey, comment: "asdf"), expectedString)
    }
    
    func testDoneButtonTitleText() {
        let localizationKey = "Done"
        let expectedString = "Done";
        XCTAssertEqual(LocalizationUtil.localizedString(forKey: localizationKey, comment: "asdf"), expectedString)
    }
    
}
