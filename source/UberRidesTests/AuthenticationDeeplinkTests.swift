//
//  AuthenticationDeeplinkTests.swift
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

class AuthenticationDeeplinkTests: XCTestCase {
    
    private var versionNumber: String?
    
    override func setUp() {
        super.setUp()
        Configuration.restoreDefaults()
        Configuration.plistName = "testInfo"
        Configuration.bundle = NSBundle(forClass: self.dynamicType)
        versionNumber = NSBundle(forClass: RideParameters.self).objectForInfoDictionaryKey("CFBundleShortVersionString") as? String
    }
    
    override func tearDown() {
        Configuration.restoreDefaults()
        super.tearDown()
    }
    
    func testScheme() {
        let authenticationDeeplink = AuthenticationDeeplink(scopes:[])
        XCTAssertEqual(authenticationDeeplink.scheme, "uberauth")
    }
    
    func testHost() {
        let authenticationDeeplink = AuthenticationDeeplink(scopes:[])
        XCTAssertEqual(authenticationDeeplink.domain, "connect")
    }
    
    func testPath() {
        let authenticationDeeplink = AuthenticationDeeplink(scopes:[])
        XCTAssertNil(authenticationDeeplink.path)
    }
    
    func testDeeplinkURL() {
        let scopes = [RidesScope.AllTrips, RidesScope.Profile]
        let authenticationDeeplink = AuthenticationDeeplink(scopes:scopes)
        let expectedURLPrefix = "uberauth://connect?"
        
        XCTAssertTrue(authenticationDeeplink.deeplinkURL.absoluteString!.hasPrefix(expectedURLPrefix))
    }
}


